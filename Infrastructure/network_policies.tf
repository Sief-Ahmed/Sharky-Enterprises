# NetworkPolicy for service-a, only allows traffic from pods that are not service-b
resource "kubernetes_network_policy" "service_a_policy" {
  metadata {
    name      = "service-a-policy"
    namespace = "default"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "service-a"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_expressions {
            key      = "app"
            operator = "NotIn"
            values   = ["service-b"]
          }
        }
      }
    }

    egress {
      to {
        pod_selector {
          match_expressions {
            key      = "app"
            operator = "NotIn"
            values   = ["service-b"]
          }
        }
      }
    }
  }
}

# NetworkPolicy for service-b, only allows traffic from pods that are not service-a
resource "kubernetes_network_policy" "service_b_policy" {
  metadata {
    name      = "service-b-policy"
    namespace = "default"
  }

  spec {
    pod_selector {
      match_labels = {
        app = "service-b"
      }
    }

    policy_types = ["Ingress", "Egress"]

    ingress {
      from {
        pod_selector {
          match_expressions {
            key      = "app"
            operator = "NotIn"
            values   = ["service-a"]
          }
        }
      }
    }

    egress {
      to {
        pod_selector {
          match_expressions {
            key      = "app"
            operator = "NotIn"
            values   = ["service-a"]
          }
        }
      }
    }
  }
}
