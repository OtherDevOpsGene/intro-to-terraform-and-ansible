data "aws_ami" "ubuntu_linux" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-21.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "target" {
  count                  = 3
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.target_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = var.key_name
  monitoring             = true
  ebs_optimized          = true

  #checkov:skip=CKV_AWS_88:Allowing public access
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name    = "ansible-target-${count.index}"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_instance" "workstation" {
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.workstation_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = var.key_name
  monitoring             = true
  ebs_optimized          = true

  #checkov:skip=CKV_AWS_88:Allowing public access
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name    = "ansible-workstation"
    Owner   = var.owner_email
    Project = var.project_tag
  }

  provisioner "remote-exec" {
    script = "bootstrap-ansible.sh"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_file)
    }
  }
}
