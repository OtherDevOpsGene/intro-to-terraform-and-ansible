resource "aws_vpc" "sandbox_vpc" {
  #checkov:skip=CKV2_AWS_11:Skipping logging to make permissions easier- not a generally good idea
  cidr_block = "10.8.0.0/16"

  tags = {
    Name    = "sandbox_vpc"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.sandbox_vpc.id
}

resource "aws_internet_gateway" "sandbox_gateway" {
  vpc_id = aws_vpc.sandbox_vpc.id

  tags = {
    Name    = "sandbox_gw"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.sandbox_vpc.id
  cidr_block = "10.8.0.0/24"

  tags = {
    Name    = "sandbox_public"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.sandbox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox_gateway.id
  }

  tags = {
    Name    = "sandbox_public"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "workstation_sg" {
  name        = "workstation_sg"
  description = "Ansible workstation traffic"
  vpc_id      = aws_vpc.sandbox_vpc.id

  #checkov:skip=CKV_AWS_24:Allowing public access to SSH
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "All outgoing"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name    = "workstation_sg"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_security_group" "target_sg" {
  name        = "target_sg"
  description = "Webserver and internal traffic"
  vpc_id      = aws_vpc.sandbox_vpc.id

  tags = {
    Name    = "target_sg"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_security_group_rule" "target_sg_allow_workstation_ssh" {
  security_group_id        = aws_security_group.target_sg.id
  type                     = "ingress"
  description              = "Workstation SSH"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.workstation_sg.id
}

resource "aws_security_group_rule" "target_sg_allow_workstation_mongodb" {
  security_group_id        = aws_security_group.target_sg.id
  type                     = "ingress"
  description              = "Workstation MongoDB"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.workstation_sg.id
}

resource "aws_security_group_rule" "target_sg_allow_public_http" {
  #checkov:skip=CKV_AWS_260:Allowing public access to HTTP
  security_group_id = aws_security_group.target_sg.id
  type              = "ingress"
  description       = "Public HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "target_sg_allow_public_https" {
  security_group_id = aws_security_group.target_sg.id
  type              = "ingress"
  description       = "Public HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "target_sg_allow_internal_mongodb" {
  security_group_id = aws_security_group.target_sg.id
  type              = "ingress"
  description       = "Internal MongoDB"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "target_sg_allow_all_outgoing" {
  security_group_id = aws_security_group.target_sg.id
  type              = "egress"
  description       = "All outgoing"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
