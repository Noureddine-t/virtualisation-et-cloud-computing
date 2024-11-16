/* Configurer Terraform pour GCP */
provider "google" {
  project = var.projectId
  region  = var.regionId
}

/* Ajouter le réseau VPC */
resource "google_compute_network" "vpc_network" {
    name         = "my-vpc"
}

/* Créer une instance VM */
resource "google_compute_instance" "tf-instance-1" {
  count = 2
  name = "tf-instance-${count.index + 1}"
  machine_type = "n1-standard-2"
  zone = "europe-west9"
   boot_disk {
      initialize_params {
        image = "debian-cloud/debian-11"
      }
   }
    network_interface {
      network = google_compute_network.vpc_network.id
    }
}

/* Ajouter une base de données SQL */
resource "google_sql_database_instance" "main" {
  name             = "my-database-instance"
  region           = "europe-west9"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }
}

/* Ajouter un enregistrement DNS */
resource "google_dns_record_set" "a" {
  name         = "esirem.polytech.com."
  managed_zone = "example.com"
  type         = "A"
  rrdatas = ["8.8.8.8"]
}


