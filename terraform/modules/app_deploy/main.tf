variable "namespace" {
  description = "The namespace where the resources will be deployed"
  type        = string
}

variable "helm_values_override_file" {
  description = "Path to Helm values override file"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag for the application"
  type        = string
}

variable "image_repository" {
  description = "Docker image repository (optional, can be set in values file)"
  type        = string
  default     = null
}

resource "helm_release" "simplewebapp-flask" {
  name  = "simplewebapp-flask"
  chart = "${path.root}/../../helm/simplewebapp"

  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    file(var.helm_values_override_file)
  ]

  set {
    name  = "container.image_tag"
    value = var.image_tag
  }

  dynamic "set" {
    for_each = var.image_repository != null ? [1] : []
    content {
      name  = "container.image"
      value = var.image_repository
    }
  }
}
