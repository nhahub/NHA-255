output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.k8s_sg.id
}