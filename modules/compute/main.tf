resource "google_compute_instance" "vm" {
  name         = "${var.project_id}-${var.environment}-${var.region}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    access_config {}
  }

  tags   = ["internal"]
  labels = var.labels
}
