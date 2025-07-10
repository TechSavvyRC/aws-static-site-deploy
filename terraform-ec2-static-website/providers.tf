##########################################################
# File: providers.tf
#
# Description:
# This file configures the primary cloud provider used by 
# the Terraform project. In this case, it sets up the AWS 
# provider by specifying the region and credentials profile.
#
# Purpose:
# - To initialize the AWS provider required to provision 
#   and manage cloud infrastructure.
# - The region and profile used are externalized as input 
#   variables for portability and environment-based flexibility.
#
# Contribution to Overall Setup:
# This is a foundational configuration file. Without it, 
# Terraform cannot interact with the AWS APIs to provision 
# resources such as EC2 instances, VPCs, or S3 buckets.
#
# Best Practices:
# - Avoid hardcoding credentials.
# - Always externalize environment-specific values (e.g., 
#   region, profile) to `variables.tf`.
# - Use separate AWS profiles for production and staging 
#   to enforce environment separation.
##########################################################

# Configure the AWS provider with the specified region and profile
provider "aws" {
  region  = var.aws_region    # AWS region where resources will be provisioned (e.g., eu-north-1)
  profile = var.aws_profile   # Named AWS CLI profile used for authentication
}
