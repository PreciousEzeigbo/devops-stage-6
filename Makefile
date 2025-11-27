# Makefile for DevOps Stage 6

.PHONY: help dev prod build up down logs restart clean infra-init infra-plan infra-apply infra-destroy ansible-setup ansible-deploy

# Colors for output
YELLOW := \033[1;33m
GREEN := \033[1;32m
RED := \033[1;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(GREEN)DevOps Stage 6 - Available Commands$(NC)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

dev: ## Start all services in development mode
	@echo "$(YELLOW)Starting services in development mode...$(NC)"
	docker compose up -d
	@echo "$(GREEN)Services started! Access at http://localhost$(NC)"

logs: ## View logs from all services
	docker compose logs -f

build: ## Build all Docker images
	@echo "$(YELLOW)Building Docker images...$(NC)"
	docker compose build

up: ## Start all services
	docker compose up -d

down: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker compose down

restart: ## Restart all services
	@echo "$(YELLOW)Restarting services...$(NC)"
	docker compose restart

clean: ## Stop services and remove volumes
	@echo "$(RED)Stopping services and removing volumes...$(NC)"
	docker compose down -v
	@echo "$(GREEN)Cleanup complete$(NC)"

##@ Infrastructure

infra-init: ## Initialize Terraform
	@echo "$(YELLOW)Initializing Terraform...$(NC)"
	cd infra/terraform && terraform init

infra-plan: ## Run Terraform plan
	@echo "$(YELLOW)Running Terraform plan...$(NC)"
	cd infra/terraform && terraform plan

infra-apply: ## Apply Terraform changes
	@echo "$(YELLOW)Applying Terraform changes...$(NC)"
	cd infra/terraform && terraform apply

infra-destroy: ## Destroy infrastructure
	@echo "$(RED)Destroying infrastructure...$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd infra/terraform && terraform destroy; \
	fi

##@ Ansible

ansible-setup: ## Install Ansible requirements
	@echo "$(YELLOW)Installing Ansible requirements...$(NC)"
	cd infra/ansible && ansible-galaxy collection install -r requirements.yml

ansible-deploy: ## Run Ansible deployment
	@echo "$(YELLOW)Running Ansible deployment...$(NC)"
	cd infra/ansible && ansible-playbook -i inventory/hosts.ini playbook.yml

ansible-check: ## Run Ansible in check mode
	@echo "$(YELLOW)Running Ansible in check mode...$(NC)"
	cd infra/ansible && ansible-playbook -i inventory/hosts.ini playbook.yml --check

##@ Utilities

env-setup: ## Create .env file from example
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN).env file created from .env.example$(NC)"; \
		echo "$(YELLOW)Please edit .env with your configuration$(NC)"; \
	else \
		echo "$(RED).env file already exists$(NC)"; \
	fi

ssh: ## SSH into the production server (requires Terraform outputs)
	@echo "$(YELLOW)Connecting to production server...$(NC)"
	@cd infra/terraform && terraform output -raw ssh_connection_command | sh

health-check: ## Check if all services are running
	@echo "$(YELLOW)Checking service health...$(NC)"
	@docker compose ps

status: ## Show status of all services
	@docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

##@ Testing

test-local: ## Test local deployment
	@echo "$(YELLOW)Testing local deployment...$(NC)"
	@curl -f http://localhost/ || echo "$(RED)Frontend not responding$(NC)"
	@curl -f http://localhost:8081/version || echo "$(RED)Auth API not responding$(NC)"

##@ Production Deploy

prod-deploy: infra-apply ansible-deploy ## Full production deployment
	@echo "$(GREEN)Production deployment complete!$(NC)"
