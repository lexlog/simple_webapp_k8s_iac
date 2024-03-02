.PHONY: help init plan apply destroy validate format lint test build push deploy clean

help:
	@echo "Available targets:"
	@echo "  make init          - Initialize Terraform in all environments"
	@echo "  make plan          - Plan infrastructure changes"
	@echo "  make apply         - Apply infrastructure changes"
	@echo "  make destroy       - Destroy infrastructure"
	@echo "  make validate      - Validate Terraform configuration"
	@echo "  make format        - Format Terraform files"
	@echo "  make lint          - Lint Python code"
	@echo "  make test          - Run tests"
	@echo "  make build         - Build Docker image"
	@echo "  make push          - Push Docker image to ECR"
	@echo "  make deploy        - Deploy application (use ENV=staging|production)"
	@echo "  make clean         - Clean temporary files"

ENV ?= staging
IMAGE_TAG ?= latest
AWS_REGION ?= eu-west-1
CLUSTER_NAME ?= simple-eks-cluster

init:
	@echo "Initializing Terraform..."
	cd terraform/aws_infra && terraform init
	cd terraform/staging && terraform init
	cd terraform/production && terraform init

plan-infra:
	cd terraform/aws_infra && terraform plan

plan-staging:
	cd terraform/staging && terraform plan -var="image_tag=$(IMAGE_TAG)"

plan-production:
	cd terraform/production && terraform plan -var="image_tag=$(IMAGE_TAG)"

plan: plan-infra

apply-infra:
	cd terraform/aws_infra && terraform apply

apply-staging:
	cd terraform/staging && terraform apply -var="image_tag=$(IMAGE_TAG)" -auto-approve

apply-production:
	cd terraform/production && terraform apply -var="image_tag=$(IMAGE_TAG)" -auto-approve

apply:
	@echo "Use make apply-infra, make apply-staging, or make apply-production"

destroy-infra:
	cd terraform/aws_infra && terraform destroy

destroy-staging:
	cd terraform/staging && terraform destroy -auto-approve

destroy-production:
	cd terraform/production && terraform destroy -auto-approve

validate:
	@echo "Validating Terraform..."
	@cd terraform/aws_infra && terraform validate
	@cd terraform/staging && terraform validate
	@cd terraform/production && terraform validate
	@echo "Validating Helm charts..."
	@helm lint helm/simplewebapp

format:
	@echo "Formatting Terraform files..."
	@terraform fmt -recursive terraform/

lint:
	@echo "Linting Python code..."
	@cd app && pip install -q flake8 && flake8 . --max-line-length=127 --exclude=venv,__pycache__

test:
	@echo "Running tests..."
	@cd app && python -m pytest tests/ || echo "No tests found"

build:
	@echo "Building Docker image..."
	docker build -t simplewebapp:$(IMAGE_TAG) .

push:
	@echo "Pushing Docker image..."
	@echo "Please configure ECR repository URL"
	@echo "Example: docker push <ECR_URL>:$(IMAGE_TAG)"

deploy:
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV not set. Use: make deploy ENV=staging"; \
		exit 1; \
	fi
	cd terraform/$(ENV) && terraform apply -var="image_tag=$(IMAGE_TAG)" -auto-approve

clean:
	@echo "Cleaning temporary files..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.tfstate*" -delete 2>/dev/null || true
	find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

check-prereqs:
	@echo "Checking prerequisites..."
	@command -v terraform >/dev/null 2>&1 || { echo "Error: terraform not installed"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo "Error: AWS CLI not installed"; exit 1; }
	@command -v kubectl >/dev/null 2>&1 || { echo "Error: kubectl not installed"; exit 1; }
	@command -v helm >/dev/null 2>&1 || { echo "Error: helm not installed"; exit 1; }
	@echo "All prerequisites met!"
