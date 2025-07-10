##########################################################
# File: variables.tf
#
# Description:
# This file defines all input variables used across the 
# Terraform project. These variables externalize critical 
# values like AWS region, instance type, AMI ID, key paths, 
# and GitHub repository URL.
#
# Purpose:
# - To parameterize the infrastructure setup for flexibility.
# - To allow customization across environments (e.g., dev, prod).
#
# Contribution to Overall Setup:
# This file makes the code reusable and environment-agnostic 
# by decoupling hardcoded values from resource definitions.
#
# Best Practices:
# - Use descriptive variable names and include helpful 
#   descriptions.
# - Store secrets (e.g., private keys) securely and avoid 
#   committing sensitive values to version control.
# - Set defaults for development, but override via CLI or 
#   workspace-specific `*.tfvars` files for production.
##########################################################

# AWS region where the infrastructure will be deployed
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "<your_aws_region>"
}

# Named AWS CLI profile used for Terraform authentication
variable "aws_profile" {
  description = "AWS CLI profile for Terraform"
  type        = string
  default     = "default"
}

# EC2 instance type to provision (Free Tier eligible: t3.micro or t2.micro)
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Amazon Machine Image (AMI) ID for Amazon Linux 2023
variable "ami_id" {
  description = "AMI ID for Amazon Linux 2023"
  type        = string
  default     = "ami-00c8ac9147e19828e"
}

# Name of the EC2 Key Pair to associate with the instance
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "<your_key_name>"
}

# GitHub repository URL from which the EC2 instance will clone the website
variable "github_repo" {
  description = "GitHub repo URL for website content"
  type        = string
  default     = "<your_git_repository_link>"
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "<your_key_name>"
}
