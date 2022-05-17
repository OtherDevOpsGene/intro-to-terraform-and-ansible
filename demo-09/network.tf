variable "az_number" {
  # Assign a number to each AZ letter used in our configuration
  default = {
    a = 1
    b = 2
    c = 3
    d = 4
    e = 5
    f = 6
  }
}

# Determine all of the available availability zones in the
# current AWS region.
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zone" "all" {
  for_each = toset(data.aws_availability_zones.available.names)
  name     = each.key
}

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
  for_each          = data.aws_availability_zone.all
  availability_zone = each.key
  vpc_id            = aws_vpc.sandbox_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.sandbox_vpc.cidr_block, 4, var.az_number[data.aws_availability_zone.all[each.key].name_suffix])

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
  for_each       = aws_subnet.public_subnet
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.rtb_public.id
}

data "http" "ifconfig_co_ip" {
  url = "https://ifconfig.co/"
  request_headers = {
    Accept = "text/*"
  }
}

locals {
  current_ip = chomp(data.http.ifconfig_co_ip.body)
}

resource "aws_security_group" "webserver_sg" {
  name        = "webserver_sg"
  description = "Webserver traffic"
  vpc_id      = aws_vpc.sandbox_vpc.id

  tags = {
    Name    = "webserver_sg"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_security_group_rule" "webserver_sg_allow_ansible_ssh" {
  security_group_id = aws_security_group.webserver_sg.id
  type              = "ingress"
  description       = "Ansible SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${local.current_ip}/32"]
}

resource "aws_security_group_rule" "webserver_sg_allow_http" {
  security_group_id        = aws_security_group.webserver_sg.id
  type                     = "ingress"
  description              = "HTTP from Application Load Balancer"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "webserver_sg_allow_https" {
  security_group_id        = aws_security_group.webserver_sg.id
  type                     = "ingress"
  description              = "HTTPS from Application Load Balancer"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "webserver_sg_allow_all_outgoing" {
  security_group_id = aws_security_group.webserver_sg.id
  type              = "egress"
  description       = "All outgoing"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb_sg"
  description = "MongoDB traffic"
  vpc_id      = aws_vpc.sandbox_vpc.id

  tags = {
    Name    = "mongodb_sg"
    Owner   = var.owner_email
    Project = var.project_tag
  }
}

resource "aws_security_group_rule" "mongodb_sg_allow_ansible_ssh" {
  security_group_id = aws_security_group.mongodb_sg.id
  type              = "ingress"
  description       = "Ansible SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${local.current_ip}/32"]
}

resource "aws_security_group_rule" "mongodb_sg_allow_webserver_mongodb" {
  security_group_id        = aws_security_group.mongodb_sg.id
  type                     = "ingress"
  description              = "Webserver access to MongoDB"
  from_port                = 27017
  to_port                  = 27017
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "mongodb_sg_allow_all_outgoing" {
  security_group_id = aws_security_group.mongodb_sg.id
  type              = "egress"
  description       = "All outgoing"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
