# Fichier de configuration racine Terragrunt
# Tous les environnements enfants (dev, preprod, prod) hériteront de cette configuration.

terraform {
  source = "..//Foundation"

  # INJECTION DES SECRETS
  # Terragrunt va automatiquement passer ce fichier de variables ignoré par Git à Terraform
  extra_arguments "secrets" {
    commands = get_terraform_commands_that_need_vars()
    required_var_files = [
      "${get_parent_terragrunt_dir()}/secrets.tfvars"
    ]
  }
}

# Inputs globaux partagés par TOUS les environnements (uniquement les variables non-sensibles)
inputs = {
  region           = "eu-paris-1"
  
  # Utilisation d'une fonction Terragrunt pour garantir que le chemin vers la clé privée est absolu peu importe le dossier d'exécution
  private_key_path = "${get_parent_terragrunt_dir()}/../oracle_OCI.pem"
}
