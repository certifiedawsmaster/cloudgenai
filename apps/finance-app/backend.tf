terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "cloudgenai-deploy-assets-880247664530"
    key            = "apps/finance-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloudgenai-agent-state"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
