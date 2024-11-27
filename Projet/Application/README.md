pour lancer redis
```bash
docker run --rm -d -p 6379:6379 --name redis redis

```

pour lancer rabbitmq
```bash 
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.12-management
```

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

```bash
docker-compose up --build
```
