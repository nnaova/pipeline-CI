# Outputs pour la configuration Terraform

output "instance_public_ip" {
  description = "Adresse IP publique de l'instance Compute Engine"
  value       = google_compute_instance.api_server.network_interface[0].access_config[0].nat_ip
}

output "instance_id" {
  description = "ID de l'instance Compute Engine"
  value       = google_compute_instance.api_server.id
}

output "instance_name" {
  description = "Nom de l'instance Compute Engine"
  value       = google_compute_instance.api_server.name
}

output "instance_zone" {
  description = "Zone de l'instance Compute Engine"
  value       = google_compute_instance.api_server.zone
}

output "ssh_command" {
  description = "Commande SSH pour se connecter à l'instance"
  value       = "ssh -i ${var.ssh_private_key_path} ubuntu@${google_compute_instance.api_server.network_interface[0].access_config[0].nat_ip}"
}
