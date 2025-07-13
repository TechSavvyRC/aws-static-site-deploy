###############################################################
#
# Variable Definitions and Local Values
# 
# This file defines all the input variables and local values used throughout the
# Terraform configuration. Variables allow customization of the deployment without
# modifying the main code, while locals help create consistent naming and tagging
# patterns across all resources. This includes AWS configuration, EC2 settings,
# application-specific values, and standardized tags for resource management.
#
###############################################################

# AWS region where all resources will be deployed
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "<aws_region>"    # Example: eu-north-1
}

# AWS CLI profile to use for authentication
variable "aws_profile" {
  description = "AWS CLI profile for Terraform"
  type        = string
  default     = "<profile_name>"    # Example: default
}

# EC2 instance size/type for the web application
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "<instance_type>"    # Example: t3.micro
}

# Amazon Machine Image ID for the EC2 instance
variable "ami_id" {
  description = "AMI ID for Amazon Linux 2023"
  type        = string
  default     = "<ami_id>"    # Example: ami-00c8ac9147e19828e
}

# SSH key pair name for EC2 instance access
variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "<key_pair_name>"    # Example: webapp-api-key
}

# Base name for the EC2 instance
variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "<instance_name>"    # Example: my-webapp
}

# GitHub repository URL containing the web application code
variable "github_repo" {
  description = "GitHub repo URL for website content"
  type        = string
  default     = "<github_repo_url>"    # Example: https://github.com/TechSavvyRC/techsavvyrc-webapp.git
}

# AWS Systems Manager parameter path for storing the API key securely
variable "ssm_parameter_name" {
  description = "Full path name of the SSM SecureString parameter for the API key"
  type        = string
  default     = "<ssm_parameter_path>"    # Example: /my-webapp/api-keys/account
}

# Email address where website contact form messages are sent
variable "contact_email_id" {
  description = "Email address configured for website contact form to receive messages"
  type        = string
  default     = "<your_email_id>"    # Example: contactme@yourdomain.com
}

# Display name associated with the contact email address
variable "contact_name" {
  description = "Display name assigned to the contact email address"
  type        = string
  default     = "<your_name>"    # Example: Steve Rogers
}

# Environment identifier for resource organization
variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "<environment_name>"    # Example: production
}

# Project name for consistent resource naming and tagging
variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "<project_name>"    # Example: my-webapp
}

# Local values for consistent naming and tagging across all resources
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "<manager_by>"    # Example: Terraform
    Owner       = "<owner_name>"    # Example: Steve Rogers
  }
  
  # Instance name with environment suffix
  instance_name = "${var.ec2_instance_name}-${var.environment}"
  
  # Security group name
  security_group_name = "${var.project_name}-sg-${var.environment}"
  
  # IAM role name
  iam_role_name = "${var.project_name}-role-${var.environment}"
}
