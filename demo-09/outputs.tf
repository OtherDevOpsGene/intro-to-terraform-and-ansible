output "webserver_public_ips" {
  description = "Public IP addresses of the webservers"
  value       = aws_instance.webserver[*].public_ip
}

output "alb_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.webserver_alb.dns_name
}
