#!/bin/bash

# Check GitHub Actions Pipeline Status
# Usage: ./check-pipeline-status.sh

echo "=========================================="
echo " Checking GitHub Pipeline Status"
echo "=========================================="
echo ""

# Get repository name from Git
REPO_URL=$(git config --get remote.origin.url)

# Extract repo owner/name
# Works for: git@github.com:owner/repo.git AND https://github.com/owner/repo.git
REPO_PATH=$(echo "$REPO_URL" | sed -E 's/.*github\.com[/:]([^\.]+)(\.git)?/\1/')

echo "Repository: $REPO_PATH"

# --- REQUIRE GITHUB TOKEN ---
if [ -z "$GITHUB_TOKEN" ]; then
    echo ""
    echo "❌ ERROR: Missing GitHub token."
    echo "Please set it using:"
    echo "export GITHUB_TOKEN=your_token_here"
    echo ""
    exit 1
fi

echo ""
echo "✓ Fetching latest workflow run status..."

API_URL="https://api.github.com/repos/$REPO_PATH/actions/runs?per_page=1"

STATUS_RESPONSE=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" "$API_URL")

CONCLUSION=$(echo "$STATUS_RESPONSE" | grep -m1 '"conclusion"' | awk -F '"' '{print $4}')
STATUS=$(echo "$STATUS_RESPONSE" | grep -m1 '"status"' | awk -F '"' '{print $4}')
HTML_URL=$(echo "$STATUS_RESPONSE" | grep -m1 '"html_url"' | awk -F '"' '{print $4}')

echo ""
echo "Latest Run Status: $STATUS"
echo "Conclusion:       $CONCLUSION"

if [ "$CONCLUSION" == "success" ]; then
    echo "  ✅ Pipeline Success!"
elif [ "$CONCLUSION" == "failure" ]; then
    echo "  ❌ Pipeline Failed!"
elif [ "$CONCLUSION" == "cancelled" ]; then
    echo "  ⚠️  Pipeline Cancelled!"
else
    echo "  ⏳ Pipeline still running or no recent runs."
fi

echo ""
echo "View Details:"
echo "$HTML_URL"

echo ""
echo "=========================================="
echo " Pipeline Status Check Complete"
echo "=========================================="
