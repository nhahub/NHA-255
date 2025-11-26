# IAM Role for EC2 instances
resource "aws_iam_role" "k8s_role" {
  name = "k8s-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_policy" "ebs_csi_policy" {
  name = "EBS-CSI-Driver-Policy"
  description = "Policy to allow EKS nodes to manage EBS volumes"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeImages",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:CreateVolume",
          "ec2:ModifyVolume"

        ]
        Resource = "*"
      }
    ]
  })
}

# SSM Policy Attachment
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "k8s_profile" {
  name = "k8s-instance-profile"
  role = aws_iam_role.k8s_role.name
}