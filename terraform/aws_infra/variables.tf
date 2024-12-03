variable "cluster-name" {
  default = "simple-eks-cluster"
  type    = string
}

# Grafana
variable "grafana_release_name" {
  type = string
}

variable "grafana_namespace" {
  type = string
}

variable "grafana_helm_repository" {
  type = string
}

variable "grafana_chart_name" {
  type = string
}

variable "grafana_chart_version" {
  type = string
}

# Prometheus
variable "prometheus_release_name" {
  type = string
}

variable "prometheus_namespace" {
  type = string
}

variable "prometheus_helm_repository" {
  type = string
}

variable "prometheus_chart_name" {
  type = string
}

variable "prometheus_chart_version" {
  type = string
}
