resource "google_compute_network" "vpc" {
  name                    = "${var.project_id}-${var.environment}-${var.region}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.project_id}-${var.environment}-${var.region}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_id}-${var.environment}-internal-fw"
  network = google_compute_network.vpc.name

  direction     = "INGRESS"
  source_ranges = [var.subnet_cidr]

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  target_tags = ["internal"]
}

