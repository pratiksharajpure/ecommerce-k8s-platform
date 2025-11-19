#!/bin/bash

echo "===================================="
echo "Kubernetes Deployment Health Check"
echo "E-commerce Analytics Platform"
echo "Student: Pratiksha Rajpure"
echo "===================================="
echo ""

echo "✓ Checking Cluster Status..."
if kubectl cluster-info > /dev/null 2>&1; then
    echo "  ✅ Cluster is running"
else
    echo "  ❌ Cluster is down"
fi

echo ""
echo "✓ Checking Namespaces..."
if kubectl get namespace dev > /dev/null 2>&1; then
    echo "  ✅ dev namespace exists"
else
    echo "  ❌ dev namespace missing"
fi

echo ""
echo "✓ Checking MySQL Deployment..."
MYSQL_READY=$(kubectl get pods -n dev -l app=mysql -o jsonpath="{.items[0].status.containerStatuses[0].ready}" 2>/dev/null)
if [ "$MYSQL_READY" = "true" ]; then
    echo "  ✅ MySQL pod is ready"
else
    echo "  ❌ MySQL pod not ready"
fi

echo ""
echo "✓ Checking Redis Deployment..."
REDIS_READY=$(kubectl get pods -n dev -l app=redis -o jsonpath="{.items[0].status.containerStatuses[0].ready}" 2>/dev/null)
if [ "$REDIS_READY" = "true" ]; then
    echo "  ✅ Redis pod is ready"
else
    echo "  ❌ Redis pod not ready"
fi

echo ""
echo "✓ Checking Streamlit App Deployment..."
APP_READY=$(kubectl get pods -n dev -l app=streamlit-app -o jsonpath="{.items[*].status.containerStatuses[*].ready}" \
            2>/dev/null | grep -o "true" | wc -l)

if [ "$APP_READY" -ge 1 ]; then
    echo "  ✅ Streamlit app pods are ready ($APP_READY running)"
else
    echo "  ❌ Streamlit app pods not ready"
fi

echo ""
echo "✓ Testing MySQL Connectivity..."
MYSQL_POD=$(kubectl get pods -n dev -l app=mysql -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ -n "$MYSQL_POD" ]; then
    if kubectl exec -n dev "$MYSQL_POD" -- mysql -u root -pRoot@123 -e "SELECT 1" > /dev/null 2>&1; then
        echo "  ✅ MySQL connection successful"
    else
        echo "  ❌ MySQL connection failed"
    fi
else
    echo "  ❌ MySQL pod not found"
fi

echo ""
echo "✓ Testing Redis Connectivity..."
REDIS_POD=$(kubectl get pods -n dev -l app=redis -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
if [ -n "$REDIS_POD" ]; then
    REDIS_RESPONSE=$(kubectl exec -n dev "$REDIS_POD" -- redis-cli ping 2>/dev/null)
    if [ "$REDIS_RESPONSE" = "PONG" ]; then
        echo "  ✅ Redis connection successful"
    else
        echo "  ❌ Redis connection failed"
    fi
else
    echo "  ❌ Redis pod not found"
fi

echo ""
echo "✓ Checking Database Tables (11 expected)..."
if [ -n "$MYSQL_POD" ]; then
    TABLE_COUNT=$(kubectl exec -n dev "$MYSQL_POD" \
        -- mysql -u root -pRoot@123 ecommerce_analytics \
        -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='ecommerce_analytics';" \
        2>/dev/null | tail -n 1)
    if [ "$TABLE_COUNT" = "11" ]; then
        echo "  ✅ All 11 tables exist"
    else
        echo "  ⚠️  Only $TABLE_COUNT tables found (expected 11)"
    fi
fi

echo ""
echo "===================================="
echo "✅ Health Check Complete!"
echo "===================================="
echo ""
echo "Run to access the app:"
echo "kubectl port-forward -n dev svc/streamlit-service 8501:8501"
