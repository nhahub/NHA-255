output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.k8s_vpc.id
}

output "master_private_ip" {
  description = "Private IP of the K8s master node for Ansible"
  value       = aws_instance.k8s_master.private_ip
}

output "worker_private_ips" {
  description = "Private IPs of the K8s worker nodes for Ansible"
  value       = aws_instance.k8s_workers[*].private_ip
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host for SSH access"
  value       = aws_instance.bastion.public_ip
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the K8s security group"
  value       = aws_security_group.k8s_sg.id
}