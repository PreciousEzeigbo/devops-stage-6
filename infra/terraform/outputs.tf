output "server_public_ip" {
  description = "Public IP address of the server"
  value       = aws_eip.app_eip.public_ip
}

output "server_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app_server.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.app_sg.id
}

output "ssh_connection_command" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${aws_eip.app_eip.public_ip}"
}

output "application_url" {
  description = "Application URL"
  value       = "https://${var.domain}"
}

output "inventory_file" {
  description = "Path to generated Ansible inventory"
  value       = local_file.ansible_inventory.filename
}
