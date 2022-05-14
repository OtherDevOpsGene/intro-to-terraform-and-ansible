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

data "aws_ami" "ubuntu_linux" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "app_server" {
  lifecycle {
    create_before_destroy = true
  }

  count         = 2
  ami           = data.aws_ami.ubuntu_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "${var.instance_name}-${count.index}"
  }
}
