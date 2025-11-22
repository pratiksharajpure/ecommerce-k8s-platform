#!/bin/bash
# Test Alert Rules for Killercoda

echo "=========================================="
echo "  TESTING ALERT RULES (Killercoda)"
echo "=========================================="
echo ""

echo "📋 Checking active alerts..."
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090 &
PF_PID=$!
sleep 3

# Query Prometheus for active alerts
curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts[] | {name:.labels.alertname, state:.state, value:.value}'

# Kill port forward
kill $PF_PID

echo ""
echo "=========================================="
echo "To view alerts in Killercoda browser:"
echo "  kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090"
echo "  Then: Killercoda Traffic → Port 9090"
echo "  Navigate to: /alerts"
echo "=========================================="
