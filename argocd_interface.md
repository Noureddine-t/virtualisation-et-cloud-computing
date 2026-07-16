# Guide d'accès à l'interface graphique d'ArgoCD

L'interface graphique d'ArgoCD n'est pas exposée directement sur Internet par défaut pour des raisons de sécurité. 

Voici la méthode pour y accéder rapidement et en toute sécurité via un tunnel SSH.

## 1. Connexion SSH avec tunnel (Local Port Forwarding)

Connectez-vous à votre serveur en SSH **en ajoutant l'argument de tunnel `-L`** :
```bash
ssh -i .\ssh_key -L 8080:localhost:8080 ubuntu@VOTRE_IP_PUBLIQUE
```

Une fois connecté, exécutez la commande suivante pour révéler le mot de passe initial (généré automatiquement par ArgoCD) :
```bash
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
*Copiez précieusement ce mot de passe.* Le nom d'utilisateur par défaut est **`admin`**.

## 3. Lancer le relai Kubernetes

Toujours sur le serveur (dans la même session SSH), lancez cette commande pour relayer l'interface ArgoCD vers le port interne de la machine :
```bash
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443
```
> **Attention :** Laissez ce terminal ouvert, la commande doit continuer de tourner en arrière-plan pendant que vous naviguez sur l'interface.

## 4. Ouvrir l'interface dans le navigateur

Ouvrez votre navigateur web sur votre ordinateur et naviguez vers l'adresse locale suivante :
👉 **`https://localhost:8080`**

*(Note : Votre navigateur vous avertira que la connexion n'est pas sécurisée. C'est tout à fait normal car ArgoCD utilise ici son propre certificat auto-signé interne. Cliquez sur "Paramètres avancés" puis "Continuer vers le site").*

## 5. Connexion

- **Username :** `admin`
- **Password :** *Le mot de passe récupéré à l'étape 1*

Vous avez maintenant accès au tableau de bord complet de GitOps ! Vous pourrez y voir le statut de synchronisation (Sync Status), l'état de santé de vos pods (Health), et toute l'architecture de votre application sous forme d'arbre.
