# outputs.tf (root)
output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = module.compute.bastion_public_ip
}

output "master_private_ip" {
  description = "Private IP of master node"
  value       = module.compute.master_private_ip
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = module.compute.worker_private_ips
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_key_path" {
  description = "Path to private key file"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security.security_group_id
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.repository_name
}

output "ecr_registry_id" {
  description = "Registry ID for ECR"
  value       = module.ecr.registry_id
}


output "database_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = module.secrets.database_secret_arn
  sensitive   = true
}

output "api_keys_secret_arn" {
  description = "ARN of the API keys secret"
  value       = module.secrets.api_keys_secret_arn
  sensitive   = true
}

output "app_config_secret_arn" {
  description = "ARN of the application configuration secret"
  value       = module.secrets.app_config_secret_arn
  sensitive   = true
}

output "secrets_management_policy_arn" {
  description = "ARN of the secrets management IAM policy"
  value       = module.secrets.secrets_management_policy_arn
}