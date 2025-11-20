#!/bin/bash

# This script sets up an Ansible bastion host by installing necessary packages
# and configuring SSH access.

set -eo pipefail

# Get the script directory and navigate to terraform
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/../../terraform"
ANSIBLE_DIR="$SCRIPT_DIR/../ansible/aws_ubuntu"

cd "$TERRAFORM_DIR" || exit 1

# Edit inventory file to add nodes private IPs
terraform output -json | jq -r '
"[masters]
master ansible_host=" + .master_private_ip.value + "

[workers]
worker1 ansible_host=" + .worker_private_ips.value[0] + "
worker2 ansible_host=" + .worker_private_ips.value[1] + "

[all:vars]
ansible_ssh_user=ubuntu
ansible_ssh_private_key_file=./k8s-key.pem"
' > "$ANSIBLE_DIR/inventory.ini"

BASTION_IP=$(terraform output -raw bastion_public_ip)

scp -i k8s-key.pem -r "$ANSIBLE_DIR" ubuntu@$BASTION_IP:~/

# Copy the private key
scp -i k8s-key.pem k8s-key.pem ubuntu@$BASTION_IP:~/aws_ubuntu/

# Configure known_hosts on the bastion for ansible-managed nodes
ssh -i k8s-key.pem ubuntu@$BASTION_IP << 'ENDSSH'
sudo apt-get update && sudo apt-get install -y python3-pip
pip3 install ansible-core>=2.12
pip3 install ansible 
cd ~/aws_ubuntu
# Extract IPs from inventory and add to known_hosts
grep ansible_host inventory.ini | awk '{print $2}' | cut -d= -f2 | while read ip; do
  ssh-keyscan -H $ip >> ~/.ssh/known_hosts 2>/dev/null
done
ENDSSH


echo "Ansible bastion setup complete. Connect using: ssh -i k8s-key.pem ubuntu@$BASTION_IP"


echo "Ansible installed on bastion."
