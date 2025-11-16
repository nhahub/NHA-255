#!/bin/bash

## This Bash script deploys the infrastructure components required for a self-managed Kubernetes cluster.


#create key
aws ec2 create-key-pair --key-name NHA-255-ec2-key --query 'KeyMaterial' --output text > NHA-255-ec2-key.pem
chmod 400 NHA-255-ec2-key.pem

#create security group
aws ec2 create-security-group --group-name prod-k8s-sg --description "Security group for production Kubernetes cluster" --query 'GroupID'
aws ec2 create-security-group --group-name prod-k8s-master-sg --description "Security group for production Kubernetes cluster" --query 'GroupID'
aws ec2 create-security-group --group-name prod-k8s-worker-sg --description "Security group for production Kubernetes cluster" --query 'GroupID'

#add inbound rules
aws ec2 authorize-security-group-ingress --group-name prod-k8s-sg --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-sg --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-sg --protocol tcp --port 443 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-name prod-k8s-master-sg --protocol tcp --port 6443 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-master-sg --protocol tcp --port 2379 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-master-sg --protocol tcp --port 2380 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-master-sg --protocol tcp --port 10250 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-master-sg --protocol tcp --port 10259 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress --group-name prod-k8s-worker-sg --protocol tcp --port 10250 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name prod-k8s-worker-sg --protocol tcp --port 30000-32767 --cidr 0.0.0.0/0

# create EC2 instance
aws ec2 run-instances \
    --image-id ami-0c398cb65a93047f2 \
    --count 1 \
    --instance-type t3.medium \
    --key-name NHA-255-ec2-key \
    --security-groups prod-k8s-sg prod-k8s-master-sg \
    --block-device-mappings "DeviceName=/dev/sda1,Ebs={VolumeSize=30}" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=K8s-Master}]'

aws ec2 run-instances \
    --image-id ami-0c398cb65a93047f2 \
    --count 2 \
    --instance-type t3.medium \
    --key-name NHA-255-ec2-key \
    --security-groups prod-k8s-sg prod-k8s-worker-sg \
    --block-device-mappings "DeviceName=/dev/sda1,Ebs={VolumeSize=12}" \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=K8s-Worker}]'

aws ec2 create-volume \
  --availability-zone us-east-1f \
  --size 10 \
  --volume-type gp3 \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=mysql-data}]'