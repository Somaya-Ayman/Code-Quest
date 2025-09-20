# =============================================================================
# Code Quest Infrastructure - Makefile
# =============================================================================

.PHONY: help plan apply destroy dev prod aws kubectl state clean

# Default environment
ENVIRONMENT ?= dev
AWS_REGION ?= us-west-2
AWS_PROFILE ?= default

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

# =============================================================================
# Help
# =============================================================================
help: ## Show this help message
	@echo "$(BLUE)Code Quest Infrastructure Management$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make <target> [ENVIRONMENT=dev|prod] [AWS_REGION=us-west-2]"
	@echo ""
	@echo "$(YELLOW)Available targets:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make plan                    # Plan dev environment"
	@echo "  make apply ENVIRONMENT=prod  # Apply prod environment"
	@echo "  make destroy ENVIRONMENT=dev # Destroy dev environment"
	@echo "  make dev                     # Start dev environment shell"
	@echo "  make aws                     # Start AWS CLI shell"

# =============================================================================
# Terraform Operations
# =============================================================================
plan: ## Plan infrastructure changes
	@echo "$(BLUE)Planning infrastructure changes for $(ENVIRONMENT) environment...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) terraform-plan

apply: ## Apply infrastructure changes
	@echo "$(BLUE)Applying infrastructure changes for $(ENVIRONMENT) environment...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) terraform-apply

destroy: ## Destroy infrastructure
	@echo "$(RED)Destroying infrastructure for $(ENVIRONMENT) environment...$(NC)"
	@read -p "Are you sure you want to destroy the $(ENVIRONMENT) environment? (yes/no): " confirm && [ "$$confirm" = "yes" ]
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) terraform-destroy

# =============================================================================
# Environment Shells
# =============================================================================
dev: ## Start development environment shell
	@echo "$(BLUE)Starting development environment shell...$(NC)"
	docker-compose run --rm -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) dev-environment

prod: ## Start production environment shell
	@echo "$(BLUE)Starting production environment shell...$(NC)"
	docker-compose run --rm -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) prod-environment

# =============================================================================
# Utility Services
# =============================================================================
aws: ## Start AWS CLI shell
	@echo "$(BLUE)Starting AWS CLI shell...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) aws-cli

kubectl: ## Start kubectl shell
	@echo "$(BLUE)Starting kubectl shell...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) kubectl

state: ## Start terraform state management shell
	@echo "$(BLUE)Starting terraform state management shell...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) terraform-state

# =============================================================================
# Quick Commands
# =============================================================================
init: ## Initialize terraform
	@echo "$(BLUE)Initializing terraform...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) -e TERRAFORM_ACTION=init terraform

validate: ## Validate terraform configuration
	@echo "$(BLUE)Validating terraform configuration...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) -e TERRAFORM_ACTION=validate terraform

format: ## Format terraform files
	@echo "$(BLUE)Formatting terraform files...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) -e TERRAFORM_ACTION=fmt terraform

# =============================================================================
# Output Commands
# =============================================================================
output: ## Show terraform outputs
	@echo "$(BLUE)Showing terraform outputs...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) -e TERRAFORM_ACTION=output terraform

cluster-info: ## Show cluster information
	@echo "$(BLUE)Getting cluster information...$(NC)"
	docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) aws-cli sh -c "aws eks describe-cluster --name code-quest-$(ENVIRONMENT) --region $(AWS_REGION)"

# =============================================================================
# Cleanup
# =============================================================================
clean: ## Clean up docker containers and volumes
	@echo "$(BLUE)Cleaning up docker containers and volumes...$(NC)"
	docker-compose down --remove-orphans
	docker system prune -f
	docker volume prune -f

clean-all: ## Clean up everything including terraform cache
	@echo "$(BLUE)Cleaning up everything...$(NC)"
	docker-compose down --remove-orphans
	docker system prune -af
	docker volume prune -f
	rm -rf terraform/.terraform
	rm -rf terraform/.terraform.lock.hcl

# =============================================================================
# Status and Info
# =============================================================================
status: ## Show infrastructure status
	@echo "$(BLUE)Infrastructure Status:$(NC)"
	@echo "Environment: $(ENVIRONMENT)"
	@echo "AWS Region: $(AWS_REGION)"
	@echo "AWS Profile: $(AWS_PROFILE)"
	@echo ""
	@echo "$(YELLOW)Checking AWS credentials...$(NC)"
	@docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) aws-cli aws sts get-caller-identity || echo "$(RED)AWS credentials not configured$(NC)"
	@echo ""
	@echo "$(YELLOW)Checking EKS cluster...$(NC)"
	@docker-compose run --rm -e ENVIRONMENT=$(ENVIRONMENT) -e AWS_REGION=$(AWS_REGION) -e AWS_PROFILE=$(AWS_PROFILE) aws-cli aws eks list-clusters --region $(AWS_REGION) || echo "$(RED)EKS clusters not found$(NC)"

# =============================================================================
# Development Workflow
# =============================================================================
dev-workflow: ## Complete development workflow
	@echo "$(BLUE)Starting development workflow...$(NC)"
	@echo "1. Planning infrastructure..."
	@$(MAKE) plan ENVIRONMENT=$(ENVIRONMENT)
	@echo ""
	@echo "2. Applying infrastructure..."
	@$(MAKE) apply ENVIRONMENT=$(ENVIRONMENT)
	@echo ""
	@echo "3. Getting cluster information..."
	@$(MAKE) cluster-info ENVIRONMENT=$(ENVIRONMENT)
	@echo ""
	@echo "$(GREEN)Development workflow completed!$(NC)"

# =============================================================================
# Production Workflow
# =============================================================================
prod-workflow: ## Complete production workflow
	@echo "$(BLUE)Starting production workflow...$(NC)"
	@echo "1. Planning infrastructure..."
	@$(MAKE) plan ENVIRONMENT=prod
	@echo ""
	@echo "2. Applying infrastructure..."
	@$(MAKE) apply ENVIRONMENT=prod
	@echo ""
	@echo "3. Getting cluster information..."
	@$(MAKE) cluster-info ENVIRONMENT=prod
	@echo ""
	@echo "$(GREEN)Production workflow completed!$(NC)"

# =============================================================================
# Troubleshooting
# =============================================================================
debug: ## Start debug shell with all tools
	@echo "$(BLUE)Starting debug shell...$(NC)"
	docker-compose run --rm terraform ENVIRONMENT=$(ENVIRONMENT) AWS_REGION=$(AWS_REGION) AWS_PROFILE=$(AWS_PROFILE) sh -c "apk add --no-cache curl jq && bash"

logs: ## Show docker-compose logs
	@echo "$(BLUE)Showing docker-compose logs...$(NC)"
	docker-compose logs

# =============================================================================
# Default target
# =============================================================================
.DEFAULT_GOAL := help
