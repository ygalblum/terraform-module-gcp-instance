# VPC
resource "google_compute_network" "this" {
  name = "${var.name}-vpc"
  delete_default_routes_on_create = false
  auto_create_subnetworks = false
  routing_mode = "REGIONAL"
}

# SUBNET
resource "google_compute_subnetwork" "this" {
  name = "${var.name}-subnetwork"
  ip_cidr_range = var.ip_cidr_range
  region = var.gcp_region
  network = google_compute_network.this.id
  private_ip_google_access = true
}

# Allow SSH access from provisioning machine
resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-ssh"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = [ var.ssh_port ]
  }

  source_ranges = [ local.myip_cidr ]
  target_tags = [ "${var.name}-ssh" ]
}

# Allow access to the application port
resource "google_compute_firewall" "application-port" {
  count = length(var.application_ports) == 0 ? 0 : 1

  name    = "${var.name}-application-ports"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = var.application_ports
  }

  source_ranges = [ var.limit_additionl_ports ? local.myip_cidr : "0.0.0.0/0" ]
  target_tags = [ "${var.name}-application-ports" ]
}
