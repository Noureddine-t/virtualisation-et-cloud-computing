# Application
[![docker](https://img.shields.io/badge/DOCKER-blue?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/)
[![HTML](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/fr/docs/Web/HTML)
[![CSS](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)](https://developer.mozilla.org/fr/docs/Web/CSS)
[![JS](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/fr/docs/Web/JavaScript)
[![flask](https://img.shields.io/badge/FLASK-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![redis](https://img.shields.io/badge/REDIS-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![LapinMQ](https://img.shields.io/badge/rabbitmq-%23FF6600.svg?&style=for-the-badge&logo=rabbitmq&logoColor=white)](https://rabbitmq.com/)
[![nginx](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![GitHub Actions](https://img.shields.io/badge/GITHUB_ACTIONS-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://docs.github.com/en/actions)
[![OCI](https://img.shields.io/badge/oracle-F80000?style=for-the-badge&logo=oracle&logoColor=white)](https://registry.terraform.io/providers/oracle/oci/latest/docs)
[![Trivy](https://img.shields.io/badge/TRIVY-353839?style=for-the-badge&logo=trivy&logoColor=white)](https://github.com/aquasecurity/trivy)

## Sommaire
- [Développement de l'application](#développement-de-lapplication)
- [Structure de données pour le stockage des calculs](#structure-de-données-pour-le-stockage-des-calculs)
- [Automatisation](#automatisation-cicd-pipeline-applicatif)
- [Docker](#docker)
    - [Création des images Docker](#création-des-images-docker)
    - [Scan des images avec Trivy](#scan-des-images-avec-trivy)
    - [Lancement des conteneurs](#lancement-des-conteneurs)
    - [Pousser les images dans le registry](#pousser-les-images-dans-le-registry)
    - [Vérification des images poussées](#vérification-des-images-poussées)
- [Problèmes rencontrés](#problèmes-rencontrés)
- [Voir aussi](#voir-aussi)

## Développement de l'application

### 1. Stack Technique
- **Frontend :** HTML, CSS, JS
- **Backend :** Flask (Python)
- **Base de données :** Redis
- **Queue de message :** RabbitMQ
- **Serveur web :** Nginx
- **Containerisation :** Docker
- **Scan des images :** Trivy
- **Automatisation :** GitHub Actions
- **Cloud :** Oracle Cloud (OCI) & GitHub Packages (GHCR)

### 2. Architecture Initiale
- **Frontend (HTML, CSS, JS) :** Création de l'interface utilisateur.
- **Backend avec Flask (Python) :** Mise en place de l'API pour renvoyer les résultats à l'utilisateur de manière synchrone :

```mermaid
graph TB
    A(Utilisateur) --> B[Frontend]
    B -->|"Envoi du calcul"| C[API] -->|Envoi du résultat| B
```

### 3. Évolution Asynchrone (Architecture Finale)
- J'ai ensuite intégré **RabbitMQ** pour gérer la file de messages et déléguer le traitement complexe des calculs à des *Workers* (consumers). L'ajout de **Redis** permet de stocker les résultats de ces calculs de manière asynchrone, comme l'illustre le schéma final :

```mermaid
graph TB
    A(Utilisateur) --> B[Frontend]
    B -->|"Envoi du calcul <br> ou <br> Demande d'un résultat"| C[API] -.-> |Envoi de l'id <br> ou <br> Résultat|B
    C -->|Transmission du calcul à faire| E[\RabbitMQ/] -.-> F(["Consumer (calcul)"]) -->|Récupération d'un calcul| E
    F -->|Stockage du résultat| D
    C <-->|Accès aux résultats| D[(Redis)]
```

## Structure de données pour le stockage des calculs

Les calculs effectués par l'application sont stockés dans **Redis**, une base de données clé-valeur. La structure utilisée est la suivante :

- **Clé :** Un identifiant unique (UUID) `calc_id` généré pour chaque calcul.
- **Valeur :** le résultat `result` du calcul.
```python
    redis_client.set(calc_id, result)
```

## Automatisation CI/CD (Pipeline Applicatif)

> [!NOTE]
> La création et le poussage des images Docker se font à l'aide de GitHub Actions. Plus de détails [workflow](../.github/workflows/app.yaml).

Le pipeline de CI (Continuous Integration) de l'application est conçu pour être rapide. Lorsqu'un changement est poussé sur le dépôt, les 3 composants (Frontend, Backend API, Worker Consumer) sont compilés et poussés **en parallèle** sur le registre Docker (GHCR) :

```mermaid
sequenceDiagram
    actor Dev as Développeur
    participant GitHub as GitHub Actions
    participant Docker as Docker Buildx
    participant GHCR as GitHub Container Registry (ghcr.io)

    Dev->>GitHub: Push du code (Application/*)
    note over GitHub: Trigger: Workflow app.yaml
    
    par Parallélisation des Builds
        GitHub->>Docker: Build Frontend
        GitHub->>Docker: Build API
        GitHub->>Docker: Build Consumer
    end
    
    par Push simultané sur le Registre
        Docker->>GHCR: Push ghcr.io/.../calculatrice-front
        Docker->>GHCR: Push ghcr.io/.../calculatrice-api
        Docker->>GHCR: Push ghcr.io/.../calculatrice-consumer
    end
```

*(Note : L'étape finale de ce pipeline, qui met à jour la configuration GitOps, est documentée dans [Helm](../Helm/README.md)).*

## Docker

### Création des images Docker

- #### Création de l'image app-frontend
```bash
docker build . -t ghcr.io/noureddine-t/calculatrice-front:latest
```

- #### Création de l'image backend-api
```bash
docker build . -t ghcr.io/noureddine-t/calculatrice-api:latest
```

- #### Création de l'image backend-consumer
```bash
docker build . -t ghcr.io/noureddine-t/calculatrice-consumer:latest
```
### Scan des images avec Trivy

- #### Scan de l'image app-frontend
```bash
trivy image ghcr.io/noureddine-t/calculatrice-front:latest
```
- #### Résultat du scan de l'image app-frontend
![Scan de l'image app-frontend](../docs/Autre/img/trivy_scan_front.png)

- #### Scan de l'image backend-api
```bash
trivy image ghcr.io/noureddine-t/calculatrice-api:latest
```
- #### Résultat du scan de l'image backend-api
![Scan de l'image backend-api](../docs/Autre/img/trivy_scan_api.png)

- #### Scan de l'image backend-consumer
```bash
trivy image ghcr.io/noureddine-t/calculatrice-consumer:latest
```
- #### Résultat du scan de l'image backend-consumer
![Scan de l'image backend-consumer](../docs/Autre/img/trivy_scan_consumer.png)

### Lancement des conteneurs

- #### En utilisant Docker Compose
```bash
docker-compose up
```
ou
```bash
docker-compose up --build
```
- #### Lancement du service Redis
```bash
docker run --rm -p 6379:6379 --name myRedis redis
```

- #### Lancement du service RabbitMQ
```bash 
docker run -it --rm --name myRabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

- #### Lancement du app-frontend
```bash
docker run --rm --name app-frontend -p 8080:80 ghcr.io/noureddine-t/calculatrice-front:latest
```

- #### Lancement du backend-api
```bash
docker run --rm --name backend-api -p 5000:5000 ghcr.io/noureddine-t/calculatrice-api:latest
```

- #### Lancement du backend-consumer
```bash
docker run --rm --name backend-consumer ghcr.io/noureddine-t/calculatrice-consumer:latest
```
### Pousser les images dans le registry
- #### Pousser app-frontend
```bash
docker push ghcr.io/noureddine-t/calculatrice-front:latest
```

- #### Pousser backend-api
```bash
docker push ghcr.io/noureddine-t/calculatrice-api:latest
```

- #### Pousser backend-consumer
```bash
docker push ghcr.io/noureddine-t/calculatrice-consumer:latest
```

### Vérification des images poussées

Les images Docker sont désormais hébergées sur le **GitHub Container Registry (GHCR)**. Leur présence et les tags disponibles sont vérifiables directement dans l'onglet **Packages** du profil GitHub ou sur la page d'accueil du dépôt.

## Problèmes rencontrés

### Politique CORS :
- Les requêtes HTTP effectuées vers un domaine différent de celui de la page déclenchent un blocage par le navigateur. Cela est dû aux restrictions de sécurité qui limitent, par défaut, les échanges aux seules requêtes provenant de la même origine.
- **Solution :** Autoriser les requêtes provenant d'un autre domaine en ajoutant des entêtes CORS dans le backend.
```python
from flask_cors import CORS
CORS(app)
```
### RabbitMQ :
- Timeout des channels après 60s.
- **Solution:** mettre le paramètre `heartbeat` à 0 pour désactiver le timeout.
```python
connection = pika.BlockingConnection(pika.ConnectionParameters(host='rabbitmq', heartbeat=0))
```

### Docker :
- **RabbitMQ et Redis :** Ils ne reconnaissaient pas `localhost`.
- **Solution :** Remplacement par `host.docker.internal` dans `host` de connexion de Redis et RabbitMQ afin de tester l'application en local avant de la déployer à l'aide de Kubernetes.
```python
redis = Redis(host='host.docker.internal', port=6379, db=0)
connection = pika.BlockingConnection(pika.ConnectionParameters(host='host.docker.internal'))
```

- **Conteneur :** Problème de connexion entre les conteneurs.
- **Solution :** Ajout de `host = 0.0.0.0` et `port = 5000` dans le backend pour qu'il soit accessible depuis l'extérieur.
```python
app.run(host='0.0.0.0', port=5000, debug=True)
```

### Docker Compose :
- **RabbitMQ :** une fois le conteneur prêt, la création des conteneurs pour l'API et le consumer commence, mais le service RabbitMQ n'est pas encore lancé. Cela entraîne un échec dans la création des conteneurs pour l'API et le consumer qui dépendent de ce dernier.
- **Solution :** Ajout de l'option `healthcheck` pour attendre que RabbitMQ soit prêt. Ajout l'option `depends_on` pour vérifier les conditions de démarrage avant de lancer le conteneur de l'API et celui du consumer.
```yaml
    healthcheck:
      test: [ "CMD", "rabbitmq-diagnostics", "status" ]
      interval: 10s
      timeout: 10s
      retries: 5
```
```yaml
    depends_on:
      rabbitmq:
        condition: service_healthy
      redis:
        condition: service_started
```

## Voir aussi
- [`Foundation/`](../Foundation) : Terraform (provisionnement de l'infrastructure).
- [`Helm/`](../Helm) : Le chart Helm qui est surveillé et déployé par ArgoCD.
- [`GitOps/`](../GitOps) : Configuration ArgoCD pour la synchronisation du cluster (déploiement continu).
- [`.github/workflows/`](../.github/workflows) : Fichier GitHub Actions pour automatiser le provisionnement de l'infrastructure et le déploiement de l'application.
- [`Kubernetes/`](../Kubernetes) : Manifests Kubernetes bruts (historique).
- [`Terragrunt/`](../Terragrunt) : Configuration Terragrunt pour gérer plusieurs environnements (Dev, Preprod, Prod).
- [`Sujet.md`](../Sujet.md) ou [source](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/projet.md).
- [🏠 Retourner à la racine du projet](../README.md)


- [🔼 Back to Top](#application)
