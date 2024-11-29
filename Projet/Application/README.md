pour lancer redis
```bash
docker run --rm -d -p 6379:6379 --name redis redis

```

pour lancer rabbitmq
```bash 
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management

```

dans un premier temps j ai crée mon frontend (html,css,js), et mon backend avec flask (proposé).
j ai créer mon premier fichier python pour envoyer résultat a l'utilisateur et le stocker dans redis, le stocker sur redis.
ensuite j ai intégré rabbitmq et la logique demdandée pour le traitement des données.




je suis passer a dockerfile : mon backend le reconnait pas localhost, j ai du changer l'adresse ip de redis et rabbitmq pour que mon backend puisse les reconnaitre.


```bash
docker build . -t backend-api 
docker run --rm --name backend-api -p 5000:5000 backend-api

```
```bash
docker build . -t backend-consumer
docker run  --rm --name backend-consumer backend-consumer

```
```bash
docker build . -t app-frontend
docker run  --rm --name app-frontend -p 8080:80 app-frontend

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
