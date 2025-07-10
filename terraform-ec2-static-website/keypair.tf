##########################################################
# File: keypair.tf
#
# Description:
# This file manages the generation and provisioning of SSH 
# key pairs used to securely access the EC2 instance.
#
# Purpose:
# - Generates a new RSA key pair (4096-bit).
# - Writes the private and public keys to local files.
# - Registers the public key with AWS as a Key Pair so it 
#   can be attached to EC2 instances.
#
# Contribution to Overall Setup:
# Enables secure SSH access to EC2 instances for setup and 
# troubleshooting. The private key can later be converted 
# to `.ppk` for PuTTY if needed.
#
# Best Practices:
# - Keys are written to paths defined in `variables.tf`.
# - Use appropriate file permissions (`0600` for private).
# - DO NOT commit the generated keys to version control.
##########################################################

# Generate a new RSA 4096-bit private/public SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the private key securely on the local machine
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/.ssh/<your_private_key_name>.pem"
  file_permission = "0600"
}

# Store the public key on the local machine
resource "local_file" "public_key" {
  content         = tls_private_key.ssh_key.public_key_openssh
  filename        = "${path.module}/.ssh/<your_public_key_name>.pub"
  file_permission = "0644"
}

# Register the public key with AWS EC2 as a named Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}
