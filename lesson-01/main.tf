terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.13.0"
    }
  }

  required_version = ">= 1.1.2"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_instance" "my_server" {
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"

  tags = {
    Name = "my-server"
  }
}
