###############################################################
# 
# IAM Role and Policy Configuration
# 
# This file creates the IAM (Identity and Access Management) resources needed
# for the EC2 instance to securely access AWS services. It defines an IAM role
# that the EC2 instance can assume, creates a custom policy that allows access
# to specific Systems Manager parameters (including encrypted ones), and sets up
# an instance profile to attach these permissions to the EC2 instance. This
# enables the application to securely retrieve API keys and other secrets.
# 
###############################################################

# IAM role that allows EC2 instances to assume permissions
resource "aws_iam_role" "web_role" {
  name = "techsavvyrc-webapp-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name        = "techsavvyrc-webapp-role"
    Environment = "production"
    Project     = "techsavvyrc-webapp"
  }
}

# Custom policy allowing access to specific SSM parameters and KMS decryption
resource "aws_iam_policy" "ssm_policy" {
  name        = "techsavvyrc-webapp-ssm-policy"
  description = "Allow EC2 to read specific SSM parameters and decrypt with specific KMS key"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:*:parameter${var.ssm_parameter_name}",
          "arn:aws:ssm:${var.aws_region}:*:parameter/techsavvyrc/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          "arn:aws:kms:${var.aws_region}:*:key/*"
        ]
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${var.aws_region}.amazonaws.com"
          }
        }
      }
    ]
  })
  tags = {
    Name        = "techsavvyrc-webapp-ssm-policy"
    Environment = "production"
    Project     = "techsavvyrc-webapp"
  }
}

# Attach the SSM policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.web_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

# Instance profile to attach the IAM role to EC2 instances
resource "aws_iam_instance_profile" "web_profile" {
  name = "techsavvyrc-webapp-instance-profile"
  role = aws_iam_role.web_role.name
  tags = {
    Name        = "techsavvyrc-webapp-instance-profile"
    Environment = "production"
    Project     = "techsavvyrc-webapp"
  }
}