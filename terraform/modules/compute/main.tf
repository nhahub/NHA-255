# AWS Key Pair
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-key"
  public_key = var.public_key
}

# K8s Master Instance
resource "aws_instance" "k8s_master" {
  ami                         = var.ami_id
  instance_type               = var.master_instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo "${var.public_key}" >> /home/ubuntu/.ssh/authorized_keys
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
  count = var.worker_count

  ami                         = var.ami_id
  instance_type               = var.worker_instance_type
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = false
  iam_instance_profile        = var.iam_instance_profile_name
  key_name                    = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo "${var.public_key}" >> /home/ubuntu/.ssh/authorized_keys
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
  ami                         = var.ami_id
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.k8s_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              cat > /home/ubuntu/.ssh/k8s-key.pem << 'KEYFILE'
              ${var.private_key_pem}
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