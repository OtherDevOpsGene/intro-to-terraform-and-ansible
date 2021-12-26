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

resource "aws_instance" "webserver" {
  lifecycle {
    create_before_destroy = true
  }

  count                  = 2
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = var.key_name


  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name  = "webserver-${count.index}"
    Owner = var.owner_email
  }
}

resource "aws_eip" "webserver_eip" {
  count    = length(aws_instance.webserver)
  instance = element(aws_instance.webserver[*].id, count.index)
  vpc      = true

  tags = {
    Name  = "webserver-${count.index}"
    Owner = var.owner_email
  }
}
