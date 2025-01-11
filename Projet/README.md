# Projet de Virtualisation et Cloud - Calculatrice Cloud Native

## Description
Projet de virtualisation et cloud effectué à Polytech Dijon pour déployer une application de calculatrice cloud native.

## Technologies utilisées

- **Frontend :** HTML, CSS, JS
- **Backend :** Flask (Python)
- **Base de données :** Redis
- **Queue de message :** RabbitMQ
- **Serveur web :** Nginx
- **Containerisation :** Docker
- **Orchestration :** Kubernetes
- **Provisionnement :** Terraform
- **Cloud :** Google Cloud Platform

## Contenu
-  [`Application/`](./Application) : Fichiers de l'application web (front-end, back-end, consumer), Dockerfiles associés et docker-compose.
- [`Kubernetes/`](./Kubernetes) : Manifests Kubernetes (Replicaset, Service, Ingress)
- [`Foundation/`](./Foundation) : Terraform (provisionnement de l'infrastructure)

## Déroulement du projet

1. **Terraform :** 
- J'ai commencé par utiliser Terraform pour le provisionnement de l'infrastructure.


2. **Développement de l'application :** Une fois l'infrastructure terminée, j'ai commencé à développer l'application.
- **Frontend (HTML, CSS, JS) :** Création de l'interface utilisateur.
- **Backend avec Flask (Python) :** Mise en place de l'API pour envoyer les résultats à l'utilisateur comme affiché dans le schéma suivant :

 ```mermaid
   graph TB; 
       A(Utilisateur) --> B[Frontend]
       B -->|"Envoi du calcul"| C[API] -->|Envoi du résultat| B
 ```

3. **Intégration de la logique demandée :** 
- J'ai intégré RabbitMQ pour gérer la queue de messages et organiser le traitement des calculs via des consommateurs en plus de stocker les résultats dans Redis comme indiqué dans le schéma suivant :

```mermaid
    graph TB; 
        A(Utilisateur) --> B[Frontend]
        B -->|"Envoi du calcul <br> ou <br> Demande d'un résultat"| C[API]
        C -->|Transmission du calcul à faire| E[\RabbitMQ/] -.-> F(["Consumer (calcul)"]) -->|Récupération d'un calcul| E
        F -->|Stockage du résultat| D
        C <-->|Accès aux résultats| D[(Redis)]
```

4. **Containerisation :**
  - Création des Dockerfiles pour chaque partie de l'application (frontend, backend, consumer).
  - Mise en place d'un fichier `docker-compose.yml` pour faciliter le lancement des 5 conteneurs (frontend, backend, consumer, Redis, RabbitMQ).

5. **Orchestration avec Kubernetes :**
  - Création des manifests Kubernetes pour déployer l'application et y accéder via un nom de domaine.

6. **Accès à l'application :** Une fois l'application fonctionnelle avec Docker et Kubernetes, l'application est accessible via un nom de domaine.

L'ensemble des problématiques rencontrées et des solutions apportées sont détaillées dans les fichiers `README.md` de chaque partie du projet.

## Notes
- L'application est désormais accessible via ce lien : [Calculatrice Cloud Native](http://calculatrice-taleb.polytech-dijon.kiowy.net).
- Veuillez ajouter la ligne suivante `34.77.144.136 calculatrice-taleb.polytech-dijon.kiowy.net` dans votre fichier `hosts` :
  - **Windows :** `C:\Windows\System32\drivers\etc\hosts`
  - **Linux :** `/etc/hosts`

## Auteur
**Nour Eddine TALEB**

