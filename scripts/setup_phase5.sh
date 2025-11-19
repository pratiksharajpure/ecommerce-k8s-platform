#!/bin/bash

# Phase 5 Setup Script - Creates all necessary directories and files

echo "=========================================="
echo "Phase 5: CI/CD Pipeline Setup"
echo "=========================================="

cd ~/Desktop/ecommerce-k8s-platform

# Create directory structure
echo "Creating directory structure..."
mkdir -p .github/workflows
mkdir -p .github/scripts
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/smoke
mkdir -p scripts
mkdir -p docs

echo "✅ Directories created!"

# Make scripts executable
echo ""
echo "Making scripts executable..."
chmod +x tests/run_tests.sh
chmod +x scripts/trigger-pipeline.sh
chmod +x scripts/verify-deployment.sh

echo "✅ Scripts are executable!"

echo ""
echo "=========================================="
echo "Directory Structure Created:"
echo "=========================================="
tree -L 3 .github/ tests/ scripts/ 2>/dev/null || find .github/ tests/ scripts/ -type d

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Copy all workflow files to .github/workflows/"
echo "2. Copy test files to tests/unit/"
echo "3. Copy script files to scripts/"
echo "4. Configure GitHub Secrets:"
echo "   - DOCKERHUB_USERNAME"
echo "   - DOCKERHUB_TOKEN"
echo "5. Create GitHub Environments:"
echo "   - development"
echo "   - staging"
echo "   - production"
echo "6. Commit and push to trigger pipeline!"
echo ""
echo "=========================================="