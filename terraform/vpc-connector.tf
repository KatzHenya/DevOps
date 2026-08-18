# VPC Connector — מחבר Cloud Run ל-GKE דרך רשת פנימית
resource "google_vpc_access_connector" "connector" {
  name          = "kanban-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.8.0.0/28"

  depends_on = [google_compute_network.vpc]
}
