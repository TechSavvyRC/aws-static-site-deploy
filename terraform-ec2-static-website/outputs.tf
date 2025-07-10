############################################################
# File: outputs.tf
#
# Description:
# This file defines Terraform output variables that expose
# useful information after infrastructure provisioning is complete.
#
# Purpose:
# - Display the public IP of the deployed EC2 instance.
# - Provide the exact SSH command to access the instance securely.
#
# Contribution to Overall Setup:
# This file is essential for quickly retrieving access details
# without having to manually inspect AWS console or Terraform state.
#
# Best Practices:
# - Descriptive names and explanations.
# - Clear guidance for SSH access using generated private key.
# - Outputs simplify post-deploy troubleshooting and operations.
############################################################

# Output the public IP address of the EC2 instance for browser/SSH access
output "public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "ssh_command" {
  description = "SSH command to connect via PuTTY/OpenSSH"
  value       = "ssh -i ${path.module}/.ssh/<your_private_key_name>.pem ec2-user@${aws_instance.web.public_ip}"
  sensitive = true
}
