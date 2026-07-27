# Helm
[![helm](https://img.shields.io/badge/helm-0F1689.svg?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh/docs/)
[![k8s](https://img.shields.io/badge/kubernetes-326CE5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/docs/home/)
[![GitHub Actions](https://img.shields.io/badge/GITHUB_ACTIONS-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://docs.github.com/en/actions)
[![OCI](https://img.shields.io/badge/oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://registry.terraform.io/providers/oracle/oci/latest/docs)

## Sommaire

- [Schema récapitulatif (services et replicasets)](#schema-récapitulatif-services-et-replicasets)
- [Fonctionnement](#fonctionnement)
    - [Etape 1 : Demande de calcul](#etape-1--demande-de-calcul)
    - [Etape 2 : Récupération du résultat du calcul](#etape-2--récupération-du-résultat-du-calcul)
- [Automatisation du déploiement (CI / GitOps)](#automatisation-du-déploiement-ci--gitops)
- [Commandes utiles](#commandes-utiles)
- [Voir aussi](#voir-aussi)

## Schema récapitulatif (services et replicasets)

```mermaid
graph LR
    
    subgraph "Kubernetes"
        subgraph "Release Helm: front"
            pod-front
            svc-front([svc-front]) --> pod-front
            ing(Ingress Traefik <br> + Cert-Manager TLS) -->|"<domaine>.duckdns.org/"| svc-front
        end
        
        subgraph "Release Helm: api"
            pod-api
            svc-api([svc-api]) --> pod-api
            ing_api(Ingress Traefik) -->|"<domaine>.duckdns.org/api"| svc-api
        end
        
        subgraph "Release Helm: redis"
            pod-redis[("Redis <br> pod")]
            svc-redis([svc-redis]) --> pod-redis
        end
        
        subgraph "Release Helm: rabbitmq"
            pod-rabbitmq[\" RabbitMQ <br> pod"/]
            svc-rabbitmq([svc-rabbitmq]) --> pod-rabbitmq
        end
        
        subgraph "Release Helm: consumer"
            pod-consumer
        end
        
        pod-consumer -.-> svc-rabbitmq
        pod-consumer -.-> svc-redis
        pod-api -.-> svc-redis
        pod-api -.-> svc-rabbitmq
        
        CertManager["Cert-Manager <br> (Let's Encrypt)"] -.->|"Génère et injecte le certificat TLS"| ing
        CertManager -.->|"Génère et injecte le certificat TLS"| ing_api
    end
```
## Fonctionnement
### Etape 1 : Demande de calcul

```mermaid
graph LR
    user([Utilisateur]) -->|choisit une opération <br> et saisit deux nombres| F[Frontend]
    F -->|"HTTP POST /api/calculate"| A[API]
    A -->|"{id, calcul à faire}"| Q[\ RabbitMQ /]
    A -.->|HTTP 200 OK <br> id| F
    C[Consumer] -->|"récupére le dernier message"| Q[\ RabbitMQ /]
    C -->|"redis.set(id, resultat du calcul)"| R[(Redis DB)]
```

### Etape 2 : Récupération du résultat du calcul

```mermaid
graph LR
    user([Utilisateur]) -->|saisit id du calcul à récupérer| F[Frontend]
    F -->|"HTTP GET /api/result/{id}"| A[API]
    A -->|"redis.get(id)"| R[(Redis DB)]
    R -.->|"résultat ou null"| A
    A -.->|HTTP 200 + Résultat| F
    A -.->|HTTP 404 Not Found| F
    F -.->|Affiche le résultat ou l'erreur| user
```

## Automatisation du déploiement (CI / GitOps)

> [!NOTE]
> Le cycle de vie de l'application est automatisé via GitHub Actions (fichier [`.github/workflows/app.yaml`](../.github/workflows/app.yaml)).

Dans notre architecture, nous utilisons l'approche **GitOps** avec ArgoCD. Cela signifie que le pipeline CI/CD n'exécute **pas** directement de commande sur le cluster (pas de `helm upgrade`). Son rôle s'arrête à la mise à jour du dépôt Git (la source de vérité).

Voici le déroulement complet du pipeline applicatif :

```mermaid
sequenceDiagram
    actor Dev as Développeur
    participant GitHub as GitHub Actions
    participant Registry as GitHub Container Registry (ghcr.io)
    participant Git as Dépôt Git (Branche main)
    participant ArgoCD as ArgoCD (Cluster)

    Dev->>Git: 1. Push du code (Application/*)
    note over GitHub: Trigger: Workflow app.yaml
    GitHub->>Registry: 2. Build & Push des images Docker (Front, API, Consumer)
    GitHub->>GitHub: 3. Modifie Helm/front/values.yaml, api/values.yaml, etc. avec yq
    GitHub->>Git: 4. Commit et Push du nouveau Tag (github.sha)
    Git-->>ArgoCD: 5. ArgoCD détecte les modifications
    ArgoCD->>ArgoCD: 6. Synchronise le cluster avec les nouvelles images
```

Le fait d'avoir des charts Helm simplifie considérablement la tâche du pipeline : au lieu de devoir modifier des tags dans plusieurs fichiers YAML disparates, le pipeline utilise simplement l'utilitaire `yq` pour mettre à jour la valeur `image.tag` de chaque chart concerné, puis fait un `git commit`. L'orchestration du déploiement est ensuite déléguée à ArgoCD (App of Apps).

## Commandes utiles

Toutes les anciennes commandes `kubectl apply -f` ont été remplacées par la gestion centralisée de Helm et ArgoCD.
En production, il n'est plus nécessaire d'utiliser la commande `helm` manuellement, car ArgoCD gère le cycle de vie de toutes les releases via le pattern **App of Apps**.

Cependant, en développement local, voici quelques commandes utiles :

#### Installation et Mise à jour d'un Chart

Pour installer ou mettre à jour un microservice individuel (ex: `front`) :
```shell
helm upgrade --install front ./front --namespace <namespace> --create-namespace
```

#### Vérification du déploiement

Lister les déploiements Helm actifs :
```shell
helm list -n <namespace>
```

Voir l'historique des versions déployées (utile pour le CI/CD) :
```shell
helm history front -n <namespace>
```

#### Debugging & Rollback

Pour simuler un déploiement et voir les fichiers YAML finaux qui seront générés (sans rien modifier sur le cluster) :
```shell
helm upgrade --install front ./front --dry-run --debug -n <namespace>
```

Pour revenir à une version précédente (par exemple la révision 1) :
```shell
helm rollback front 1 -n <namespace>
```

#### Désinstallation

Pour supprimer entièrement une application et toutes ses ressources associées (pods, services, ingress) :
```shell
helm uninstall front -n <namespace>
```

## Voir aussi
- [`Foundation/`](../Foundation) : Terraform (provisionnement de l'infrastructure).
- [`Application/`](../Application) : Fichiers de l'application web (front-end, back-end, consumer), Dockerfiles associés et docker-compose.
- [`ArgoCD/`](../ArgoCD) : Configuration ArgoCD pour la synchronisation du cluster (déploiement continu).
- [`.github/workflows/`](../.github/workflows) : Fichier GitHub Actions pour automatiser le provisionnement de l'infrastructure et le déploiement de l'application.
- [`Kubernetes/`](../Kubernetes) : Manifests Kubernetes bruts (historique).
- [`Terragrunt/`](../Terragrunt) : Configuration Terragrunt pour gérer plusieurs environnements (Dev, Preprod, Prod).
- [`Sujet.md`](../Sujet.md) ou [source](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/projet.md).
- [🏠 Retourner à la racine du projet](../README.md)


- [🔼 Back to Top](#helm)