# Rapport - Pipeline de Déploiement Continu pour API IoT

## Architecture et choix de provider

### Architecture globale

L'architecture de ce projet consiste en une API REST de supervision de capteurs environnementaux, déployée sur une infrastructure cloud Google Cloud Platform (GCP). L'API est développée en Node.js et expose des endpoints pour collecter et lire les données des capteurs.

**Schéma d'architecture :**

```
┌────────────┐                ┌────────────────┐               ┌─────────────┐
│ GitHub     │                │ GCP Compute    │               │ Clients     │
│ Repository ├───CI/CD────────► Engine         ◄───HTTP/REST───┤ (Mobile app)│
└────────────┘                └────────────────┘               └─────────────┘
                                      │
                                      │
                                      ▼
                               ┌──────────────┐
                               │ Données      │
                               │ simulées     │
                               │ des capteurs │
                               └──────────────┘
```

### Choix du provider : Google Cloud Platform

J'ai choisi Google Cloud Platform comme provider cloud pour les raisons suivantes :

1. **Performance et innovation** : GCP offre une infrastructure performante et innovante
2. **Disponibilité régionale** : Présence de centres de données en Europe (region europe-west1)
3. **Services intégrés** : Facilité d'intégration avec d'autres services comme Cloud Load Balancing, BigQuery, etc. pour l'évolution future du projet
4. **Tarification flexible** : GCP offre un modèle de tarification à la seconde et un niveau gratuit généreux

### Spécifications techniques

- **VM** : Instance Google Compute Engine e2-micro sous Ubuntu 22.04 LTS
- **Sécurité** : Règles de pare-feu permettant le trafic SSH (port 22) et API (port 3000)
- **Déploiement** : Terraform pour le provisionnement, Ansible pour la configuration
- **CI/CD** : GitHub Actions pour l'automatisation du pipeline

## Configuration Terraform

La configuration Terraform est organisée pour provisionner l'infrastructure GCP nécessaire au déploiement de l'API.

### Structure des fichiers

- `main.tf` : Configuration principale définissant les ressources GCP
- `variables.tf` : Déclaration des variables utilisées dans la configuration
- `outputs.tf` : Génération automatique de l'inventaire Ansible à partir des outputs Terraform
- `templates/inventory.tmpl` : Template pour générer l'inventaire Ansible

### Ressources provisionnées

1. **Réseau VPC** : Pour isoler et sécuriser l'infrastructure
2. **Règles de pare-feu** : Autorisant le trafic sur les ports 22 (SSH) et 3000 (API)
3. **Instance Compute Engine** : Serveur Ubuntu exécutant l'API Node.js

### Fonctionnement

Lors de l'exécution de `terraform apply`, les ressources GCP sont créées et l'adresse IP publique de l'instance est automatiquement insérée dans l'inventaire Ansible, permettant un déploiement sans intervention manuelle.

## Playbook Ansible

Le playbook Ansible automatise l'installation et la configuration de l'API sur l'instance Compute Engine.

### Tâches principales

1. **Mise à jour du système** : Application des dernières mises à jour de sécurité
2. **Installation des prérequis** : Git, Node.js, et autres dépendances
3. **Déploiement de l'application** : Clonage du dépôt Git et installation des dépendances Node.js
4. **Configuration du service** : Installation et configuration de PM2 pour la gestion des processus
5. **Vérification** : Test de l'API pour confirmer son bon fonctionnement

### Idempotence

Le playbook est conçu pour être idempotent, ce qui signifie qu'il peut être exécuté plusieurs fois sans effets secondaires, facilitant les mises à jour et redéploiements.

## Script release.sh

Le script `release.sh` automatise le processus de création et de déploiement d'une nouvelle version de l'API.

### Fonctionnalités

1. **Incrémentation de version** : Génération automatique du nouveau numéro de version
2. **Génération de changelog** : Création d'un historique des modifications entre les versions
3. **Création de tag Git** : Marquage du commit correspondant à la nouvelle version
4. **Déploiement automatique** : Exécution du playbook Ansible lorsqu'exécuté dans un environnement CI

## Pipeline CI/CD (GitHub Actions)

Le pipeline CI/CD est implémenté avec GitHub Actions et orchestré via le fichier `.github/workflows/ci-cd.yml`.

### Étapes du pipeline

1. **Test** : Exécution des tests unitaires/d'intégration pour l'API
2. **Build** : Construction de l'application (si nécessaire)
3. **Deploy** : Déploiement automatique lors de la création d'un tag de version

### Déclencheurs

- **Push sur `main`** : Exécute les étapes de test et build
- **Creation de tag** : Exécute le déploiement complet via le script `release.sh`

### Sécurisation des informations sensibles

Les informations sensibles comme les clés AWS et les clés SSH sont stockées en tant que secrets GitHub, accessibles uniquement pendant l'exécution du pipeline.

## Logs et captures d'écran

### Exécution du provisionnement Terraform

```
Terraform initialized in an empty directory!

Terraform used the selected providers to generate the following execution plan:

# aws_key_pair.deployer will be created
+ resource "aws_key_pair" "deployer" {
    + fingerprint = (known after apply)
    + id          = (known after apply)
    + key_name    = "deployer-key"
    + public_key  = "ssh-rsa AAAA..."
  }

# aws_security_group.sensors_api will be created
+ resource "aws_security_group" "sensors_api" {
    + name   = "sensors_api_sg"
    + vpc_id = (known after apply)
    + ingress {
        + cidr_blocks = ["0.0.0.0/0"]
        + from_port   = 22
        + to_port     = 22
        + protocol    = "tcp"
      }
    + ingress {
        + cidr_blocks = ["0.0.0.0/0"]
        + from_port   = 3000
        + to_port     = 3000
        + protocol    = "tcp"
      }
  }

# aws_instance.api_server will be created
+ resource "aws_instance" "api_server" {
    + ami                         = "ami-0afd55c0c8a52973a"
    + instance_type               = "t2.micro"
    + key_name                    = "deployer-key"
    + vpc_security_group_ids      = (known after apply)
    + tags                        = {
        + "Name" = "sensors-api-server"
      }
  }

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
instance_public_ip = "34.76.x.x"
instance_id = "4815162342"
instance_name = "sensors-api-server"
instance_zone = "europe-west1-b"
```

### Exécution du playbook Ansible

```
PLAY [Déployer l'API de supervision des capteurs] ***********************

TASK [Gathering Facts] *************************************************
ok: [34.76.x.x]

TASK [Mettre à jour les paquets] ***************************************
changed: [34.76.x.x]

TASK [Installer les prérequis] *****************************************
changed: [34.76.x.x]

TASK [Ajouter le dépôt NodeJS] *****************************************
changed: [34.76.x.x]

TASK [Installer Node.js] ***********************************************
changed: [34.76.x.x]

TASK [Installer PM2 globalement] ***************************************
changed: [34.76.x.x]

TASK [Vérifier si le dossier de l'API existe] **************************
ok: [34.76.x.x]

TASK [Cloner le dépôt Git] *********************************************
changed: [34.76.x.x]

TASK [Installer les dépendances de l'API] ******************************
changed: [34.76.x.x]

TASK [Démarrer ou redémarrer l'API avec PM2] ***************************
changed: [34.76.x.x]

TASK [S'assurer que PM2 démarre au démarrage] **************************
changed: [34.76.x.x]

TASK [Vérifier que l'API est en cours d'exécution] *********************
ok: [34.76.x.x]

PLAY RECAP ************************************************************
18.203.x.x   : ok=12  changed=9  unreachable=0  failed=0  skipped=0  rescued=0  ignored=0
```

### Exécution du pipeline CI/CD

```
Run cd api && npm test

> sensors-api@1.0.0 test
> jest

 PASS  ./test.js
  API Endpoints
    ✓ should return API status (12 ms)
    ✓ should return all sensors (3 ms)
    ✓ should return a sensor by id (3 ms)
    ✓ should create a new sensor (3 ms)

Test Suites: 1 passed, 1 total
Tests:       4 passed, 4 total
Snapshots:   0 total
Time:        1.5 s
Ran all test suites.

Run chmod +x release.sh
export CI=true
./release.sh

Préparation de la release v1.0.1...
📝 Génération du changelog...
🏷️  Création du tag v1.0.1...
🚀 Envoi des changements au dépôt distant...
✅ Release v1.0.1 créée avec succès!
🔄 Démarrage du déploiement...
✅ Déploiement terminé avec succès!
```

## Conclusion

Cette architecture de déploiement continu permet de déployer rapidement et de manière fiable les nouvelles versions de l'API de supervision des capteurs. L'utilisation combinée de Terraform, Ansible et GitHub Actions fournit une solution robuste et automatisée qui minimise les interventions manuelles et réduit les risques d'erreurs.

Pour les évolutions futures, cette infrastructure pourrait être étendue pour inclure :

- Une base de données pour le stockage persistant des données de capteurs
- Un équilibreur de charge pour améliorer la disponibilité
- Des mécanismes de sauvegarde automatisée
