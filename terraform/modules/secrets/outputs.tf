output "database_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = aws_secretsmanager_secret.database_credentials.arn
  sensitive   = true
}

output "database_secret_name" {
  description = "Name of the database credentials secret"
  value       = aws_secretsmanager_secret.database_credentials.name
}

output "api_keys_secret_arn" {
  description = "ARN of the API keys secret"
  value       = aws_secretsmanager_secret.api_keys.arn
  sensitive   = true
}

output "api_keys_secret_name" {
  description = "Name of the API keys secret"
  value       = aws_secretsmanager_secret.api_keys.name
}

output "app_config_secret_arn" {
  description = "ARN of the application configuration secret"
  value       = aws_secretsmanager_secret.app_config.arn
  sensitive   = true
}

output "app_config_secret_name" {
  description = "Name of the application configuration secret"
  value       = aws_secretsmanager_secret.app_config.name
}

output "custom_secrets_arns" {
  description = "ARNs of custom secrets"
  value       = { for k, v in aws_secretsmanager_secret.custom_secrets : k => v.arn }
  sensitive   = true
}

output "all_secret_arns" {
  description = "List of all secret ARNs"
  value = concat(
    [aws_secretsmanager_secret.database_credentials.arn],
    [aws_secretsmanager_secret.api_keys.arn],
    [aws_secretsmanager_secret.app_config.arn],
    [for secret in aws_secretsmanager_secret.custom_secrets : secret.arn]
  )
  sensitive = true
}

output "secrets_management_policy_arn" {
  description = "ARN of the secrets management IAM policy"
  value       = aws_iam_policy.secrets_management_policy.arn
}