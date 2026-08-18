# Cloud Run Service — Frontend (Nginx + HTML)
resource "google_cloud_run_v2_service" "frontend" {
  name     = "kanban-frontend"
  location = var.region

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repo_name}/kanban-frontend:latest"

      env {
        name  = "BACKEND_URL"
        value = var.backend_url
      }

      ports {
        container_port = 80
      }
    }

    # חיבור ל-VPC כדי לדבר עם GKE
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress    = "PRIVATE_RANGES_ONLY"
    }
  }

  depends_on = [google_vpc_access_connector.connector]
}

# מאפשר גישה ציבורית ל-Frontend
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = var.region
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
