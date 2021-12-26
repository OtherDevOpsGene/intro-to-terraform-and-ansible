output "webserver_instance_ids" {
  description = "IDs of the webserver instances"
  value       = aws_instance.webserver[*].id
}

output "webserver_elastic_ips" {
  description = "Elastic IP addresses of the webserver instances"
  value       = aws_eip.webserver_eip[*].public_ip
}
