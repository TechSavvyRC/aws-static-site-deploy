###############################################################
# 
# AWS Provider Configuration
# 
# This file configures the AWS provider for Terraform, which is required to manage
# AWS resources. It sets up the connection to AWS by specifying which region to
# deploy resources in and which AWS profile to use for authentication. The actual
# values for region and profile are pulled from variables defined elsewhere in
# the configuration.
# 
###############################################################

# Configure the AWS provider with region and authentication profile
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
