# Application et Docker

### Développement de l'application
- **Frontend :** HTML, CSS, JS
- **Backend :** Flask (Python)
- **Base de données :** Redis
- **Queue de message :** RabbitMQ
- **Serveur web :** Nginx

### Dockerfile

#### Création des images Docker

- Création de l'image app-frontend
```bash
docker build . -t europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/app-frontend:talebv8
```

- Création de l'image backend-api
```bash
docker build . -t europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-api:talebv3
```

- Création de l'image backend-consumer
```bash
docker build . -t europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-consumer:talebv4
```


#### Lancement des conteneurs

- En utilisant Docker Compose
```bash
docker-compose up
```
ou
```bash
docker-compose up --build
```
- Lancement du service Redis
```bash
docker run --rm -p 6379:6379 --name myRedis redis
```

- Lancement du service RabbitMQ
```bash 
docker run -it --rm --name myRabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

- Lancement du app-frontend
```bash
docker run --rm --name app-frontend -p 8080:80 europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/app-frontend:talebv8
```

- Lancement du backend-api
```bash
docker run --rm --name backend-api -p 5000:5000 europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-api:talebv3
```

- Lancement du backend-consumer
```bash
docker run --rm --name backend-consumer europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-consumer:talebv4
```
### Pousser les images dans le registry
- Pousser app-frontend
```bash
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/app-frontend:talebv8
```

- Pousser backend-api
```bash
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-api:talebv3
```

- Pousser backend-consumer
```bash
docker push europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/backend-consumer:talebv4
```



### Vérification des images poussées
```bash
gcloud artifacts docker images list europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon
```

#### Problème rencontré
- Backend ne reconnaissait pas `localhost`.
- Solution : Remplacement par `host.docker.internal` + modification IP de Redis et RabbitMQ.
- Problème CORS Policy 

