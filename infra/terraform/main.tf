# DevOps Stage 6 - Infrastructure as Code
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for ${var.project_name} application"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_ips
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Key Pair
resource "aws_key_pair" "app_key" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key

  tags = {
    Name        = "${var.project_name}-key"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.app_key.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = var.subnet_id

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y python3 python3-pip
              EOF

  tags = {
    Name        = "${var.project_name}-server"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}

# Elastic IP
resource "aws_eip" "app_eip" {
  domain   = "vpc"
  instance = aws_instance.app_server.id

  tags = {
    Name        = "${var.project_name}-eip"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_instance.app_server]
}

# Run Ansible after infrastructure is ready
# Inventory file is created as a side effect, not tracked in state
resource "null_resource" "run_ansible" {
  count = var.run_ansible ? 1 : 0

  triggers = {
    instance_id = aws_instance.app_server.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Create inventory file (not tracked in state)
      mkdir -p ${path.module}/../ansible/inventory
      cat > ${path.module}/../ansible/inventory/hosts.ini <<'INVENTORY'
[app_servers]
app_server ansible_host=${aws_eip.app_eip.public_ip} ansible_user=${var.ssh_user} ansible_ssh_private_key_file=${var.ssh_private_key_path}

[app_servers:vars]
domain=${var.domain}
acme_email=${var.acme_email}
jwt_secret=${var.jwt_secret}
github_repo=${var.github_repo}
github_branch=${var.github_branch}
traefik_dashboard_user=${var.traefik_dashboard_user}
traefik_dashboard_password=${var.traefik_dashboard_password}
app_directory=/opt/devops-stage-6
INVENTORY

      # Wait for instance to be ready
      sleep 30
      
      # Run Ansible playbook
      cd ${path.module}/../ansible && ansible-playbook -i inventory/hosts.ini playbook.yml
    EOT
  }

  depends_on = [
    aws_eip.app_eip,
    aws_instance.app_server
  ]
}