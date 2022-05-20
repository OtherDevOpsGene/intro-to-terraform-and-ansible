resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Application Load Balancer traffic"
  vpc_id      = aws_vpc.sandbox_vpc.id

  tags = {
    Name    = "alb_sg"
    Project = "planets"
    Owner   = var.owner_email
  }
}

resource "aws_security_group_rule" "alb_sg_allow_http" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  description       = "Public HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_allow_https" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  description       = "Public HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_sg_allow_http_to_webservers" {
  security_group_id        = aws_security_group.alb_sg.id
  type                     = "egress"
  description              = "HTTP to webservers"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_security_group_rule" "alb_sg_allow_https_to_webservers" {
  security_group_id        = aws_security_group.alb_sg.id
  type                     = "egress"
  description              = "HTTPS to webservers"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.webserver_sg.id
}

resource "aws_lb" "webserver_alb" {
  #checkov:skip=CKV2_AWS_28:No WAF since it is a demo- not good for production
  #checkov:skip=CKV_AWS_91:No logging since it is a demo- not good for production
  #checkov:skip=CKV2_AWS_20:HTTP only for demo- not good for production
  name_prefix                = "planet"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [for subnet in aws_subnet.public_subnet : subnet.id]
  drop_invalid_header_fields = true

  #checkov:skip=CKV_AWS_150:Allow deletion since it is a demo- not good for production
  enable_deletion_protection = false

  tags = {
    Name    = "planet-alb"
    Project = "planets"
    Owner   = var.owner_email
  }
}

resource "aws_lb_target_group" "webservers" {
  name     = "planet-webservers"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sandbox_vpc.id

  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_lb_target_group_attachment" "webserver" {
  count            = length(aws_instance.webserver)
  target_group_arn = aws_lb_target_group.webservers.arn
  target_id        = aws_instance.webserver[count.index].id
  port             = 80
}

resource "aws_alb_listener" "webservers_http" {
  #checkov:skip=CKV_AWS_2:HTTP only for demo- not good for production
  #checkov:skip=CKV_AWS_103:HTTP only for demo- not good for production
  load_balancer_arn = aws_lb.webserver_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.webservers.arn
    type             = "forward"
  }
}
