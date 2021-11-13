terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.65"
    }
  }

  required_version = ">= 1.0.11"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

resource "aws_instance" "my_server" {
  count         = 2
  ami           = "ami-0629230e074c580f2"
  instance_type = "t2.micro"

  tags = {
    Name = "tf-lesson-01-${count.index}"
  }
}
