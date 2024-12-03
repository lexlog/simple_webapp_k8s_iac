variable "namespace" {
  description = "The namespace where the resources will be deployed"
  type        = string
}

variable "helm_values_override_file" {
  description = "Optional override for Helm values"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag for the application"
  type        = string
}

resource "helm_release" "mytomorrows-flask" {

  name       = "mytomorrows-flask"
  repository  = "../../helm"
  chart      = "mytomorrows-flask"

  namespace  = var.namespace
  create_namespace = true
  wait             = true

  values = [
    file(var.helm_values_override_file)
  ]

  set {
    name  = "container.image_tag"
    value = var.image_tag
  }
}
