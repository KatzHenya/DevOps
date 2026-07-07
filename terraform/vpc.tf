resource "google_compute_network" "vpc" {
  name                    = "kanban-vpc"
  auto_create_subnetworks = true
}