###############################################################
#
# SSH Key Pair Generation and Management
# 
# This file creates an SSH key pair for secure access to EC2 instances. It generates
# a private/public key pair using RSA encryption, saves both keys locally as files,
# and registers the public key with AWS as a key pair. This allows secure SSH access
# to the EC2 instances without having to manually create and manage SSH keys.
#
###############################################################

# Generate a new RSA private key for SSH access
#resource "tls_private_key" "ssh_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# Save the private key to a local file with secure permissions
#resource "local_file" "private_key" {
#  content         = tls_private_key.ssh_key.private_key_pem
#  filename        = "${path.module}/.ssh/techsavvyrc-webapp.pem"
#  file_permission = "0600"
#}

# Save the public key to a local file with standard permissions
#resource "local_file" "public_key" {
#  content         = tls_private_key.ssh_key.public_key_openssh
#  filename        = "${path.module}/.ssh/techsavvyrc-webapp.pub"
#  file_permission = "0644"
#}

# Register the public key with AWS as a key pair for EC2 access
#resource "aws_key_pair" "deployer" {
#  key_name   = var.key_name
#  public_key = tls_private_key.ssh_key.public_key_openssh
#}