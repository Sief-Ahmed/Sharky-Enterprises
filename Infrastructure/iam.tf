
# resource "google_kms_crypto_key_iam_binding" "gke_encrypter" {
#   crypto_key_id = google_kms_crypto_key.k8s_crypto_key.id
#   role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

#   members = [
#     "serviceAccount:${google_container_cluster.primary.service_account.default.email}"
#   ]
# }

resource "google_service_account" "dev_gke" {
  account_id   = "dev-gke"
  display_name = "dev-gke"
}

