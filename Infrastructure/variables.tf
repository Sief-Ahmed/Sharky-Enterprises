# Define the variables used in the Terraform configurations
variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
  default     = "avian-azimuth-436920-q0"
}

variable "region" {
  description = "The region where the GKE cluster and other resources will be deployed."
  type        = string
  default     = "us-central1" # Default region set to us-central1.
}


