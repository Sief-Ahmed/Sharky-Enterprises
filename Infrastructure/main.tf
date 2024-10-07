# Providers Configuration

# Specify the provider to use, which is Google Cloud Platform (GCP)
provider "google" {
  credentials = file("avian-azimuth-436920-q0-199d2a839fab.json")
  project     = var.project_id # The GCP project ID where resources will be created.
  region      = var.region     # The region where GCP resources will be deployed.
}
provider "google-beta" {
  credentials = file("avian-azimuth-436920-q0-199d2a839fab.json")
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

provider "kubectl" {
  host                   = google_container_cluster.primary.endpoint
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  token                  = data.google_container_cluster.primary.token
  load_config_file       = false
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


}
# IAM Configuration

# # IAM binding to grant GKE Cluster Admin role to the Terraform service account
# resource "google_project_iam_binding" "gke_admin" {
#   project = var.project_id          # The project ID to apply the IAM role.
#   role    = "roles/container.admin" # GKE Cluster Admin role required to manage GKE clusters.

#   members = [
#     "serviceAccount:${var.service_account_email}" # The service account email to grant the role to.
#   ]
# }


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
  provider                 = google-beta
  name                     = "primary-gke-cluster" # The name of the GKE cluster.
  location                 = var.region            # The region or zone where the cluster will be deployed.
  initial_node_count       = 2                     # Initial number of nodes; will use a node pool for scaling.
  remove_default_node_pool = true                  # Remove the default node pool to define custom node pools.
  enable_l4_ilb_subsetting = true



  # Enable private nodes for security; no public IPs on nodes
  private_cluster_config {
    enable_private_nodes   = true            # Nodes will not have public IPs.
    master_ipv4_cidr_block = "172.16.0.0/28" # CIDR block for GKE control plane.

    # Configure master access settings
    master_global_access_config {
      enabled = false # Allows access to the control plane from outside the VPC.
    }
  }
  cluster_ipv4_cidr = "10.80.0.0/14"
  default_snat_status {
    disabled = false
  }


  protect_config {
    workload_config {
      audit_mode = "BASIC"
    }

    workload_vulnerability_mode = "BASIC"
  }
  # Define auto provisioning defaults (disabled in this case)
  cluster_autoscaling {
    autoscaling_profile = "BALANCED"



    auto_provisioning_defaults {
      image_type = "COS_CONTAINERD"
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
    }



  }
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  # Encryption Configuration using KMS
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.k8s_crypto_key.id
  }
  default_max_pods_per_node = 4

  # Select the release channel
  release_channel {
    channel = "STABLE"
  }
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }
  # Addons configuration
  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }

    gke_backup_agent_config {
      enabled = true
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }

  }
  pod_security_policy_config {
    enabled = true
  }
  # Lifecycle settings
  lifecycle {
    create_before_destroy = true # Recreate resource before destroying
  }





  # Enable logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"    # Send logs to Cloud Logging.
  monitoring_service = "monitoring.googleapis.com/kubernetes" # Send metrics to Cloud Monitoring.

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
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


    kubelet_config {
      cpu_manager_policy                     = "static"
      insecure_kubelet_readonly_port_enabled = "FALSE"

    }

    # Uncomment if you want to enable gVisor
    # sandbox_config {
    #   sandbox_type = "GVISOR"
    # }
  }
  enable_shielded_nodes = true

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
    preemptible     = true
    machine_type    = "e2-medium"
    disk_size_gb    = 100
    disk_type       = "pd-balanced"
    image_type      = "COS_CONTAINERD"
    logging_variant = "DEFAULT"
    metadata = {
      disable-legacy-endpoints = "true"
    }


    oauth_scopes    = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
    service_account = "default"

    shielded_instance_config {
      enable_integrity_monitoring = true

    }


  }



  lifecycle {
    create_before_destroy = true
  }

  depends_on = [google_container_cluster.primary]
}

