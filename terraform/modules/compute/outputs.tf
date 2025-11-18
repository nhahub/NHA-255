output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value       = aws_instance.bastion.public_ip
}

output "master_private_ip" {
  description = "Private IP of master node"
  value       = aws_instance.k8s_master.private_ip
}

output "worker_private_ips" {
  description = "Private IPs of worker nodes"
  value       = aws_instance.k8s_workers[*].private_ip
}

output "key_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.k8s_key.key_name
}