#!/bin/bash
# deploy-infrastructure.sh - Script pour déployer l'infrastructure et l'application

set -e  # Arrêt du script en cas d'erreur

echo "🚀 Démarrage du déploiement de l'infrastructure et de l'application..."

# Étape 1: Provisionner l'infrastructure avec Terraform
echo "1️⃣ Provisionnement de l'infrastructure avec Terraform..."
cd infra
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
cd ..

# Étape 2: Attendre que l'instance soit prête
echo "2️⃣ Attente de 30 secondes pour permettre à l'instance de démarrer..."
sleep 30

# Étape 3: Déployer l'application avec Ansible
echo "3️⃣ Déploiement de l'application avec Ansible..."
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ./ansible/inventory.ini ./ansible/deploy.yml

# Étape 4: Afficher les informations de connexion
echo "4️⃣ Récupération des informations de l'instance..."
cd infra
INSTANCE_IP=$(terraform output -raw instance_public_ip)
SSH_COMMAND=$(terraform output -raw ssh_command)
cd ..

echo "✅ Déploiement terminé avec succès !"
echo ""
echo "📌 Informations de l'instance :"
echo "   - Adresse IP : ${INSTANCE_IP}"
echo "   - API URL    : http://${INSTANCE_IP}:3000"
echo "   - SSH        : ${SSH_COMMAND}"
echo ""
echo "Pour vous connecter à l'instance via SSH :"
echo "   ${SSH_COMMAND}"
echo ""
echo "Pour tester l'API :"
echo "   curl http://${INSTANCE_IP}:3000"
