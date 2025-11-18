# VPC inputs
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for bastion"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for K8s nodes"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID"
  type        = string
}

# IAM inputs
variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

# Key inputs
variable "public_key" {
  description = "SSH public key"
  type        = string
}

variable "private_key_pem" {
  description = "SSH private key PEM"
  type        = string
  sensitive   = true
}

# Instance configuration
variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
}

variable "master_instance_type" {
  description = "Instance type for master node"
  type        = string
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}