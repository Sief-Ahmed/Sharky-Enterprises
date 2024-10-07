resource "kubernetes_deployment" "app1_deployment" {
  metadata {
    name = "app1-deployment"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app1"
      }
    }

    template {
      metadata {
        labels = {
          app = "app1"
        }
      }

      spec {
        container {
          name  = "app1-container"
          image = "us-west2-docker.pkg.dev/avian-azimuth-436920-q0/sharky-enterprises/app1:latest"

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "app2_deployment" {
  metadata {
    name = "app2-deployment"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app2"
      }
    }

    template {
      metadata {
        labels = {
          app = "app2"
        }
      }

      spec {
        container {
          name  = "app2-container"
          image = "us-west2-docker.pkg.dev/avian-azimuth-436920-q0/sharky-enterprises/app2:latest"

          port {
            container_port = 8000
          }
        }
      }
    }
  }
}
