terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ecr            = var.floci_endpoint
    eks            = var.floci_endpoint
    rds            = var.floci_endpoint
    ec2            = var.floci_endpoint
    iam            = var.floci_endpoint
    sts            = var.floci_endpoint
    elbv2          = var.floci_endpoint
  }
}