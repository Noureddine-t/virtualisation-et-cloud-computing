/* Output pour le VPC */
output "vpc_id" {
  description = "ID du VPC principal"
  value       = aws_vpc.main_vpc.id
}

/* Output pour les instances EC2 */
output "instance_public_ips" {
  description = "IP publiques des instances EC2"
  value       = [for instance in aws_instance.web_server : instance.public_ip]
}

/* Output pour l'instance de base de données RDS */
output "db_endpoint" {
  description = "Endpoint de la base de données RDS"
  value       = aws_db_instance.mydb.address
}

/* Output pour l'enregistrement DNS */
output "dns_record" {
  description = "Nom d'hôte DNS"
  value       = aws_route53_record.dns_record.fqdn
}
