output "workstation_instance_id" {
  description = "ID of the Ansible workstation instance"
  value       = aws_instance.workstation.id
}

output "target_instance_ids" {
  description = "IDs of the Ansible target instances"
  value       = aws_instance.target[*].id
}

output "workstation_public_ip" {
  description = "Public IP address of the Ansible workstation"
  value       = aws_instance.workstation.public_ip
}

output "workstation_private_ip" {
  description = "Private IP address of the Ansible workstation"
  value       = aws_instance.workstation.private_ip
}

output "target_private_ips" {
  description = "Private IP addresses of the Ansible targets"
  value       = aws_instance.target[*].private_ip
}
