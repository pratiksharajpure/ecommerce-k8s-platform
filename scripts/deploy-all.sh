---

## 📁 **16. scripts/deploy-all.sh**
````bash
#!/bin/bash

echo "=========================================="
echo "  Kubernetes Deployment Script"
echo "  E-commerce Analytics Platform"
echo "  Student: Pratiksha Rajpure"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Step 1: Creating Namespaces...${NC}"
kubectl apply -f kubernetes/base/namespaces.yaml
echo ""

echo -e "${YELLOW}Step 2: Deploying MySQL...${NC}"
kubectl apply -f kubernetes/base/mysql-secret.yaml
kubectl apply -f kubernetes/base/mysql-init-scripts-configmap.yaml
kubectl apply -f kubernetes/base/mysql-initdb-configmap.yaml
kubectl apply -f kubernetes/base/mysql-pvc.yaml
kubectl apply -f kubernetes/base/mysql-deployment.yaml
kubectl apply -f kubernetes/base/mysql-service.yaml
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n dev --timeout=300s
echo ""

echo -e "${YELLOW}Step 3: Deploying Redis...${NC}"
kubectl apply -f kubernetes/base/redis-deployment.yaml
kubectl apply -f kubernetes/base/redis-service.yaml
echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app=redis -n dev --timeout=60s
echo ""

echo -e "${YELLOW}Step 4: Deploying Application...${NC}"
kubectl apply -f kubernetes/base/app-configmap.yaml
kubectl apply -f kubernetes/base/app-secret.yaml
kubectl apply -f kubernetes/base/app-deployment.yaml
kubectl apply -f kubernetes/base/app-service.yaml
echo "Waiting for Application to be ready..."
kubectl wait --for=condition=ready pod -l app=streamlit-app -n dev --timeout=180s
echo ""

echo -e "${GREEN}=========================================="
echo "✅ Deployment Complete!"
echo "==========================================${NC}"
echo ""

echo "Verifying deployment..."
kubectl get all -n dev
echo ""

echo "To access your application:"
echo "kubectl port-forward -n dev svc/streamlit-service 8501:8501"
echo ""

echo "Run health check:"
echo "./scripts/verify-deployment.sh"
````

---

## 📁 **17. scripts/export-manifests.sh**
````bash
#!/bin/bash

echo "=========================================="
echo "  Exporting Kubernetes Manifests"
echo "  E-commerce Analytics Platform"
echo "=========================================="
echo ""

mkdir -p kubernetes/base/exported/

# Export deployments
echo "Exporting deployments..."
kubectl get deployment mysql -n dev -o yaml > kubernetes/base/exported/mysql-deployment.yaml
kubectl get deployment redis -n dev -o yaml > kubernetes/base/exported/redis-deployment.yaml
kubectl get deployment streamlit-app -n dev -o yaml > kubernetes/base/exported/app-deployment.yaml

# Export services
echo "Exporting services..."
kubectl get svc mysql-service -n dev -o yaml > kubernetes/base/exported/mysql-service.yaml
kubectl get svc mysql-external -n dev -o yaml > kubernetes/base/exported/mysql-external-service.yaml
kubectl get svc redis-service -n dev -o yaml > kubernetes/base/exported/redis-service.yaml
kubectl get svc streamlit-service -n dev -o yaml > kubernetes/base/exported/app-service.yaml

# Export configmaps
echo "Exporting configmaps..."
kubectl get configmap app-config -n dev -o yaml > kubernetes/base/exported/app-configmap.yaml
kubectl get configmap mysql-initdb -n dev -o yaml > kubernetes/base/exported/mysql-initdb-configmap.yaml
kubectl get configmap mysql-init-scripts -n dev -o yaml > kubernetes/base/exported/mysql-init-scripts-configmap.yaml

# Export secrets (WARNING: These contain sensitive data!)
echo "Exporting secrets (be careful with these!)..."
kubectl get secret app-secret -n dev -o yaml > kubernetes/base/exported/app-secret.yaml
kubectl get secret mysql-secret -n dev -o yaml > kubernetes/base/exported/mysql-secret.yaml

# Export PVC
echo "Exporting PVC..."
kubectl get pvc mysql-pvc -n dev -o yaml > kubernetes/base/exported/mysql-pvc.yaml

# Export namespaces
echo "Exporting namespaces..."
kubectl get namespace dev -o yaml > kubernetes/base/exported/namespace-dev.yaml
kubectl get namespace staging -o yaml > kubernetes/base/exported/namespace-staging.yaml
kubectl get namespace production -o yaml > kubernetes/base/exported/namespace-production.yaml

echo ""
echo "✅ All manifests exported to kubernetes/base/exported/"
echo ""
echo "⚠️  WARNING: Secret files contain sensitive data!"
echo "   DO NOT commit them to Git without encryption!"
````

---

## 📁 **18. scripts/take-screenshots.sh**
````bash
#!/bin/bash

echo "=========================================="
echo "📸 Phase 3 Screenshot Guide"
echo "  E-commerce Analytics Platform"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Take these screenshots in order:${NC}"
echo ""

echo -e "${BLUE}=== CATEGORY 1: Cluster Setup ===${NC}"
echo "1. cluster-info.png"
echo "   Command: kubectl cluster-info && kubectl get nodes"
echo ""
read -p "Press Enter when screenshot is taken..."

echo "2. namespaces.png"
echo "   Command: kubectl get namespaces"
echo ""
read -p "Press Enter when screenshot is taken..."

echo "3. all-resources-overview.png"
echo "   Command: kubectl get all -n dev"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 2: Deployments ===${NC}"
echo "4. deployments-status.png"
echo "   Command: kubectl get deployments -n dev"
echo ""
read -p "Press Enter when screenshot is taken..."

echo "5. pods-status.png"
echo "   Command: kubectl get pods -n dev -o wide"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 3: Services ===${NC}"
echo "6. services-list.png"
echo "   Command: kubectl get svc -n dev"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 4: Storage ===${NC}"
echo "7. pvc-status.png"
echo "   Command: kubectl get pvc -n dev"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 5: Database Verification ===${NC}"

MYSQL_POD=$(kubectl get pods -n dev -l app=mysql -o jsonpath='{.items[0].metadata.name}')
echo "MySQL Pod: $MYSQL_POD"
echo ""

echo "8. tables-list.png (CRITICAL - Shows all 11 tables)"
echo "   Command: kubectl exec -n dev $MYSQL_POD -- mysql -u root -pRoot@123 ecommerce_analytics -e 'SHOW TABLES;'"
echo ""
read -p "Press Enter when screenshot is taken..."

echo "9. table-counts.png"
echo '   Command: kubectl exec -n dev $MYSQL_POD -- mysql -u root -pRoot@123 ecommerce_analytics -e "SELECT \"customers\", COUNT(*) FROM customers UNION ALL SELECT \"products\", COUNT(*) FROM products UNION ALL SELECT \"orders\", COUNT(*) FROM orders UNION ALL SELECT \"order_items\", COUNT(*) FROM order_items UNION ALL SELECT \"loyalty_program\", COUNT(*) FROM loyalty_program;"'
echo ""
read -p "Press Enter when screenshot is taken..."

echo "10. sample-data-query.png"
echo '   Command: kubectl exec -n dev $MYSQL_POD -- mysql -u root -pRoot@123 ecommerce_analytics -e "SELECT c.first_name, c.last_name, l.tier, l.points_earned FROM customers c LEFT JOIN loyalty_program l ON c.customer_id = l.customer_id LIMIT 5;"'
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 6: Redis Verification ===${NC}"

REDIS_POD=$(kubectl get pods -n dev -l app=redis -o jsonpath='{.items[0].metadata.name}')
echo "Redis Pod: $REDIS_POD"
echo ""

echo "11. redis-connection-test.png"
echo "   Command: kubectl exec -n dev $REDIS_POD -- redis-cli ping"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 7: Application Access ===${NC}"
echo "12. port-forward-command.png"
echo "   Command: kubectl port-forward -n dev svc/streamlit-service 8501:8501"
echo ""
echo "   NOTE: Run this command in another terminal, then take screenshot"
read -p "Press Enter when screenshot is taken..."

echo "13. application-homepage.png"
echo "   Open browser to http://localhost:8501 (or Killercoda Traffic tab)"
echo "   Take screenshot of the application homepage"
echo ""
read -p "Press Enter when screenshot is taken..."

echo "14. application-with-data.png"
echo "   Navigate to a page showing data (charts/tables)"
echo "   Take screenshot showing actual data from database"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 8: Logs & Health ===${NC}"
echo "15. app-logs.png"
echo "   Command: kubectl logs -n dev -l app=streamlit-app --tail=50"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${BLUE}=== CATEGORY 9: Testing ===${NC}"
echo "16. verification-script-output.png"
echo "   Command: ./scripts/verify-deployment.sh"
echo ""
read -p "Press Enter when screenshot is taken..."

echo "17. test-script-output.png"
echo "   Command: ./scripts/test-deployment.sh"
echo ""
read -p "Press Enter when screenshot is taken..."

echo ""
echo -e "${GREEN}=========================================="
echo "✅ Screenshot guide complete!"
echo "==========================================${NC}"
echo ""
echo "All screenshots should be saved in:"
echo "docs/screenshots/phase3/"
echo ""
echo "CRITICAL Screenshots (minimum required):"
echo "  - all-resources-overview.png"
echo "  - pods-status.png"
echo "  - tables-list.png (shows 11 tables)"
echo "  - table-counts.png (shows data)"
echo "  - application-homepage.png"
echo "  - verification-script-output.png"
````

---

## 📁 **19. scripts/cleanup.sh**
````bash
#!/bin/bash

echo "=========================================="
echo "  Kubernetes Cleanup Script"
echo "  E-commerce Analytics Platform"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}WARNING: This will delete all resources in dev namespace!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
  echo "Cleanup cancelled."
  exit 0
fi

echo ""
echo -e "${YELLOW}Deleting all resources in dev namespace...${NC}"

# Delete deployments
echo "Deleting deployments..."
kubectl delete deployment --all -n dev

# Delete services
echo "Deleting services..."
kubectl delete svc --all -n dev

# Delete configmaps
echo "Deleting configmaps..."
kubectl delete configmap --all -n dev

# Delete secrets
echo "Deleting secrets..."
kubectl delete secret --all -n dev

# Delete PVCs
echo "Deleting PVCs..."
kubectl delete pvc --all -n dev

echo ""
echo -e "${YELLOW}Optionally delete namespaces...${NC}"
read -p "Delete dev, staging, production namespaces? (yes/no): " delete_ns

if [ "$delete_ns" == "yes" ]; then
  echo "Deleting namespaces..."
  kubectl delete namespace dev staging production
fi

echo ""
echo "✅ Cleanup complete!"
````

---

## 📁 **20. scripts/database-backup.sh**
````bash
#!/bin/bash

echo "=========================================="
echo "  MySQL Database Backup Script"
echo "  E-commerce Analytics Platform"
echo "=========================================="
echo ""

# Get MySQL pod name
MYSQL_POD=$(kubectl get pods -n dev -l app=mysql -o jsonpath='{.items[0].metadata.name}')

if [ -z "$MYSQL_POD" ]; then
  echo "❌ MySQL pod not found!"
  exit 1
fi

echo "MySQL Pod: $MYSQL_POD"
echo ""

# Create backup directory
mkdir -p backups/
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backups/ecommerce_analytics_backup_${TIMESTAMP}.sql"

echo "Creating backup: $BACKUP_FILE"
echo ""

# Create backup
kubectl exec -n dev $MYSQL_POD -- mysqldump -u root -pRoot@123 ecommerce_analytics > $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "✅ Backup created successfully!"
  echo "File: $BACKUP_FILE"
  echo "Size: $(du -h $BACKUP_FILE | cut -f1)"
else
  echo "❌ Backup failed!"
  exit 1
fi

echo ""
echo "To restore this backup, use:"
echo "kubectl exec -i -n dev \$MYSQL_POD -- mysql -u root -pRoot@123 ecommerce_analytics < $BACKUP_FILE"
````

---

## 📁 **21. scripts/database-restore.sh**
````bash
#!/bin/bash

echo "=========================================="
echo "  MySQL Database Restore Script"
echo "  E-commerce Analytics Platform"
echo "=========================================="
echo ""

if [ -z "$1" ]; then
  echo "Usage: ./database-restore.sh <backup_file.sql>"
  echo ""
  echo "Available backups:"
  ls -lh backups/*.sql 2>/dev/null || echo "No backups found in backups/"
  exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Backup file not found: $BACKUP_FILE"
  exit 1
fi

# Get MySQL pod name
MYSQL_POD=$(kubectl get pods -n dev -l app=mysql -o jsonpath='{.items[0].metadata.name}')

if [ -z "$MYSQL_POD" ]; then
  echo "❌ MySQL pod not found!"
  exit 1
fi

echo "MySQL Pod: $MYSQL_POD"
echo "Backup File: $BACKUP_FILE"
echo ""

read -p "This will overwrite the current database. Continue? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
  echo "Restore cancelled."
  exit 0
fi

echo ""
echo "Restoring database..."

kubectl exec -i -n dev $MYSQL_POD -- mysql -u root -pRoot@123 ecommerce_analytics < $BACKUP_FILE

if [ $? -eq 0 ]; then
  echo "✅ Database restored successfully!"
else
  echo "❌ Restore failed!"
  exit 1
fi
````

---

## 📁 **22. .gitignore**