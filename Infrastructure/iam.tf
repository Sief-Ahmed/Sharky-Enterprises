# data "google_project" "project" {
#   project_id = var.project_id
# }

# data "google_service_account" "gke_service_agent" {
# account_id = "service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
# }

# resource "google_kms_crypto_key_iam_binding" "gke_encrypter" {
#   crypto_key_id = google_kms_crypto_key.k8s_crypto_key.id
#   role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

#   members = [
#     "serviceAccount:${var.service_account_email}"
#   ]
# }

