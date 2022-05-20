terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.13.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1.0"
    }
  }

  required_version = ">= 1.1.2"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
