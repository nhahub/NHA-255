# main.tf (root)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

}

# Generate SSH key pair
resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.k8s_ssh.private_key_pem
  filename = "${path.module}/k8s-key.pem"
  file_permission = "0400"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}

# IAM Module
module "iam" {
  source = "./modules/iam"
}

# Security Module
module "security" {
  source = "./modules/security"

  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  # VPC inputs
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_id
  private_subnet_id   = module.vpc.private_subnet_id
  security_group_id   = module.security.security_group_id

  # IAM inputs
  iam_instance_profile_name = module.iam.instance_profile_name

  # Key inputs
  public_key = tls_private_key.k8s_ssh.public_key_openssh
  private_key_pem = tls_private_key.k8s_ssh.private_key_pem

  # Instance configuration
  ami_id               = var.ami_id
  master_instance_type = var.master_instance_type
  worker_instance_type = var.worker_instance_type
  bastion_instance_type = var.bastion_instance_type
  worker_count        = var.worker_count
}


# ECR Module
module "ecr" {
  source = "./modules/ecr"

  repository_name    = var.ecr_repository_name
  vpc_id             = module.vpc.vpc_id
  k8s_nodes_role_name = module.iam.k8s_role_name
  
  # Optional: Allow specific IAM users/roles to push images
  ecr_access_principals = var.ecr_access_principals
  
  tags = {
    Environment = "production"
    Project     = "kubernetes-cluster"
  }
}


# Secrets Manager Module
module "secrets" {
  source = "./modules/secrets"

  environment                   = var.environment
  k8s_nodes_role_name          = module.iam.k8s_role_name
  secrets_management_principals = var.secrets_management_principals

  # Database credentials
  database_username = var.database_username
  database_password = var.database_password
  database_host     = var.database_host
  database_port     = var.database_port
  database_name     = var.database_name

  # API keys
  stripe_secret_key    = var.stripe_secret_key
  sendgrid_api_key     = var.sendgrid_api_key
  aws_access_key_id    = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key

  # App configuration
  jwt_secret     = var.jwt_secret
  encryption_key = var.encryption_key
  log_level      = var.log_level
  api_rate_limit = var.api_rate_limit

  # Custom secrets
  custom_secrets = var.custom_secrets

  tags = {
    Environment = var.environment
    Project     = "kubernetes-cluster"
    ManagedBy   = "terraform"
  }
}
