# RoleBinding for dev-gke  service account
resource "kubernetes_role_binding" "pod-reader-binding_prod" {
  metadata {
    name      = "pod-reader-binding"
    namespace = "production"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "pod_reader"
  }

  subject {
    kind      = "ServiceAccount"
    name      = google_service_account.dev_gke.email
    namespace = "production"
  }
}

resource "kubernetes_role_binding" "pod-reader-binding_dev" {
  metadata {
    name      = "pod-reader-binding"
    namespace = "development"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "pod_reader"
  }

  subject {
    kind      = "ServiceAccount"
    name      = google_service_account.dev_gke.email
    namespace = "development"
  }
}


