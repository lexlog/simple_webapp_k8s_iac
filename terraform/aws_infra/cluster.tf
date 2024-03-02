resource "helm_release" "metrics_server" {
  depends_on = [ aws_eks_node_group.eks_node_group ]
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.12.2"
}

