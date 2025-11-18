variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "k8s-app-repository"
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Whether to scan images on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository"
  type        = string
  default     = "AES256"
}

variable "keep_last_images" {
  description = "Number of images to keep in the repository"
  type        = number
  default     = 30
}

variable "untagged_image_expiry_days" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 7
}

variable "ecr_access_principals" {
  description = "List of IAM principals that can access ECR"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for VPC-based access control"
  type        = string
}

variable "k8s_nodes_role_name" {
  description = "IAM role name used by K8s nodes"
  type        = string
}

variable "tags" {
  description = "Additional tags for the ECR repository"
  type        = map(string)
  default     = {}
}