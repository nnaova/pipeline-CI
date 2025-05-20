# Pipeline de Déploiement Continu - API de Capteurs IoT

Ce projet met en place une infrastructure complète pour déployer et gérer une API REST de supervision de capteurs environnementaux.

## Architecture

- **API** : Application Node.js exposant des endpoints REST pour interagir avec les données de capteurs
- **Infrastructure** : Instance Google Compute Engine avec Ubuntu, provisionnée par Terraform
- **Configuration** : Installation et déploiement automatisés via Ansible
- **CI/CD** : Pipeline GitHub Actions pour les tests, le build et le déploiement

## Prérequis

- Google Cloud SDK configuré avec des credentials valides
- Terraform v1.0.0+
- Ansible 2.10+
- Node.js 16.x+
- Compte GitHub pour le déploiement CI/CD

## Structure du projet

```
├── .github/workflows/  # Configuration GitHub Actions
├── api/                # Code source de l'API Node.js
├── ansible/            # Playbooks et inventaire Ansible
├── infra/              # Configuration Terraform
├── release.sh          # Script de release
└── rapport.md          # Documentation du projet
```

## Démarrage rapide

### 1. Provisionnement de l'infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 2. Déploiement manuel de l'API

```bash
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml
```

### 3. Création d'une nouvelle version

```bash
./release.sh
```

## Points d'accès de l'API

- `GET /` - Statut de l'API
- `GET /api/sensors` - Liste de tous les capteurs
- `GET /api/sensors/:id` - Détails d'un capteur spécifique
- `POST /api/sensors` - Ajouter un nouveau capteur
- `PUT /api/sensors/:id` - Mettre à jour un capteur existant

## Pipeline CI/CD

Le pipeline CI/CD s'exécute automatiquement :

- Sur chaque push sur la branche `main` (tests et build)
- À la création d'un tag de version (déploiement complet)

## Documentation complète

Voir [rapport.md](rapport.md) pour une documentation détaillée de l'architecture, des choix techniques et du processus de déploiement.
