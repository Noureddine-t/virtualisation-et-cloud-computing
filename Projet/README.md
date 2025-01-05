# virtualisation-et-cloud-computing
## Description
Projet de virtualisation utilisant Docker, Docker Compose, et Kubernetes pour déployer une application de calculatrice cloud native.

## Technologies utilisées
- **Backend :** Flask (Python)
- **Frontend :** HTML, CSS, JS
- **Base de données :** Redis
- **Queue de message :** RabbitMQ
- **Serveur web :** Nginx
- **Containerisation :** Docker
- **Orchestration :** Kubernetes
- **Provisionnement :** Terraform
- **Cloud :** Google Cloud Platform

## Contenu
- `Application/` : Fichiers de l'application web (front-end, back-end, consumer), Dockerfiles associés et docker-compose.
- `Kubernetes/` : Manifests Kubernetes (Replicaset, Service, Ingress)
- `Foundation/` : Terraform (provisionnement de l'infrastructure)

## Déroulement du projet
// TODO: Ajouter le déroulement du projet



  ```mermaid
  graph TB;
      A(Utilisateur) --> B[Frontend]
      B -->|"Envoi du calcul "| C[API] -->|Envoi du résultat| B
  ```

  ```mermaid
  graph TB;
      A(Utilisateur) --> B[Frontend]
      B -->|"Envoi du calcul \n ou \n Demande d'un résultat"| C[API]
      C -->|Transmission du calcul à faire | E[\RabbitMQ/] -.-> F(["Consumer( calcul )"]) -->|Récupèration d'un calcul| E
      F -->|Stockage du résultat| D
      C <-->|Accès aux résultats| D[(Redis)]
  ```

## Problèmes rencontrés
- **Docker :** Connexion `localhost` -> remplacé par `host.docker.internal`.
- **Kubernetes :** ClusterIP non accessible de l'extérieur. Solution : changement en LoadBalancer.
- **RabbitMQ :** Timeout des channels après 60s.

## Notes
- L'application est désormais accessible via ce lien [Calculatrice Cloud Native](http://calculatrice-taleb.polytech-dijon.kiowy.net).
- Veuillez ajouter la ligne suivante `34.77.144.136 calculatrice-taleb.polytech-dijon.kiowy.net` dans:
  - pour windows :`C:\Windows\System32\drivers\etc\hosts`
  - pour linux : `/etc/hosts`

**author:** Nour Eddine TALEB

