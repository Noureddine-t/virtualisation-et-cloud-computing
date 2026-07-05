variable "project_id" {
  type        = string
  description = "L'ID du projet Google Cloud (GCP)"
  default     = "Calculatrice Cloud Native"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

variable "region" {
  type    = string
  default = "europe-west1" # Belgique (Faible latence et écologique)
}

variable "billing_account_id" {
  type        = string
  description = "L'ID du compte de facturation GCP (ex: 012345-6789AB-CDEF01) pour activer le Kill-Switch"
  default     = "" 
}

variable "student" {
  type    = string
  default = "taleb"
}
