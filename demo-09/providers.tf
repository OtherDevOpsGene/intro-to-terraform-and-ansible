terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.3.0"
    }
  }

  required_version = ">= 1.8.3"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
