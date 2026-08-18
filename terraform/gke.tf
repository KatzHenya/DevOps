# GKE Autopilot Cluster
resource "google_container_cluster" "autopilot" {
  name     = "kanban-cluster"
  location = var.region

  enable_autopilot = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_network.vpc.name

  deletion_protection = false
}
