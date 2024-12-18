pour lancer redis
```bash
docker run --rm -p 6379:6379 --name myRedis redis

```

pour lancer rabbitmq
```bash 
docker run -it --rm --name myRabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management

```

dans un premier temps j ai crée mon frontend (html,css,js), et mon backend avec flask (proposé).
j ai créer mon premier fichier python pour envoyer résultat a l'utilisateur et le stocker dans redis, le stocker sur redis.
ensuite j ai intégré rabbitmq et la logique demdandée pour le traitement des données.




je suis passer a dockerfile : mon backend le reconnait pas localhost, j ai du changer l'adresse ip de redis et rabbitmq pour que mon backend puisse les reconnaitre.


```bash
docker build . -t europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-api:talebv3
docker run --rm --name backend-api -p 5000:5000 europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-api:talebv3

```
```bash
docker build . -t europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-consumer:talebv3
docker run  --rm --name backend-consumer europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-consumer:talebv3

```
```bash
docker build . -t europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/app-frontend:talebv3
docker run  --rm --name app-frontend -p 8080:80 europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/app-frontend:talebv3

```
a force de lancer plusioeeurs commandes dans différents terminal plusiiur fois afin de debuggere j ai décidé de créer un docker-compose pour lancer les 3 containers en meme temps.

debugging:
apres 8h j ai réssussi a faire fonctionner mon application, j ai eu des problèmes de connexion entre mes containers. solution etait d echangre localhost par host.docker.internal et ajouter host 0.0.0.0 et port 5000 dans mon application backend pour qu'elle soit accessible depuis l'extrérieur.

en utilisant docker-compose, j ai pu lancer mes 3 containers en meme temps et les connecter entre eux.
```bash
# docker-compose lancer les containers 
docker-compose up 
#docker-compose construire les images et lancer les containers
docker-compose up --build
```

```bash
# pousser les images dans le registry
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-api:talebv3
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-consumer:talebv3
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/app-frontend:talebv3
```

```bash
# verifier que les images sont bien poussées
gcloud artifacts docker images list europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon
```