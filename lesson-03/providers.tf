terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.2.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
