
# Create trust policy file
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name K8sNodeRole \
  --assume-role-policy-document file://trust-policy.json

# Create instance profile
aws iam create-instance-profile \
  --instance-profile-name K8sNodeInstanceProfile

# Add role to instance profile
aws iam add-role-to-instance-profile \
  --instance-profile-name K8sNodeInstanceProfile \
  --role-name K8sNodeRole

# First create the EBS policy
aws iam create-policy \
  --policy-name EBSCSIPolicy \
  --policy-document file://ebs_csi_policy.json

# Attach policy to role
aws iam attach-role-policy \
  --role-name K8sNodeRole \
  --policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/EBSCSIPolicy

# Get all your K8s node instance IDs
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=*k8s*" \
  --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# Attach to each instance
# Master
aws ec2 associate-iam-instance-profile \
  --instance-id i-0d56573397539c2a2 \
  --iam-instance-profile Name=K8sNodeInstanceProfile

#Workers
aws ec2 associate-iam-instance-profile \
  --instance-id i-085b710daee266c3a \
  --iam-instance-profile Name=K8sNodeInstanceProfile

aws ec2 associate-iam-instance-profile \
  --instance-id i-0b9ced8aea93a350a \
  --iam-instance-profile Name=K8sNodeInstanceProfile

