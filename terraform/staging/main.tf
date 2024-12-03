variable "image_tag" {
  description = "Docker image tag for the application"
  type        = string
}
module "app_deploy" {
  source = "../modules/app_deploy"
  namespace   = "staging"
  helm_values_override_file = "./values-staging.yaml"
  image_tag = var.image_tag
}