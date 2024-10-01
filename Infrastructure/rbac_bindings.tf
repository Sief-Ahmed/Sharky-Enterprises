# # RoleBinding for frontend service account
# resource "kubernetes_role_binding" "frontend_binding" {
#   metadata {
#     name      = "frontend-binding"
#     namespace = "default"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = kubernetes_role.frontend_role.metadata[0].name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.frontend_sa.metadata[0].name
#     namespace = "default"
#   }
# }

# # RoleBinding for backend service account
# resource "kubernetes_role_binding" "backend_binding" {
#   metadata {
#     name      = "backend-binding"
#     namespace = "default"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = kubernetes_role.backend_role.metadata[0].name
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account.backend_sa.metadata[0].name
#     namespace = "default"
#   }
# }
