###############################################################
# 
# Security Group Configuration
# 
# This file defines the AWS Security Group that controls network access to the
# EC2 instance hosting the web application. It acts as a virtual firewall,
# specifying which inbound and outbound traffic is allowed. The security group
# opens the necessary ports for SSH access (22), HTTP web traffic (80), and
# HTTPS secure web traffic (443), while allowing all outbound traffic for
# system updates and application functionality.
# 
###############################################################

# Security group defining firewall rules for the web application EC2 instance
resource "aws_security_group" "web_sg" {
  name        = "techsavvyrc-sg"
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
