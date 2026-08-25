# AWS EKS & RDS Infrastructure (Local Emulation with Floci)

Une architecture Cloud-Native moderne émulant une pile AWS multi-tiers (VPC, EKS, RDS PostgreSQL, ECR) en environnement local à l'aide de **Floci** (K3s), orchestrée via **Kubernetes** et automatisée par un pipeline **CI/CD GitHub Actions**.

---

## 📐 Architecture du Projet

L'infrastructure s'articule autour d'une séparation stricte en 3 tiers réseau (Public, App Privé, Data Privé) sur deux zones d'disponibilité (Multi-AZ) :

![AWS EKS Architecture](architecture.jpg)

### Composants de l'Architecture
* **VPC (`10.0.0.0/16`)** : Isolation réseau globale.
* **Public Tier** : 
  * `Public Subnet 1` (`10.0.1.0/24`) & `Public Subnet 2` (`10.0.2.0/24`).
  * NAT Gateways et Application Load Balancers (ALB) pour l'exposition et le trafic sortant.
* **Private App Tier (EKS)** :
  * `Private Subnet 1` (`10.0.10.0/24`) & `Private Subnet 2` (`10.0.20.0/24`).
  * Worker Nodes EKS exécutant les Pods applicatifs (Node.js).
* **Private Data Tier (RDS)** :
  * `DB Subnet 1` (`10.0.100.0/24`) & `DB Subnet 2` (`10.0.200.0/24`).
  * Instance PostgreSQL Primaire avec réplication synchrone Multi-AZ (Standby DB).

---

## 🛠️ Stack Technique

* **Infrastructure & Émulation Cloud** : Floci (Émulation AWS EKS/K3s, RDS PostgreSQL, ECR local)
* **Orchestration** : Kubernetes / K3s (Deployments, Services NodePort, Secrets, Ingress)
* **Conteneurisation** : Docker (Base image Node.js Alpine)
* **Base de données** : PostgreSQL 
* **CI/CD** : GitHub Actions via un **Self-Hosted Runner** (Fedora)

---

## 🚀 Fonctionnalités & Workflow CI/CD

Le projet inclut un pipeline de déploiement continu automatisé (`.github/workflows/deploy.yml`) :

[ Git Push ] ➔ [ Self-Hosted Runner ] ➔ [ Build Docker ] ➔ [ Import K3s ] ➔ [ Rollout Restart K8s ]


1. **Build d'image** : Automatisé depuis l'application (`app/Dockerfile`).
2. **Import direct** : Transfert de l'image dans le runtime K3s local (`ctr images import`).
3. **Mise à jour sans interruption** : Redéploiement à chaud du Deployment Kubernetes.

---

## 📋 Structure du Dépôt

```text
.
├── app/
│   ├── Dockerfile
│   ├── package.json
│   └── index.js
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── secret.yaml
│   └── ingress.yaml
├── .github/
│   └── workflows/
│       └── deploy.yml
├── architecture.jpg
└── README.md

🧪 Verification & Health Check

L'application valide son interconnectivité avec la base RDS via l'endpoint de santé :
Bash

# Vérification via le NodePort (30080) sur le conteneur Floci
docker exec -it floci-eks-aws-eks-cluster-dev wget -qO- [http://127.0.0.1:30080/health](http://127.0.0.1:30080/health)

Résultat attendu :
JSON

{
  "status": "UP",
  "db": "Connected to Postgres"
}

📄 Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.


---

### 💡 Conseils pour l'intégration :
1. Enregistre l'image du diagramme générée plus haut sous le nom **`architecture.jpg`** à la racine de ton dépôt GitHub.
2. Copie-colle le bloc ci-dessus dans le fichier **`README.md`** à la racine de ton projet.