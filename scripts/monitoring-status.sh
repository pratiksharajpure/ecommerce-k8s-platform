#!/bin/bash
# Monitoring Stack Status Check for Killercoda

echo "=========================================="
echo "  MONITORING STACK STATUS (Killercoda)"
echo "=========================================="
echo ""

echo "📊 Prometheus Stack Pods:"
echo "----------------------------------------"
kubectl get pods -n monitoring -o wide

echo ""
echo "💾 Storage (PVCs) - Should use local-path:"
echo "----------------------------------------"
kubectl get pvc -n monitoring -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,CAPACITY:.status.capacity.storage,STORAGECLASS:.spec.storageClassName

echo ""
echo "🔌 Services:"
echo "----------------------------------------"
kubectl get svc -n monitoring

echo ""
echo "📡 ServiceMonitors:"
echo "----------------------------------------"
kubectl get servicemonitor --all-namespaces

echo ""
echo "🚨 PrometheusRules:"
echo "----------------------------------------"
kubectl get prometheusrule -n monitoring

echo ""
echo "=========================================="
echo "Access URLs (Killercoda Port-Forward):"
echo "=========================================="
echo ""
echo "Grafana:"
echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
echo "  Then: Killercoda Traffic → Port 3000"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo "Prometheus:"
echo "  kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090"
echo "  Then: Killercoda Traffic → Port 9090"
echo ""
echo "AlertManager:"
echo "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
echo "  Then: Killercoda Traffic → Port 9093"
echo ""
echo "⚠️  Remember: Keep port-forward terminals open!"
echo "=========================================="
