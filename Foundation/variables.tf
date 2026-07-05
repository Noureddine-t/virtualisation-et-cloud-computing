# Identifiants Oracle Cloud Infrastructure (OCI)
variable "tenancy_ocid" {
  description = "OCID de votre location (Tenancy)"
  type        = string
}

variable "user_ocid" {
  description = "OCID de votre utilisateur"
  type        = string
}

variable "fingerprint" {
  description = "Empreinte de votre clé API"
  type        = string
}

variable "private_key_path" {
  description = "Chemin local vers votre clé privée API (ex: ~/.oci/oci_api_key.pem)"
  type        = string
}

variable "region" {
  description = "Région Oracle (ex: eu-paris-1)"
  type        = string
  default     = "eu-paris-1"
}

variable "compartment_ocid" {
  description = "OCID de votre compartiment"
  type        = string
}

variable "ssh_public_key" {
  description = "Votre clé publique SSH (ex: ssh-rsa AAAAB3N...) pour vous connecter au serveur"
  type        = string
}
