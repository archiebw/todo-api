resource "google_compute_network" "default" {
  project                 = var.project_id
  name                    = "gke-vpc-${var.environment}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "default" {
  project       = var.project_id
  name          = "gke-subnet-${var.environment}"
  region        = var.primary_region
  network       = google_compute_network.default.id
  ip_cidr_range = "10.0.0.0/16"

  secondary_ip_range {
    range_name    = var.ip_range_pods_name
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = var.ip_range_services_name
    ip_cidr_range = "10.2.0.0/20"
  }
}

module "gke" {
  depends_on = [google_project_service.compute, google_project_service.container]
  source     = "terraform-google-modules/kubernetes-engine/google"
  version    = "~> 36.0"

  project_id               = var.project_id
  name                     = "${var.project_id}-gke-${var.environment}"
  regional                 = true
  region                   = var.primary_region
  network                  = google_compute_network.default.name
  subnetwork               = google_compute_subnetwork.default.name
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  create_service_account   = true
  deletion_protection      = false
  remove_default_node_pool = true
  node_metadata            = "GKE_METADATA"

  node_pools = [
    {
      name         = "wi-pool"
      min_count    = 1
      max_count    = 2
      auto_upgrade = true
    }
  ]
}

resource "google_artifact_registry_repository" "default" {
  project       = var.project_id
  location      = var.primary_region
  repository_id = "${var.project_id}-repo-${var.environment}"
  description   = "docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

resource "kubernetes_namespace" "todo" {
  metadata {
    annotations = {
      name = "todo"
    }
    name = "todo"
  }
}

module "todo_workload_identity" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "~> 36.0"

  name       = "id-${module.gke.name}"
  namespace  = kubernetes_namespace.todo.metadata[0].name
  project_id = var.project_id
  roles      = ["roles/datastore.user"]
}
