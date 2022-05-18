output "webserver_public_ips" {
  description = "Public IP addresses of the NGINX webservers"
  value       = aws_instance.webserver[*].public_ip
}

output "mongodb_public_ip" {
  description = "Public IP address of the MongoDB database"
  value       = aws_instance.mongodb.public_ip
}

output "alb_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.webserver_alb.dns_name
}

output "planets_url" {
  description = "URL for the planets demo"
  value       = "http://${aws_lb.webserver_alb.dns_name}/"
}
