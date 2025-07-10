############################################################
# File: security_group.tf
#
# Description:
# Defines the AWS Security Group used by the EC2 instance
# hosting the static web application.
#
# Purpose:
# - Controls inbound (ingress) and outbound (egress) traffic
#   to the EC2 instance.
# - Opens necessary ports for SSH (22), HTTP (80), and HTTPS (443).
#
# Contribution to Overall Setup:
# This resource ensures that:
# - You can securely SSH into the instance.
# - Web traffic (HTTP/HTTPS) is allowed from the internet.
# - The instance can make outbound calls if needed (e.g., for package installs).
#
# Best Practices:
# - Restrict SSH (`port 22`) to known IP ranges in production.
# - Keep rules tightly scoped for enhanced security.
############################################################

# Define a security group to allow SSH, HTTP, and HTTPS traffic
resource "aws_security_group" "web_sg" {
  name        = "<your_security_group_name>"
  description = "Allow SSH, HTTP, HTTPS"

  # Allow incoming SSH traffic (port 22) from all IPs
  # NOTE: Restrict in production to specific IPs
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming HTTP traffic (port 80) for website access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming HTTPS traffic (port 443) for secure access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  # Necessary for updates, git clone, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
