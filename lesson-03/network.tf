resource "aws_vpc" "sandbox_vpc" {
  cidr_block = "10.8.0.0/16"

  tags = {
    Name  = "sandbox_vpc"
    Owner = var.owner_email
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.sandbox_vpc.id
}

resource "aws_internet_gateway" "sandbox_gateway" {
  vpc_id = aws_vpc.sandbox_vpc.id

  tags = {
    Name  = "sandbox_gw"
    Owner = var.owner_email
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.sandbox_vpc.id
  cidr_block = "10.8.0.0/24"

  tags = {
    Name  = "sandbox_public"
    Owner = var.owner_email
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.sandbox_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sandbox_gateway.id
  }

  tags = {
    Name  = "sandbox_public"
    Owner = var.owner_email
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "webserver_sg" {
  name        = "webserver_sg"
  description = "Webserver traffic"
  vpc_id      = aws_vpc.sandbox_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all traffic out"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "webserver_sg"
    Owner = var.owner_email
  }
}
