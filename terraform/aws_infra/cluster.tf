resource "helm_release" "metrics_server" {
  depends_on = [ aws_eks_node_group.eks_node_group ]
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.12.2"
}
module "monitoring" {
  source          = "../modules/monitoring"
  grafana_release_name    = "grafana"
  grafana_namespace       = "monitoring"
  grafana_helm_repository = "https://grafana.github.io/helm-charts"
  grafana_chart_name      = "grafana"
  grafana_chart_version   = "8.6.4"

  prometheus_release_name    = "prometheus"
  prometheus_namespace       = "monitoring"
  prometheus_helm_repository = "https://prometheus-community.github.io/helm-charts"
  prometheus_chart_name      = "prometheus"
  prometheus_chart_version   = "26.0.0"
  
}

