output "public_ip" {
  description = "L'adresse IP publique de votre serveur (A renseigner sur DuckDNS)"
  value       = oci_core_instance.arm_instance.public_ip
}
