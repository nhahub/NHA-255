# variables.tf (root)
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
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

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "ami_id" {
  description = "AMI ID for instances"
  type        = string
  default     = "ami-0c398cb65a93047f2" # Ubuntu 22.04 LTS
}

variable "master_instance_type" {
  description = "Instance type for master node"
  type        = string
  default     = "c7i-flex.large"
}

variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "c7i-flex.large"
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}


variable "ecr_repository_name" {
  description = "Name for the ECR repository"
  type        = string
  default     = "k8s-app-repository"
}

variable "ecr_access_principals" {
  description = "List of IAM principals that can push to ECR"
  type        = list(string)
  default     = []
}

variable "ecr_keep_last_images" {
  description = "Number of images to keep in ECR"
  type        = number
  default     = 30
}


# Basic Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "secrets_management_principals" {
  description = "List of IAM roles/users that can manage secrets"
  type        = list(string)
  default     = []
}

# Database Secret Variables
variable "database_username" {
  description = "Database username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "database_password" {
  description = "Database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "database_host" {
  description = "Database host"
  type        = string
  default     = "localhost"
}

variable "database_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "app_db"
}

# API Keys Secret Variables
variable "stripe_secret_key" {
  description = "Stripe secret key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "sendgrid_api_key" {
  description = "SendGrid API key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = ""
  sensitive   = true
}

# App Config Secret Variables
variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "encryption_key" {
  description = "Encryption key for application data"
  type        = string
  default     = ""
  sensitive   = true
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"
}

variable "api_rate_limit" {
  description = "API rate limit"
  type        = number
  default     = 1000
}

# Custom Secrets
variable "custom_secrets" {
  description = "Map of custom secrets to create"
  type = map(object({
    description = string
    secret_data = map(string)
  }))
  default = {}
}