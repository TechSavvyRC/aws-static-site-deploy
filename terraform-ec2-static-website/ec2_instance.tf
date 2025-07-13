###############################################################
# 
# EC2 Instance Configuration
# 
# This file creates and configures the main EC2 instance that will host the web
# application. It sets up the instance with the specified AMI, instance type,
# security groups, and IAM permissions. The instance runs a startup script that
# automatically clones the GitHub repository and configures the application with
# necessary environment variables and API keys from AWS Systems Manager.
# 
###############################################################

# Template for the user data script with variable substitution
data "template_file" "user_data" {
  template = file("${path.module}/scripts/clone_repo.sh")
  
  vars = {
    aws_region          = var.aws_region
    github_repo         = var.github_repo
    ssm_parameter_name  = var.ssm_parameter_name
    contact_email_id    = var.contact_email_id
    contact_name        = var.contact_name
  }
}

# Main EC2 instance for hosting the web application
resource "aws_instance" "web" {
  ami = var.ami_id
  instance_type = var.instance_type
  #key_name = aws_key_pair.deployer.key_name
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  #vpc_security_group_ids = ["sg-0ee5f6f626e80c130"]
  availability_zone = "${var.aws_region}a"
  iam_instance_profile = aws_iam_instance_profile.web_profile.name

  user_data = base64encode(templatefile("${path.module}/scripts/clone_repo.sh", {
    aws_region          = var.aws_region
    github_repo         = var.github_repo
    ssm_parameter_name  = var.ssm_parameter_name
    contact_email_id    = var.contact_email_id
    contact_name        = var.contact_name
  }))

  depends_on = [
    aws_iam_instance_profile.web_profile,
    aws_iam_role_policy_attachment.attach_ssm_policy
  ]

  tags = {
    Name = var.ec2_instance_name
    Environment = "production"
    Project = "techsavvyrc-webapp"
  }
}
