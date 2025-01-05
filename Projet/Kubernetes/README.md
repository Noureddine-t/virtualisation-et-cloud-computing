# Kubernetes

### Schema récapitulatif (services et replicasets)

```mermaid
graph LR
    
    subgraph "Kubernetes"
        subgraph "Taleb"
            subgraph "front-replicaset"
                pod-front
            end
            
            subgraph "api-replicaset"
                pod-api
            end
            
            subgraph "redis-replicaset"
                pod-redis[("Redis \n pod")]
            end
            
            subgraph "rabbitmq-replicaset"
                pod-rabbitmq[\" RabbitMQ \n pod"/]
            end
            
            subgraph "consumer-replicaset"
                pod-consumer
            end
            
            svc-api([svc-api]) --> pod-api
            svc-redis([svc-redis]) --> pod-redis
            svc-rabbitmq([svc-rabbitmq]) --> pod-rabbitmq
            pod-consumer -.-> svc-rabbitmq
            pod-consumer -.-> svc-redis
            pod-api -.-> svc-redis
            pod-api -.-> svc-rabbitmq
            ing -->|"calculatrice-taleb.polytech-dijon.kiowy.net/api"| svc-api
            ing(Ingress NGINX rules) -->|"calculatrice-taleb.polytech-dijon.kiowy.net/"| svc-front
            svc-front([svc-front]) --> pod-front
        end
    end
```
### Fonctionnement
#### Etape 1 : Demande de calcul

```mermaid
graph LR
    user([Utilisateur]) -->|choisit une opération \n et saisit deux nombres| F[Frontend]
    F -->|"HTTP POST /api/calculate"| A[API]
    A -->|"{id, calcul à faire}"| Q[\ RabbitMQ /]
    A -.->|HTTP 200 OK \n id| F
    C[Consumer] -->|"récupére le dernier message"| Q[\ RabbitMQ /]
    C -->|"redis.set(id, resultat du calcul)"| R[(Redis DB)]
```

#### Etape 2 : Récupération du résultat du calcul

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
### Commandes utiles

#### Namespace Kubernetes

```shell
kubectl create ns taleb
```
```shell
kubectl config set-context --current --namespace=taleb
```

#### Déploiement Redis

```shell
kubectl apply -f redis-replicaset.yaml
```
```shell
kubectl apply -f redis-service.yaml
```

#### Déploiement RabbitMQ

```shell
kubectl apply -f rabbitmq-replicaset.yaml
```
```shell
kubectl apply -f rabbitmq-service.yaml
```

#### Déploiement Frontend

```shell
kubectl apply -f front-replicaset.yaml
```
```shell
kubectl apply -f front-service.yaml
```

#### Déploiement Ingress

```shell
kubectl apply -f nginx-ingress.yaml
```

#### Déploiement Backend API

```shell
kubectl apply -f api-replicaset.yaml
```
```shell
kubectl apply -f api-service.yaml
```

#### Déploiement Consumer
```shell
kubectl apply -f consumer-replicaset.yaml
```

#### Debugging
```shell
kubectl get pods
```
```shell
kubectl get replicasets
```
```shell
kubectl get svc
```
```shell
kubectl get ingress
```
```shell
kubectl logs <pod-name>
```
```shell
kubectl describe pod <pod-name>
```
```shell
kubectl describe ingress
```

#### Suppression des replicasets

```shell
kubectl delete -f nginx-ingress.yaml
```
```shell
kubectl delete -f front-replicaset.yaml
```
```shell
kubectl delete -f api-replicaset.yaml
```
```shell
kubectl delete -f rabbitmq-replicaset.yaml
```
```shell
kubectl delete -f redis-replicaset.yaml
```
```shell
kubectl delete -f consumer-replicaset.yaml
```

#### Suppression des services

```shell
kubectl delete -f front-service.yaml
```
```shell
kubectl delete -f api-service.yaml
```
```shell
kubectl delete -f rabbitmq-service.yaml
```
```shell
kubectl delete -f redis-service.yaml
```

#### Suppression de toutes les resources

```shell
kubectl delete all --all -n taleb
```

### Problèmes rencontrés
- Remplacer `127.0.0.1` par `svc-api`, `svc-rabbitmq`, et `svc-redis`.
- Problème résolu en changeant le type de service de ClusterIP à LoadBalancer.
- Postman utilisé pour tester les requêtes API.