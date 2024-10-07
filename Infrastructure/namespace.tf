
resource "kubernetes_namespace" "development" {
  metadata {
    name = "dev"

    labels = {
      "pod-security.kubernetes.io/enforce"         = "baseline"
      "pod-security.kubernetes.io/audit"           = "baseline"
      "pod-security.kubernetes.io/warn"            = "baseline"
      "pod-security.kubernetes.io/enforce-version" = "latest"
    }
  }
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"

    labels = {
      "pod-security.kubernetes.io/enforce"         = "restricted"
      "pod-security.kubernetes.io/audit"           = "restricted"
      "pod-security.kubernetes.io/warn"            = "restricted"
      "pod-security.kubernetes.io/enforce-version" = "latest"
    }
  }
}
