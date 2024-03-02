output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "ecr_repository_url_dev" {
  description = "ECR repository URL for dev/staging"
  value       = aws_ecr_repository.simplewebapp-test-repo-dev.repository_url
}

output "ecr_repository_url_prod" {
  description = "ECR repository URL for production"
  value       = aws_ecr_repository.simplewebapp-test-repo-prod.repository_url
}

output "ecr_repository_name_dev" {
  description = "ECR repository name for dev/staging"
  value       = aws_ecr_repository.simplewebapp-test-repo-dev.name
}

output "ecr_repository_name_prod" {
  description = "ECR repository name for production"
  value       = aws_ecr_repository.simplewebapp-test-repo-prod.name
}
