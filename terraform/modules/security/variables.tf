variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for internal traffic rules"
  type        = string
}