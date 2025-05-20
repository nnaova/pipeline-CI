#!/bin/bash
# Script de release pour l'API de supervision des capteurs

set -e  # Arrêt du script en cas d'erreur

# Variables
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
NEXT_VERSION=""
CHANGELOG_FILE="CHANGELOG.md"

# Fonction pour générer le nouveau numéro de version
increment_version() {
  local version=$1
  version=${version#v}  # Supprimer le préfixe 'v' s'il existe
  
  # Extraire les composants de la version (majeur.mineur.patch)
  IFS='.' read -r -a version_parts <<< "$version"
  
  local major=${version_parts[0]:-0}
  local minor=${version_parts[1]:-0}
  local patch=${version_parts[2]:-0}
  
  # Incrémenter le numéro de patch
  patch=$((patch + 1))
  
  echo "v$major.$minor.$patch"
}

# Générer le prochain numéro de version
NEXT_VERSION=$(increment_version "$CURRENT_VERSION")

echo "Préparation de la release $NEXT_VERSION..."

# Vérifier que la branche est propre (aucun changement non commité)
if [[ -n $(git status --porcelain) ]]; then
  echo "❌ Erreur: Des changements non commités ont été détectés. Veuillez commiter tous vos changements avant de créer une release."
  exit 1
fi

# Générer le changelog
echo "📝 Génération du changelog..."
if [ ! -f "$CHANGELOG_FILE" ]; then
  echo "# Changelog" > "$CHANGELOG_FILE"
  echo "" >> "$CHANGELOG_FILE"
fi

# Insérer les changements depuis la dernière version
{
  echo "## $NEXT_VERSION ($(date +%Y-%m-%d))"
  echo ""
  git log --pretty=format:"* %s" "$CURRENT_VERSION"..HEAD
  echo ""
  echo ""
  cat "$CHANGELOG_FILE"
} > "$CHANGELOG_FILE.tmp"
mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"

# Commiter les changements du changelog
git add "$CHANGELOG_FILE"
git commit -m "chore: mise à jour du changelog pour $NEXT_VERSION"

# Créer un tag pour la nouvelle version
echo "🏷️  Création du tag $NEXT_VERSION..."
git tag -a "$NEXT_VERSION" -m "Release $NEXT_VERSION"

# Pousser le commit et le tag
echo "🚀 Envoi des changements au dépôt distant..."
git push && git push origin "$NEXT_VERSION"

echo "✅ Release $NEXT_VERSION créée avec succès!"

# Si le script est exécuté en mode CI, déployer l'application
if [ "$CI" = "true" ]; then
  echo "🔄 Démarrage du déploiement..."
  
  # S'assurer que l'inventaire Ansible existe
  if [ ! -f "./ansible/inventory.ini" ]; then
    echo "❌ Erreur: Fichier d'inventaire Ansible introuvable."
    exit 1
  fi
  
  # Vérifier que le projet GCP est bien configuré
  if [ -n "$GOOGLE_PROJECT" ]; then
    echo "🔍 Utilisation du projet GCP: $GOOGLE_PROJECT"
  fi
  
  # Exécuter le playbook Ansible
  ansible-playbook -i ./ansible/inventory.ini ./ansible/deploy.yml
  
  echo "✅ Déploiement terminé avec succès!"
fi

exit 0
