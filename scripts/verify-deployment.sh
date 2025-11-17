#!/bin/bash

echo "===================================="
echo "Kubernetes Deployment Health Check"
echo "E-commerce Analytics Platform"
echo "Student: Pratiksha Rajpure"
echo "===================================="
echo ""

echo "✓ Checking Cluster Status..."
kubectl cluster-info > /dev/null 2>&1 && echo "  ✅ Cluster is running" || echo "  ❌ Cluster is down"

echo ""
echo "✓ Checking Namespaces..."
kubectl get namespace dev > /dev/null 2>&1 && echo "  ✅ dev namespace exists" || echo "  ❌ dev namespace missing"

echo ""
echo "✓ Checking MySQL Deployment..."
MYSQL_READY=$(kubectl get pods -n dev -l app=mysql -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null)
[ "$MYSQL_READY" == "true" ] && echo "  ✅ MySQL pod is ready" || echo "  ❌ MySQL pod not ready"

echo ""
echo "✓ Checking Redis Deployment..."
REDIS_READY=$(kubectl get pods -n dev -l app=redis -o jsonpath='{.items[0].status.containerStatuses[0].ready}' 2>/dev/null)
[ "$REDIS_READY" == "true" ] && echo "  ✅ Redis pod is ready" || echo "  ❌ Redis pod not ready"

echo ""
echo "✓ Checking Streamlit App Deployment..."
APP_READY=$(kubectl get pods -n dev -l app=streamlit-app -o jsonpath='{.items[*].status.containerStatuses[*].ready}' 2>/dev/null | grep -o "true" | wc -l)
[ "$APP_READY" -ge "1" ] && echo "  ✅ Streamlit app pods are ready ($APP_READY running)" || echo "  ❌ Streamlit app pods not ready"

echo ""
echo "✓ Testing MySQL Connectivity..."
MYSQL_POD=$(kubectl get pods -n dev -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$MYSQL_POD" ]; then
  kubectl exec -n dev $MYSQL_POD -- mysql -u root -pRoot@123 -e "SELECT 1" > /dev/null 2>&1 && echo "  ✅ MySQL connection successful" || echo "  ❌ MySQL connection failed"
else
  echo "  ❌ MySQL pod not found"
fi

echo ""
echo "✓ Testing Redis Connectivity..."
REDIS_POD=$(kubectl get pods -n dev -l app=redis -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$REDIS_POD" ]; then
  REDIS_RESPONSE=$(kubectl exec -n dev $REDIS_POD -- redis-cli ping 2>/dev/null)
  [ "$REDIS_RESPONSE" == "PONG" ] && echo "  ✅ Redis connection successful" || echo "  ❌ Redis connection failed"
else
  echo "  ❌ Redis pod not found"
fi

echo ""
echo "✓ Checking Database Tables (11 tables expected)..."
if [ ! -z "$MYSQL_POD" ]; then
  TABLE_COUNT=$(kubectl exec -n dev $MYSQL_POD -- mysql -u root -pRoot@123 ecommerce_analytics -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='ecommerce_analytics';" 2>/dev/null | tail -n 1)
  [ "$TABLE_COUNT" == "11" ] && echo "  ✅ All 11 tables exist" || echo "  ⚠️  Only $TABLE_COUNT tables found (expected 11)"
fi

echo ""
echo "===================================="
echo "✅ Health Check Complete!"
echo "===================================="
echo ""
echo "Access your application:"
echo "kubectl port-forward -n dev svc/streamlit-service 8501:8501"