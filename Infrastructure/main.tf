# Providers Configuration

# Specify the provider to use, which is Google Cloud Platform (GCP)
provider "google" {
  credentials = file("/home/kali/Sharky-Enterprises/Infrastructure/avian-azimuth-436920-q0-e9e6039d8b85.json")
  project     = var.project_id # The GCP project ID where resources will be created.
  region      = var.region     # The region where GCP resources will be deployed.
}

#Configure the Kubernetes provider to interact with the GKE cluster
provider "kubernetes" {
  host                   = google_container_cluster.primary.endpoint
  client_certificate     = base64decode(google_container_cluster.primary.master_auth[0].client_certificate)
  client_key             = base64decode(google_container_cluster.primary.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)

}


# Data source to get the default Google client configuration
# data "google_client_config" "default" {}

# Enable Necessary Google Cloud APIs

# Enable the Kubernetes Engine API for the project
resource "google_project_service" "kubernetes" {
  service = "container.googleapis.com" # Required API for GKE.
  project = var.project_id             # The project ID where the API should be enabled.
}



# Networking Configuration

# Define a VPC network to host the GKE cluster
resource "google_compute_network" "gke_network" {
  name                    = "gke-network" # Name of the VPC network.
  auto_create_subnetworks = false         # Disables automatic creation of subnets to allow for custom configurations.
}

# Define a subnet for the VPC network with secondary IP ranges
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  network       = google_compute_network.gke_network.name
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region

  # Define secondary IP ranges for the subnet
  secondary_ip_range {
    range_name    = "gke-pods"    # Name of the secondary IP range for Pods.
    ip_cidr_range = "10.1.0.0/16" # IP range for the Pods.
  }

  secondary_ip_range {
    range_name    = "gke-services" # Name of the secondary IP range for Services.
    ip_cidr_range = "10.2.0.0/20"  # IP range for the Services.
  }
}
# IAM Configuration

# IAM binding to grant GKE Cluster Admin role to the Terraform service account??????
resource "google_project_iam_binding" "gke_admin" {
  project = var.project_id          # The project ID to apply the IAM role.
  role    = "roles/container.admin" # GKE Cluster Admin role required to manage GKE clusters.

  members = [
    "serviceAccount:${var.service_account_email}" # The service account email to grant the role to.
  ]
}


# Key Management Service (KMS) Configuration

# Create a KMS Key Ring for encryption keys
resource "google_kms_key_ring" "k8s_key_ring" {
  name     = "k8s-keyy-ring"
  location = var.region
}

# Create a KMS Crypto Key for database encryption
resource "google_kms_crypto_key" "k8s_crypto_key" {
  name            = "k8s-crypto-keyy"
  key_ring        = google_kms_key_ring.k8s_key_ring.id
  rotation_period = "100000s" # Optional: Key rotation period

  lifecycle {
    prevent_destroy = true # Prevent accidental deletion
  }

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

# Output the resource ID of the KMS Crypto Key
output "crypto_key_id" {
  description = "The resource ID of the KMS Crypto Key."
  value       = google_kms_crypto_key.k8s_crypto_key.id
}

# GKE Cluster Configuration

# Define the primary GKE cluster
resource "google_container_cluster" "primary" {
  name                     = "primary-gke-cluster" # The name of the GKE cluster.
  location                 = var.region            # The region or zone where the cluster will be deployed.
  initial_node_count       = 1                     # Initial number of nodes; will use a node pool for scaling.
  remove_default_node_pool = true                  # Remove the default node pool to define custom node pools.
  enable_l4_ilb_subsetting = true
  enable_autopilot = true

  # Enable private nodes for security; no public IPs on nodes
  private_cluster_config {
    enable_private_nodes    = true                  # Nodes will not have public IPs.
    master_ipv4_cidr_block  = "172.16.0.0/28"       # CIDR block for GKE control plane.

    # Configure master access settings
    master_global_access_config {
      enabled = true # Allows access to the control plane from outside the VPC.
    }
  }

  # Define auto provisioning defaults (disabled in this case)
  cluster_autoscaling {
    enabled = false

    auto_provisioning_defaults {
      image_type = "COS_CONTAINERD"
    }
  }

  # Encryption Configuration using KMS
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.k8s_crypto_key.id
  }

  # Select the release channel
  release_channel {
    channel = "STABLE"
  }

  # Addons configuration
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false # Enable Horizontal Pod Autoscaling
    }
  }

  # Lifecycle settings
  lifecycle {
    create_before_destroy = true # Recreate resource before destroying
  }





  # Enable logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"    # Send logs to Cloud Logging.
  monitoring_service = "monitoring.googleapis.com/kubernetes" # Send metrics to Cloud Monitoring.

  # Enable network policy
  network_policy {
    provider = "CALICO" # Options: CALICO, CLOUD_FIREWALL
    enabled  = true
  }

  # Enable Binary Authorization for image verification
  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE" # Enforces policies defined at the project level.
  }

 # Define the initial default node configuration
  node_config {
    machine_type = "e2-medium" # Machine type for the nodes in the cluster.

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write", # Scopes for logging.
      "https://www.googleapis.com/auth/monitoring"     # Scopes for monitoring.
    ]

    # Service account for the nodes to use
    #service_account = var.service_account_email # Use a predefined service account for the nodes.

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    kubelet_config {
      cpu_manager_policy                     = "static"
      insecure_kubelet_readonly_port_enabled = "FALSE"

    }

    # Uncomment if you want to enable gVisor
    # sandbox_config {
    #   sandbox_type = "GVISOR"
    # }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00" # To minimize the impact
    }
  }


}

# GKE Node Pool Configuration
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
  }
  management {
    auto_upgrade = true
    auto_repair  = true
  }
  upgrade_settings {
    strategy = "BLUE_GREEN"

    blue_green_settings {
      standard_rollout_policy {
        batch_percentage    = 0.2   # 20% of nodes per batch
        batch_soak_duration = "60s" # 1 minute between batches
      }
      node_pool_soak_duration = "300s" # 5 minutes
    }
  }



  lifecycle {
    create_before_destroy = true
  }

  depends_on = [google_container_cluster.primary]
}
