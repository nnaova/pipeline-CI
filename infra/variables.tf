# Variables pour la configuration Terraform

variable "gcp_project_id" {
  description = "ID du projet Google Cloud"
  type        = string
  default     = "sensors-api-project"  # Remplacer par votre ID de projet GCP
}

variable "gcp_region" {
  description = "Région Google Cloud à utiliser"
  type        = string
  default     = "europe-west1"  # Europe (Belgique)
}

variable "gcp_zone" {
  description = "Zone Google Cloud à utiliser"
  type        = string
  default     = "europe-west1-b"  # Europe (Belgique), zone b
}

variable "machine_type" {
  description = "Type de machine Compute Engine"
  type        = string
  default     = "e2-micro"  # Instance économique pour le développement
}

variable "disk_image" {
  description = "Image du disque à utiliser"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"  # Ubuntu 22.04 LTS
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH à utiliser pour l'accès à l'instance"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Chemin vers la clé privée SSH à utiliser pour l'accès à l'instance"
  type        = string
  default     = "~/.ssh/id_rsa"
}
