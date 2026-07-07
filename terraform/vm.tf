resource "google_compute_instance" "vm" {
  name         = "kanban-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc.id

    access_config {}
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
apt update
apt install -y docker.io
systemctl enable docker
systemctl start docker

mkdir -p /app/database
EOF
}