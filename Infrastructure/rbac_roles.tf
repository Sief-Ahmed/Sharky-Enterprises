resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod_reader"
    namespace = "kubernetes_namespace.production"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list"]
  }
}
