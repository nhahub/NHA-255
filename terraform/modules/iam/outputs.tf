output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.k8s_profile.name
}

output "role_arn" {
  description = "ARN of the IAM role"
  value       = aws_iam_role.k8s_role.arn
}

output "k8s_role_name" {
  description = "Name of the K8s IAM role"
  value       = aws_iam_role.k8s_role.name
}