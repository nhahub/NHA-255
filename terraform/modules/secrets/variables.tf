# Basic Configuration
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "recovery_window_in_days" {
  description = "Number of days that secrets can be recovered after deletion"
  type        = number
  default     = 7
}

variable "k8s_nodes_role_name" {
  description = "IAM role name used by K8s nodes"
  type        = string
}

variable "secrets_management_principals" {
  description = "List of IAM roles/users that can manage secrets"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for secrets"
  type        = map(string)
  default     = {}
}

# Database Secret Variables
variable "database_secret_name" {
  description = "Name for the database credentials secret"
  type        = string
  default     = "k8s/database/credentials"
}

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
variable "api_keys_secret_name" {
  description = "Name for the API keys secret"
  type        = string
  default     = "k8s/api/keys"
}

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
variable "app_config_secret_name" {
  description = "Name for the application configuration secret"
  type        = string
  default     = "k8s/app/config"
}

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