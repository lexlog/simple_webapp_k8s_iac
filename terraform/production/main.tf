variable "image_tag" {
  description = "Docker image tag for the application"
  type        = string
}

module "app_deploy" {
  source = "../modules/app_deploy"
  namespace   = "production"
  helm_values_override_file = "./values-production.yaml"
  image_tag = var.image_tag
}