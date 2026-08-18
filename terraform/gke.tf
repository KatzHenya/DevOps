# GKE Autopilot Cluster
resource "google_container_cluster" "autopilot" {
  name     = "kanban-cluster"
  location = var.region

  # Autopilot mode — GCP מנהל את ה-nodes אוטומטית
  enable_autopilot = true

  network    = google_compute_network.vpc.name
  subnetwork = "projects/${var.project_id}/regions/${var.region}/subnetworks/${var.region}"

  # מאפשר גישה פרטית ל-cluster
  private_cluster_config {
    enable_private_nodes    = false
    enable_private_endpoint = false
  }

  deletion_protection = false
}
