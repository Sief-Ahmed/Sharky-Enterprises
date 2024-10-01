# resource "kubernetes_pod_security_policy" "restricted_psp" {
#   metadata {
#     name = "restricted-psp"
#   }

#   spec {
#     privileged = false

#     run_as_user {
#       rule = "MustRunAsNonRoot"
#     }

#     allowed_capabilities = []

#     se_linux {
#       rule = "RunAsAny"
#     }

#     volumes = ["configMap", "emptyDir", "secret", "persistentVolumeClaim"]

#     read_only_root_filesystem = true
#   }
# }
