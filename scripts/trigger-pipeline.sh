#!/bin/bash

# Trigger CI/CD Pipeline
# Usage: ./trigger-pipeline.sh [commit-message]

MESSAGE=${1:-"chore: Trigger pipeline"}

echo "=========================================="
echo "Triggering CI/CD Pipeline"
echo "=========================================="
echo "Commit message: $MESSAGE"
echo ""

# Check if there are changes
if git diff-index --quiet HEAD --; then
    echo "No changes to commit. Creating empty commit..."
    git commit --allow-empty -m "$MESSAGE"
else
    echo "Committing changes..."
    git add .
    git commit -m "$MESSAGE"
fi

echo ""
echo "Pushing to main branch..."
git push origin main

echo ""
echo "✅ Pipeline triggered!"

# Extract repo path safely for Windows
REPO_URL=$(git config --get remote.origin.url)
REPO_PATH=$(echo "$REPO_URL" | sed -E 's/.*github\.com[/:]([^\.]+)(\.git)?/\1/')

echo "View at: https://github.com/$REPO_PATH/actions"
