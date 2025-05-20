# Configuration du fournisseur Google Cloud
provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  zone        = var.gcp_zone
}

# Création d'un réseau VPC pour l'instance
resource "google_compute_network" "vpc_network" {
  name                    = "sensors-api-network"
  auto_create_subnetworks = "true"
}

# Création d'une règle de pare-feu pour autoriser le trafic SSH
resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

# Création d'une règle de pare-feu pour autoriser le trafic API
resource "google_compute_firewall" "api" {
  name    = "allow-api"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["api"]
}

# Création d'une instance Compute Engine
resource "google_compute_instance" "api_server" {
  name         = "sensors-api-server"
  machine_type = var.machine_type
  tags         = ["ssh", "api"]

  boot_disk {
    initialize_params {
      image = var.disk_image
      size  = 10
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  # Script de démarrage pour mettre à jour l'instance
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get upgrade -y
  EOF

  # Connexion directe pour tester l'accès SSH
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
    
    inline = ["echo 'SSH connection established'"]
  }
}

# Utiliser le provider local pour générer des fichiers
provider "local" {}

# Générer l'inventaire Ansible à partir des informations de l'instance
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tmpl",
    {
      api_server_ip = google_compute_instance.api_server.network_interface[0].access_config[0].nat_ip
    }
  )
  filename = "${path.module}/../ansible/inventory.ini"

  depends_on = [google_compute_instance.api_server]
}
