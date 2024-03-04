data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "google_compute_zones" "available" {
}

locals {
  instance_network_tags = concat(
    ["${var.name}-ssh"],
    var.application_port == 0 ? [] : ["${var.name}-application-port"]
  )
  myip_cidr = "${chomp(data.http.myip.response_body)}/32"
  zone = data.google_compute_zones.available.names[0]
}

data "google_compute_image" "boot_image" {
  project = "centos-cloud"
  family  = "centos-stream-9"
  most_recent = true
}

resource "google_compute_instance" "this" {
  boot_disk {
    auto_delete = true
    device_name = "${var.name}"

    initialize_params {
      image = data.google_compute_image.boot_image.id
      size  = var.boot_image_size
      type  = "pd-ssd"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  guest_accelerator {
    count = 1
    type  = "projects/${var.gcp_project}/zones/${local.zone}/acceleratorTypes/${var.accelerator_type}"
  }

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = var.machine_type

  metadata = {
    ssh-keys = var.ssh_public_key
  }

  name = "${var.name}"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = google_compute_subnetwork.this.id
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "TERMINATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email = var.service_account
    scopes = concat(["https://www.googleapis.com/auth/cloud-platform"], var.additional_scopes)
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = tolist(local.instance_network_tags)
  zone = local.zone
}
