apres avoir fini mon application et la tester avec des conteneur docker, j ai décidé de passer a kubernetes.

1. Initialiser `gcloud`

    ```shell
    gcloud init
    ```

   Aux question posées, répondez :
    * Pick a configuration to use :  **[1] Re-initialize this configuration (default) with new settings**
    * Select an account : **Skip this step**

2. S'authentifier

    ```shell
    gcloud auth login
    ```

   Connectez-vous avec l'adresse email Google que vous aviez saisie dans le Google Sheet

3. Configurer le projet
    ```shell
    gcloud config set project polytech-dijon
    ```

   Do you want to continue (Y/n) ? **Y**

4. Configurer l'outil `docker` pour pousser dans **Artifact Registry**.

    ```shell
    gcloud auth configure-docker europe-west1-docker.pkg.dev
    ```

**Vous pouvez maintenant pousser les images.** Utiliser les tags adaptés pour faire fonctionner la commande `docker push`

###### Exemple pour le frontend

```shell
europe-west1-docker.pkg.dev/polytech-dijon/polytech-dijon/frontend-2024:nom1-nom2
```

kubectl create ns taleb
kubectl config set-context --current --namespace=taleb

kubectl apply -f front-replicaset.yaml
kubectl apply -f front-service.yaml

kubectl apply -f nginx-ingress.yaml

kubectl apply -f rabbitmq-replicaset.yaml
kubectl apply -f rabbitmq-service.yaml

kubectl apply -f redis-replicaset.yaml
kubectl apply -f redis-service.yaml

kubectl apply -f api-replicaset.yaml
kubectl apply -f api-service.yaml

kubectl apply -f consumer-replicaset.yaml

kubectl port-forward service/svc-front 8080:80



kubectl get replicasets
kubectl get pods
kubectl get svc

kubectl delete -f nginx-ingress.yaml

kubectl delete -f front-replicaset.yaml
kubectl delete -f front-service.yaml

kubectl delete -f api-replicaset.yaml
kubectl delete -f api-service.yaml

kubectl delete -f rabbitmq-replicaset.yaml
kubectl delete -f rabbitmq-service.yaml

kubectl delete -f redis-replicaset.yaml
kubectl delete -f redis-service.yaml

kubectl delete -f consumer-replicaset.yaml


---------------------------------------------------------------------------
kubectl logs frontend-replicaset-5blbn
kubectl get endpoints svc-front

kubectl get pods -n ingress-nginx
kubectl logs -n ingress-nginx ingress-nginx-controller-586f4794cb-nn62d

kubectl get svc svc-front -o=jsonpath='{.metadata.namespace}'ace}'
kubectl get ingress front-ingress -o=jsonpath='{.metadata.namespace}'

kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx

kubectl describe ingress front-ingress -n taleb

kubectl get ingressclass

kubectl delete all --all -n taleb
   
kubectl logs <pod-name> -n taleb -f

------------------------------------------------------------------------------------------------

kubectl logs consumer-replicaset-dz2rm


remplacer 127.0.0.1 (localhost) par le nom du service "svc-api"
remplacer host.docker.internal "svc-rabbitmq"
remplacer localhost "svc-redis"
j ai du modifire mes fichier par conséquent créer de nouvbelle iumage et les pousser sauf que mes modification n'etait pas prise en cvompte. j ai du tout supprimer de mon namespacee et ajoutre une nouvlle tag a mes images pour eviter confusion taleb->talebv2
calculatrice-taleb-polytech-dijon.kiowy.net

supposition
apres plusieurs echecs et tentatives. 
vu que je peux pas acceder a mon application depuis "calculatrice-taleb-polytech-dijon.kiowy.net" avec ingress (intrieur) , je redirige le 8080 a 80 pour acceder a mon application depuiis localhost:8080 (extérieur)
maitenant que l'acces a mon application est fait. j arrive a envoyer mes requetes a l'api via serevice tant que CLUSTERIP j ai conclu que cela n est pas possible car la source de la requete via de l'extreieur.
au final j ai utilisé postman pour envoyer des requetes directement a mon api.
j ai changé type du service a loadbalancer pour que je puisse acceder a mon api depuis l'exterieur.
et j ai bien recu les reponses de mon api.

autres problemes:
- le channel de rabbitmq se ferme automatiquement apres 60s ce qui fait que mon cluster est tjrs 'running' pareil pour les pods mais y a pas de communication dernire.
