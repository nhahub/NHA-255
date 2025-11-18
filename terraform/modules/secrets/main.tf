# Database Credentials Secret
resource "aws_secretsmanager_secret" "database_credentials" {
  name        = var.database_secret_name
  description = "Database credentials for the application"

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, {
    Name        = var.database_secret_name
    SecretType  = "database"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  secret_id = aws_secretsmanager_secret.database_credentials.id
  secret_string = jsonencode({
    username = var.database_username
    password = var.database_password
    host     = var.database_host
    port     = var.database_port
    database = var.database_name
  })
}

# API Keys Secret
resource "aws_secretsmanager_secret" "api_keys" {
  name        = var.api_keys_secret_name
  description = "API keys for external services"

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, {
    Name        = var.api_keys_secret_name
    SecretType  = "api-keys"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    stripe_secret_key   = var.stripe_secret_key
    sendgrid_api_key    = var.sendgrid_api_key
    aws_access_key_id   = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
  })
}

# Application Config Secret
resource "aws_secretsmanager_secret" "app_config" {
  name        = var.app_config_secret_name
  description = "Application configuration settings"

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, {
    Name        = var.app_config_secret_name
    SecretType  = "app-config"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    jwt_secret          = var.jwt_secret
    encryption_key      = var.encryption_key
    environment         = var.environment
    log_level           = var.log_level
    api_rate_limit      = var.api_rate_limit
  })
}

# Custom Secrets (for additional user-defined secrets)
resource "aws_secretsmanager_secret" "custom_secrets" {
  for_each = var.custom_secrets

  name        = each.key
  description = each.value.description

  recovery_window_in_days = var.recovery_window_in_days

  tags = merge(var.tags, {
    Name        = each.key
    SecretType  = "custom"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "custom_secrets" {
  for_each = var.custom_secrets

  secret_id = aws_secretsmanager_secret.custom_secrets[each.key].id
  secret_string = jsonencode(each.value.secret_data)
}

# IAM Policy for K8s nodes to read secrets
resource "aws_iam_role_policy" "secrets_read_policy" {
  name = "secrets-read-policy"
  role = var.k8s_nodes_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ]
        Resource =  concat(
          [
            aws_secretsmanager_secret.database_credentials.arn,
            aws_secretsmanager_secret.api_keys.arn,
            aws_secretsmanager_secret.app_config.arn
          ],
          [for secret in aws_secretsmanager_secret.custom_secrets : secret.arn]
        )
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for specific users/roles to manage secrets
resource "aws_iam_policy" "secrets_management_policy" {
  name        = "secrets-management-policy"
  description = "Policy for managing secrets in Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:CreateSecret",
          "secretsmanager:UpdateSecret",
          "secretsmanager:DeleteSecret",
          "secretsmanager:RestoreSecret",
          "secretsmanager:RotateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:GetRandomPassword",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach management policy to specified roles/users
resource "aws_iam_role_policy_attachment" "secrets_management_attachment" {
  count = length(var.secrets_management_principals)

  role       = var.secrets_management_principals[count.index]
  policy_arn = aws_iam_policy.secrets_management_policy.arn
}