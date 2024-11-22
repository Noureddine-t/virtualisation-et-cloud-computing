pour lancer redis
```bash
docker run -d -p 6379:6379 --name redis redis
```

pour lancer rabbitmq
```bash 
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

dans un premier temps j ai crée mon frontend (html,css,js), et mon backend avec flask (proposé). 
j ai créer mon premier fichier python pour envoyer résultat a l'utilisateur et le stocker dans redis, le stocker sur redis.
ensuite j ai intégré rabbitmq et la logique demdandée pour le traitement des données.
