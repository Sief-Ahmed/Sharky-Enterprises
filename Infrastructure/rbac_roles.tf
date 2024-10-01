# resource "kubernetes_role" "frontend_role" {
#   metadata {
#     name      = "frontend-role"
#     namespace = kubernetes_namespace.default
#   }

#   rule {
#     api_groups = [""]
#     resources  = ["pods", "services"]
#     verbs      = ["get", "watch", "list"]
#   }

#   # Add more rules as necessary, ensuring minimal permissions
# }

# resource "kubernetes_role" "backend_role" {
#   metadata {
#     name      = "backend-role"
#     namespace = kubernetes_namespace.default
#   }

#   rule {
#     api_groups = ["apps"]
#     resources  = ["deployments", "replicasets"]
#     verbs      = ["get", "watch", "list"]
#   }

#   # Add more rules as necessary, ensuring minimal permissions
# }

# # resource "kubernetes_role_binding" "frontend_binding" {
# #   metadata {
# #     name      = "frontend-binding"
# #     namespace = kubernetes_namespace.default.metadata[0].name
# #   }

# #   role_ref {
# #     api_group = "rbac.authorization.k8s.io"
# #     kind      = "Role"
# #     name      = kubernetes_role.frontend_role.metadata[0].name
# #   }

# #   subject {
# #     kind      = "ServiceAccount"
# #     name      = kubernetes_service_account.frontend_sa.metadata[0].name
# #     namespace = kubernetes_namespace.default.metadata[0].name
# #   }
# # }

# # resource "kubernetes_role_binding" "backend_binding" {
# #   metadata {
# #     name      = "backend-binding"
# #     namespace = kubernetes_namespace.default.metadata[0].name
# #   }

# #   role_ref {
# #     api_group = "rbac.authorization.k8s.io"
# #     kind      = "Role"
# #     name      = kubernetes_role.backend_role.metadata[0].name
# #   }

# #   subject {
# #     kind      = "ServiceAccount"
# #     name      = kubernetes_service_account.backend_sa.metadata[0].name
# #     namespace = kubernetes_namespace.default.metadata[0].name
# #   }
# # }
