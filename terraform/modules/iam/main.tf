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

# SSM Policy Attachment
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "k8s_profile" {
  name = "k8s-instance-profile"
  role = aws_iam_role.k8s_role.name
}