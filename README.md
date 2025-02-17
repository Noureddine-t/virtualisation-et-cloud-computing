# Virtualisation-et-cloud-computing

Contient le projet du module de Virtualisation & Cloud Computing et les travaux dirigés réalisés à Polytech Dijon.

- **Travaux dirigés 👉 [ici](TD)**
- **Projet de Calculatrice Cloud Native ci-dessous 👇**

| [![uBe](./docs/Autre/img/UB-Europe.png)](https://www.ube.fr) | Polytech Dijon - 4A - ILIA/SQR <br/> Projet&nbsp;de&nbsp;Virtualisation&nbsp;&amp;&nbsp;Cloud&nbsp;Computing <br/> Calculatrice Cloud Native <br/><br/> **[ EXAMEN PRATIQUE ]** | [![Polytech Dijon](./docs/Autre/img/logo_polytech.png)](https://polytech.ube.fr) |
|:-------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|---------------------------------------------------------------------------------:|

[![docker](https://img.shields.io/badge/DOCKER-blue?style=for-the-badge&logo=docker&logoColor=white)](https://docs.docker.com/)
[![kubernetes](https://img.shields.io/badge/KUBERNETES-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![flask](https://img.shields.io/badge/FLASK-000000?style=for-the-badge&logo=flask&logoColor=white)](https://flask.palletsprojects.com/)
[![redis](https://img.shields.io/badge/REDIS-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io/)
[![LapinMQ](https://img.shields.io/badge/rabbitmq-%23FF6600.svg?&style=for-the-badge&logo=rabbitmq&logoColor=white)](https://rabbitmq.com/)
[![nginx](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)](https://nginx.org/)
[![terraform](https://img.shields.io/badge/TERRAFORM-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![scaleway](https://img.shields.io/badge/scaleway-663399?style=for-the-badge&logo=scaleway&logoColor=white)](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs)
[![HTML](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/fr/docs/Web/HTML)
[![CSS](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)](https://developer.mozilla.org/fr/docs/Web/CSS)
[![JS](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/fr/docs/Web/JavaScript)
[![GitHub Actions](https://img.shields.io/badge/GITHUB_ACTIONS-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://docs.github.com/en/actions)
[![Google Cloud Platform](https://img.shields.io/badge/Google_Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Trivy](https://img.shields.io/badge/TRIVY-353839?style=for-the-badge&logo=trivy&logoColor=white)](https://github.com/aquasecurity/trivy)
## Sommaire
- [Description](#description)
- [Technologies utilisées](#technologies-utilisées)
- [Contenu](#contenu)
- [Déroulement du projet](#déroulement-du-projet)
  - [1. Terraform](#1-terraform)
  - [2. Développement de l'application](#2-développement-de-lapplication)
  - [3. Intégration de la logique demandée](#3-intégration-de-la-logique-demandée)
  - [4. Containerisation](#4-containerisation)
  - [5. Orchestration avec Kubernetes](#5-orchestration-avec-kubernetes)
  - [6. Accès à l'application](#6-accès-à-lapplication)
  - [7. Scan des images avec Trivy](#7-scan-des-images-avec-trivy)
  - [8. Automatisation du déploiement (CI/CD)](#8-automatisation-du-déploiement-cicd)
- [Application](#application)

## Description
Projet de virtualisation et cloud effectué à Polytech Dijon pour déployer une application de calculatrice cloud native. [Sujet](Sujet.md) ou [source](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/projet.md)


## Technologies utilisées

- **Frontend :** HTML, CSS, JS
- **Backend :** Flask (Python)
- **Base de données :** Redis
- **Queue de message :** RabbitMQ
- **Serveur web :** Nginx
- **Provisionnement :** Terraform
- **Provider :** Scaleway
- **Containerisation :** Docker
- **Scan des images :** Trivy
- **Orchestration :** Kubernetes
- **CI/CD :** GitHub Actions
- **Cloud :** Google Cloud Platform

## Contenu
- [`Application/`](./Application) : Fichiers de l'application web (front-end, back-end, consumer), Dockerfiles associés et docker-compose.
- [`Kubernetes/`](./Kubernetes) : Manifests Kubernetes (Replicaset, Service, Ingress).
- [`Foundation/`](./Foundation) : Terraform (provisionnement de l'infrastructure).
- [`.github/workflows/`](./.github/workflows) : Fichier GitHub Actions pour automatiser le build, le push des images Docker et le déploiement de l'application.
- [`Sujet.md`](./Sujet.md) [source](https://github.com/JeromeMSD/module_virtualisation-et-cloud-computing/blob/main/projet.md).

## Déroulement du projet

### 1. Terraform
- J'ai commencé par utiliser Terraform pour le provisionnement de l'infrastructure. [ici](./Foundation)

### 2. Développement de l'application
- **Frontend (HTML, CSS, JS) :** Création de l'interface utilisateur.
- **Backend avec Flask (Python) :** Mise en place de l'API pour envoyer les résultats à l'utilisateur comme affiché dans le schéma suivant :

 ```mermaid
   graph TB; 
       A(Utilisateur) --> B[Frontend]
       B -->|"Envoi du calcul"| C[API] -->|Envoi du résultat| B
 ```

### 3. Intégration de la logique demandée
- J'ai intégré RabbitMQ pour gérer la queue de messages et organiser le traitement des calculs via des consommateurs en plus de stocker les résultats dans Redis comme indiqué dans le schéma suivant :

```mermaid
    graph TB; 
        A(Utilisateur) --> B[Frontend]
        B -->|"Envoi du calcul <br> ou <br> Demande d'un résultat"| C[API] -.-> |Evoi de l'id <br> ou <br> Résultat|B
        C -->|Transmission du calcul à faire| E[\RabbitMQ/] -.-> F(["Consumer (calcul)"]) -->|Récupération d'un calcul| E
        F -->|Stockage du résultat| D
        C <-->|Accès aux résultats| D[(Redis)]
```

### 4. Containerisation
  - **Docker :** Création des Dockerfiles pour chaque partie de l'application (frontend, backend, consumer). [ici](./Application)

    - **Docker Compose :** Mise en place d'un fichier `docker-compose.yml` pour faciliter le lancement des 5 conteneurs (frontend, backend, consumer, Redis, RabbitMQ).

### 5. Orchestration avec Kubernetes
  - Création des manifests Kubernetes pour déployer l'application. [ici](./Kubernetes)

### 6. Accès à l'application
  - Une fois l'application fonctionnelle avec Docker et Kubernetes, l'application est accessible. [voir la section application](#application)

### 7. Scan des images avec Trivy
  - J'ai également scanné les images Docker avec Trivy pour identifier les vulnérabilités. [ici](./Application/README.md/#scan-des-images-avec-trivy)

### 8. Automatisation du déploiement (CI/CD)
- J'ai automatisé le build et le push des images Docker sur le registry de Google Cloud Platform mais également le déploiement de l'application avec Kubernetes en utilisant GitHub Actions. [ici](./.github/workflows/build_push_deploy.yaml)

> [!NOTE]
> L'ensemble des problématiques rencontrées et des solutions apportées sont détaillées dans les fichiers `README.md` de chaque partie du projet.
> - [Application](./Application/README.md)
> - [Kubernetes](./Kubernetes/README.md)
> - [Foundation](./Foundation/README.md)



## Application
> [!IMPORTANT]
> ~~L'application est désormais accessible via ce lien : [Calculatrice Cloud Native](http://calculatrice-taleb.polytech-dijon.kiowy.net)~~
> 
> ~~Veuillez ajouter la ligne suivante `34.77.144.136 calculatrice-taleb.polytech-dijon.kiowy.net` dans votre fichier `hosts` :~~
>  - ~~**Windows :** `C:\Windows\System32\drivers\etc\hosts`~~
>  - ~~**Linux :** `/etc/hosts`~~

- [🔼 Back to Top](#virtualisation-et-cloud-computing)

