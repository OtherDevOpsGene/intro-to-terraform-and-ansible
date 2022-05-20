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

variable "planet_az" {
  default     = "us-east-2a"
  description = "Availability zone to run the demo in"
}

resource "aws_instance" "webserver" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  availability_zone      = var.planet_az
  subnet_id              = aws_subnet.public_subnet[var.planet_az].id
  key_name               = var.key_name
  monitoring             = true
  ebs_optimized          = true

  #checkov:skip=CKV_AWS_88:Allowing public access for Ansible
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "planet-webserver-${count.index}"
    Project     = "planets"
    Environment = "demo"
    Role        = "webservers"
    Owner       = var.owner_email
  }
}

resource "aws_instance" "mongodb" {
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  availability_zone      = var.planet_az
  subnet_id              = aws_subnet.public_subnet[var.planet_az].id
  key_name               = var.key_name
  monitoring             = true
  ebs_optimized          = true

  #checkov:skip=CKV_AWS_88:Allowing public access for Ansible
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "planet-mongodb"
    Project     = "planets"
    Environment = "demo"
    Role        = "database"
    Owner       = var.owner_email
  }
}

resource "null_resource" "ansible" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook --inventory inventory-aws_ec2.yml --user ubuntu site.yml"
  }

  triggers = {
    always_run = timestamp()
  }
}
