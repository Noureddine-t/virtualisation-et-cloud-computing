/* Nom de chaque instance VM */
output "instance_names" {
  description = "Nom des instances VM créées"
  value       = [for instance in google_compute_instance.tf-instance-1 : instance.name]
}

/* Nom de l'instance de base de données SQL */
output "database_instance_name" {
  description = "Nom de l'instance de base de données SQL"
  value       = google_sql_database_instance.main.name
}

/* Nom de l'enregistrement DNS */
output "dns_record_name" {
  description = "Nom complet de l'enregistrement DNS"
  value       = google_dns_record_set.a.name
}

/* Nom du VPC */
output "vpc_name" {
  description = "Nom du réseau VPC"
  value       = google_compute_network.vpc_network.name
}
