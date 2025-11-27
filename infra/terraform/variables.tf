variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devops-stage-6"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "ssh_allowed_ips" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for Ansible"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for the server"
  type        = string
  default     = "ubuntu"
}

variable "domain" {
  description = "Domain name for the application"
  type        = string
}

variable "acme_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret for authentication"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository URL"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to deploy"
  type        = string
  default     = "main"
}

variable "run_ansible" {
  description = "Whether to run Ansible after provisioning"
  type        = bool
  default     = true
}

variable "traefik_dashboard_user" {
  description = "Username for Traefik dashboard"
  type        = string
  default     = "admin"
}

variable "traefik_dashboard_password" {
  description = "Password for Traefik dashboard (will be hashed)"
  type        = string
  sensitive   = true
}
