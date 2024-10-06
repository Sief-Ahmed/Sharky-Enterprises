# resource "kubernetes_network_policy" "allow_app_ingress" {
#   metadata {
#     name      = "allow-app-ingress"
#     namespace = kubernetes_namespace.default.metadata[0].name
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         app = "frontend"
#       }
#     }

#     ingress {
#       from {
#         pod_selector {
#           match_labels = {
#             app = "backend"
#           }
#         }
#       }

#       ports {
#         protocol = "TCP"
#         port     = 80
#       }
#     }

#     policy_types = ["Ingress"]
#   }
# }

# resource "kubernetes_network_policy" "deny_all_other_ingress" {
#   metadata {
#     name      = "deny-all-other-ingress"
#     namespace = kubernetes_namespace.default.metadata[0].name
#   }

#   spec {
#     pod_selector {}

#     policy_types = ["Ingress"]
#   }
# }
