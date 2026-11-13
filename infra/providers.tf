terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_endpoint" {
  description = "AWS API endpoint. Defaults to the local Floci emulator."
  type        = string
  default     = "http://localhost:4566"
}

# Points at Floci (local AWS emulator), not real AWS.
# For real AWS: remove the endpoints block, the test keys and the skip_* lines,
# and authenticate the pipeline with OIDC.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_use_path_style           = true

  endpoints {
    s3  = var.aws_endpoint
    kms = var.aws_endpoint
    iam = var.aws_endpoint
    sts = var.aws_endpoint
  }
}
