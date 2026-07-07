terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "project-d24488cc-167d-4a0a-8b2"
  region  = "us-central1"
  zone    = "us-central1-a"
}