output "webserver_public_ips" {
  description = "Public IP addresses of the NGINX webservers"
  value       = aws_instance.webserver[*].public_ip
}

output "webserver_private_ips" {
  description = "Private IP addresses of the NGINX webservers"
  value       = aws_instance.webserver[*].private_ip
}

output "planets_url" {
  description = "URL for the planets demo"
  value       = "http://${aws_lb.webserver_alb.dns_name}/"
}
