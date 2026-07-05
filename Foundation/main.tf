terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC and Subnet
resource "google_compute_network" "vpc_network" {
  name                    = "calculatrice-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "calculatrice-subnet"
  region        = var.region
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = "10.0.0.0/16"
}

# GKE Autopilot Cluster
# Autopilot gère automatiquement les noeuds et bénéficie d'un tier gratuit pour le control plane.
resource "google_container_cluster" "primary" {
  name     = "calculatrice-cluster"
  location = var.region

  enable_autopilot = true

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Désactivé pour permettre de détruire facilement le cluster pour un projet étudiant
  deletion_protection = false
}

# Artifact Registry pour stocker les images Docker
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "calculatrice-repo"
  description   = "Docker repository pour Calculatrice Native"
  format        = "DOCKER"
}

# ==============================================================================
# KILL-SWITCH / ALERTE BUDGETAIRE
# Permet d'éviter les factures imprévues.
# Ne sera créé que si l'ID du compte de facturation est fourni.
# ==============================================================================
resource "google_pubsub_topic" "billing_alerts" {
  count = var.billing_account_id != "" ? 1 : 0
  name  = "billing-alerts"
}

resource "google_billing_budget" "budget" {
  count           = var.billing_account_id != "" ? 1 : 0
  billing_account = var.billing_account_id
  display_name    = "Calculatrice Kill-Switch Budget (5$)"
  
  amount {
    specified_amount {
      currency_code = "USD"
      units         = "5" # Limite de 5$
    }
  }

  threshold_rules {
    threshold_percent = 1.0 # Alerte à 100% de la limite
  }

  all_updates_rule {
    # Envoie une alerte dans Pub/Sub. (Nécessite une Cloud Function pour désactiver réellement le projet, 
    # mais l'alerte budgétaire est la première étape obligatoire).
    pubsub_topic_name = google_pubsub_topic.billing_alerts[0].id
  }
}
