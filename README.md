# Simple WebApp K8s IaC

Production-ready example of deploying a Flask application to AWS EKS using Terraform and Helm.

## Quick Start

```bash
# Deploy infrastructure
cd terraform/aws_infra
terraform init && terraform apply

# Configure kubectl
aws eks update-kubeconfig --name simple-eks-cluster --region eu-west-1

# Deploy application
cd ../production
terraform init && terraform apply -var="image_tag=1.0.0"
```

## Structure

- `app/` - Flask application
- `helm/simplewebapp/` - Helm chart
- `terraform/aws_infra/` - EKS cluster infrastructure
- `terraform/production/` - Production environment
- `terraform/staging/` - Staging environment

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- kubectl
- Helm >= 3.0

## Configuration

1. Update `terraform/{env}/values-{env}.yaml` with your image repository
2. Set base64-encoded secrets in values files
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and configure

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed instructions.

## License

MIT
