terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "WJDVS-portfolio"

    workspaces {
      name = "aws-eks-wordpress-enterprise"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "aws-eks-wordpress-enterprise"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}