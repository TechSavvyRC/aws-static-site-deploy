###############################################################
# 
# Output Values Configuration
# 
# This file defines the output values that Terraform will display after
# successfully creating the infrastructure. These outputs provide important
# information about the deployed resources, including connection details,
# resource identifiers, and configuration summaries. This makes it easy to
# access the web application, connect to the server, and understand the
# current deployment configuration.
# 
###############################################################

# Public IP address of the deployed web server
output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

# EC2 instance identifier for reference and management
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

# Summary of key configuration values used in the deployment
output "configuration_summary" {
  description = "Summary of the current configuration"
  value = {
    aws_region       = var.aws_region
    instance_type    = var.instance_type
    environment      = var.environment
    project_name     = var.project_name
    github_repo      = var.github_repo
    ssm_parameter    = var.ssm_parameter_name
  }
}

# Ready-to-use SSH command for connecting to the instance
#output "ssh_command" {
#  description = "SSH command to connect via PuTTY/OpenSSH"
#  value       = "ssh -i ${path.module}/.ssh/techsavvyrc-webapp.pem ec2-user@${aws_instance.web.public_ip}"
#  sensitive = true
#}