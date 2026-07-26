# Terragrunt
[![terragrunt](https://img.shields.io/badge/terragrunt-5C4EE5?style=for-the-badge&logo=terraform&logoColor=white)](https://terragrunt.gruntwork.io/)
[![terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://developer.hashicorp.com/terraform/docs)
[![OCI](https://img.shields.io/badge/oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://registry.terraform.io/providers/oracle/oci/latest/docs)
[![GitHub Actions](https://img.shields.io/badge/GITHUB_ACTIONS-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://docs.github.com/en/actions)

> [!WARNING]
> **Ce dossier est uniquement à but démonstratif.** 
> Il n'est pas utilisé activement dans le cycle de vie réel de ce projet. Son objectif est de montrer à quoi ressemblerait une architecture Terraform gérée via Terragrunt pour séparer les environnements (Dev, Preprod, Prod) sans dupliquer de code.

## Sommaire
- [Pourquoi Terragrunt ?](#pourquoi-terragrunt-)
- [Structure du dossier](#structure-du-dossier)
- [Commandes Utiles](#commandes-utiles)
- [Voir aussi](#voir-aussi)

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

Pour utiliser réellement cette structure, il est nécessaire d'installer l'outil en ligne de commande `terragrunt` et d'utiliser les commandes suivantes à la place de `terraform` :

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

## Voir aussi
- [`Foundation/`](../Foundation) : Terraform (provisionnement de l'infrastructure).
- [`Application/`](../Application) : Fichiers de l'application web (front-end, back-end, consumer), Dockerfiles associés et docker-compose.
- [`Helm/`](../Helm) : Le chart Helm qui est surveillé et déployé par ArgoCD.
- [`GitOps/`](../GitOps) : Configuration ArgoCD pour la synchronisation du cluster (déploiement continu).
- [`.github/workflows/`](../.github/workflows) : Fichier GitHub Actions pour automatiser le provisionnement de l'infrastructure et le déploiement de l'application.
- [`Kubernetes/`](../Kubernetes) : Manifests Kubernetes bruts (historique).
- [`Sujet.md`](../Sujet.md) ou [source](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/projet.md).
- [🏠 Retourner à la racine du projet](../README.md)


- [🔼 Back to Top](#terragrunt)