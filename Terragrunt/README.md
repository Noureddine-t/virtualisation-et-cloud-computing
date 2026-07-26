# Terragrunt - Environnements Multiples

> [!WARNING]
> **Ce dossier est uniquement à but démonstratif.** 
> Il n'est pas utilisé activement dans le cycle de vie réel de ce projet. Son objectif est de montrer à quoi ressemblerait une architecture Terraform gérée via Terragrunt pour séparer les environnements (Dev, Preprod, Prod) sans dupliquer de code.

## Pourquoi Terragrunt ?
Dans le dossier `Foundation`, nous avons notre code Terraform ("Infrastructure as Code"). Si nous voulions déployer cette même infrastructure sur 3 environnements différents sans dupliquer le fichier `main.tf`, nous utiliserions **Terragrunt**.
Terragrunt garde le code Terraform "DRY" (Don't Repeat Yourself) en référençant le même module racine, mais avec des variables (inputs) et un état (state) différents pour chaque environnement.

## Structure du dossier

```
Terragrunt/
├── terragrunt.hcl        # Configuration racine (héritée par les environnements)
├── dev/
│   └── terragrunt.hcl    # Inputs spécifiques à l'environnement de développement
├── preprod/
│   └── terragrunt.hcl    # Inputs spécifiques à la préproduction
└── prod/
    └── terragrunt.hcl    # Inputs spécifiques à la production
```

## Commandes Utiles

Si vous souhaitiez réellement utiliser cette structure, vous devriez installer l'outil en ligne de commande `terragrunt` et utiliser les commandes suivantes à la place de `terraform` :

**Initialiser et planifier un environnement spécifique (ex: dev) :**
```bash
cd dev
terragrunt init
terragrunt plan
```

**Appliquer les modifications d'un environnement :**
```bash
terragrunt apply
```

**Appliquer tous les environnements d'un seul coup (depuis le dossier racine Terragrunt) :**
```bash
terragrunt run-all plan
terragrunt run-all apply
```
