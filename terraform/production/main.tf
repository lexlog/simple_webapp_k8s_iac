variable "image_tag" {
  description = "Docker image tag for the application"
  type        = string
}

variable "image_repository" {
  description = "Docker image repository (e.g., ECR URL or Docker Hub)"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "simple-eks-cluster"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

module "app_deploy" {
  source = "../modules/app_deploy"
  namespace             = "production"
  helm_values_override_file = "./values-production.yaml"
  image_tag             = var.image_tag
  image_repository      = var.image_repository != "" ? var.image_repository : null
}