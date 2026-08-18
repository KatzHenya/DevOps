variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "repo_name" {
  default = "kanban-repo"
}

# URL של ה-Backend ב-GKE — יתעדכן אחרי הפריסה
variable "backend_url" {
  default = "http://kanban-backend.default.svc.cluster.local:5000"
}