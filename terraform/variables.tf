variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for K8s nodes"
  type        = string
  default     = "t3.medium"
}

variable "bastion_instance_type" {
  description = "EC2 instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 20.04 LTS"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair"
  type        = string
  default     = "k8s-key"
}