resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.monitoring]

  name       = var.prometheus_release_name
  namespace  = var.prometheus_namespace
  repository = var.prometheus_helm_repository
  chart      = var.prometheus_chart_name
  version    = var.prometheus_chart_version

  values = [jsonencode({
    alertmanager = {
      persistentVolume = {
        enabled          = true
        storageClass     = "gp2"
        size             = "10Gi"
        accessModes      = ["ReadWriteOnce"]
      }
    }
    server = {
      persistentVolume = {
        enabled          = true
        storageClass     = "gp2"
        size             = "10Gi"
        accessModes      = ["ReadWriteOnce"]
      }
      service = {
        type = "ClusterIP"
        port = 9090
      }
    }
  })]
}

resource "helm_release" "grafana" {
  depends_on = [helm_release.prometheus]

  name       = var.grafana_release_name
  namespace  = var.grafana_namespace
  repository = var.grafana_helm_repository
  chart      = var.grafana_chart_name
  version    = var.grafana_chart_version

  values = [jsonencode({
    persistence = {
      enabled = false
    }
    adminPassword = "admin123"
    service = {
      type = "LoadBalancer"
      port = 80
    }
    datasources = {
      "prometheus.yaml" = {
        apiVersion = 1
        datasources = [
          {
            name      = "Prometheus"
            type      = "prometheus"
            access    = "proxy"
            url       = "http://prometheus-server.monitoring.svc.cluster.local:9090"
            isDefault = true
          }
        ]
      }
    }
  })]
}

resource "kubernetes_persistent_volume_claim" "alertmanager" {
  metadata {
    name      = "storage-prometheus-alertmanager-0"
    namespace = var.prometheus_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "gp2"
  }
}

output "grafana_status" {
  value = helm_release.grafana.status
}
