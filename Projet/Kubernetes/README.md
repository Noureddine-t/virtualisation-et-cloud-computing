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
