# BackendConfig Resource
# resource "kubernetes_manifest" "backend_config" {
#   manifest = {
#     "apiVersion" = "cloud.google.com/v1"
#     "kind"       = "BackendConfig"
#     "metadata" = {
#       "name" = "backend-config"
#     }
#     "spec" = {
#       "healthCheck" = {
#         "checkIntervalSec"   = 30
#         "timeoutSec"         = 10
#         "healthyThreshold"   = 1
#         "unhealthyThreshold" = 3
#         "requestPath"        = "/quote"
#       }
#     }
#   }
# }

# Service for app1 (service-a)
resource "kubernetes_service" "service_a" {
  metadata {
    name = "service-a"


  }

  spec {
    selector = {
      app = "app1"
    }

    port {
      protocol    = "TCP"
      port        = 5000
      target_port = 5000
    }

    type             = "LoadBalancer"
    load_balancer_ip = "146.148.50.139"
  }

}

# Service for app2 (service-b)
resource "kubernetes_service" "service_b" {
  metadata {
    name = "service-b"


  }

  spec {
    selector = {
      app = "app2"
    }

    port {
      protocol    = "TCP"
      port        = 8000
      target_port = 8000
    }

    type             = "LoadBalancer"
    load_balancer_ip = "35.226.62.63"
  }

}