terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile ="terraform_dev"
}

# Generate SSH key pair using Terraform
resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS key pair
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = tls_private_key.k8s_ssh.public_key_openssh
}

# Save private key to file for SSH access
resource "local_file" "private_key" {
  content  = tls_private_key.k8s_ssh.private_key_pem
  filename = "${path.module}/k8s-key.pem"
  file_permission = "0400"
}

# Save public key to file for reference
resource "local_file" "public_key" {
  content  = tls_private_key.k8s_ssh.public_key_openssh
  filename = "${path.module}/k8s-key.pub"
  file_permission = "0644"
}

# VPC
resource "aws_vpc" "k8s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "k8s-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "k8s_igw" {
  vpc_id = aws_vpc.k8s_vpc.id

  tags = {
    Name = "k8s-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "k8s-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "k8s-private-subnet"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s_igw.id
  }

  tags = {
    Name = "k8s-public-rt"
  }
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway for Private Subnet
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "k8s_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "k8s-nat"
  }

  depends_on = [aws_internet_gateway.k8s_igw]
}

# Route Table for Private Subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.k8s_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.k8s_nat.id
  }

  tags = {
    Name = "k8s-private-rt"
  }
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group for K8s instances
resource "aws_security_group" "k8s_sg" {
  name        = "k8s-security-group"
  description = "Security group for Kubernetes cluster"
  vpc_id      = aws_vpc.k8s_vpc.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd client API
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.k8s_vpc.cidr_block]
  }

  # Kubelet API
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.k8s_vpc.cidr_block]
  }

  # NodePort services range
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal cluster communication
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.k8s_vpc.cidr_block]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}

# IAM Role for EC2 instances
resource "aws_iam_role" "k8s_role" {
  name = "k8s-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "k8s_profile" {
  name = "k8s-instance-profile"
  role = aws_iam_role.k8s_role.name
}

# K8s Master Instance
resource "aws_instance" "k8s_master" {
  ami                         = "ami-0c398cb65a93047f2" # Ubuntu 22.04 LTS
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.k8s_profile.name
  key_name                    = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Create SSH directory and add public key
              mkdir -p /home/ubuntu/.ssh
              echo "${tls_private_key.k8s_ssh.public_key_openssh}" >> /home/ubuntu/.ssh/authorized_keys
              chmod 700 /home/ubuntu/.ssh
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              EOF

  tags = {
    Name = "k8s-master"
    Role = "master"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

# K8s Worker Instances
resource "aws_instance" "k8s_workers" {
  count = 2

  ami                         = "ami-0c398cb65a93047f2" # Ubuntu 22.04 LTS
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.k8s_profile.name
  key_name                    = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Create SSH directory and add public key
              mkdir -p /home/ubuntu/.ssh
              echo "${tls_private_key.k8s_ssh.public_key_openssh}" >> /home/ubuntu/.ssh/authorized_keys
              chmod 700 /home/ubuntu/.ssh
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              EOF

  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = "ami-0c398cb65a93047f2" # Ubuntu 22.04 LTS
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.k8s_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Copy private key to bastion for SSH access to private instances
              mkdir -p /home/ubuntu/.ssh
              cat << 'KEYFILE' > /home/ubuntu/.ssh/k8s-key.pem
              ${tls_private_key.k8s_ssh.private_key_pem}
              KEYFILE
              chmod 700 /home/ubuntu/.ssh
              chmod 400 /home/ubuntu/.ssh/k8s-key.pem
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              EOF

  tags = {
    Name = "k8s-bastion"
    Role = "bastion"
  }
}