#!/bin/bash

echo "=========================================="
echo "PHASE 7 - MONITORING VERIFICATION"
echo "(Killercoda Edition)"
echo "=========================================="
echo ""

echo "✓ Checking Prometheus Stack installation..."
kubectl get pods -n monitoring

echo ""
echo "✓ Checking storage (PVCs) - Should use local-path..."
kubectl get pvc -n monitoring -o custom-columns=NAME:.metadata.name,STORAGECLASS:.spec.storageClassName,STATUS:.status.phase

echo ""
echo "✓ Checking services..."
kubectl get svc -n monitoring | grep -E "grafana|prometheus|alertmanager"

echo ""
echo "✓ Checking ServiceMonitors..."
kubectl get servicemonitor --all-namespaces

echo ""
echo "✓ Checking PrometheusRules..."
kubectl get prometheusrule -n monitoring

echo ""
echo "✓ Testing Prometheus accessibility..."
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090 &
PF_PID=$!
sleep 3
PROM_STATUS=$(curl -s http://localhost:9090/-/healthy)
kill $PF_PID

if [ "$PROM_STATUS" == "Prometheus is Healthy." ]; then
    echo "  ✅ Prometheus is healthy"
else
    echo "  ❌ Prometheus health check failed"
fi

echo ""
echo "✓ Testing Grafana accessibility..."
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &
PF_PID=$!
sleep 3
GRAFANA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
kill $PF_PID

if [ "$GRAFANA_STATUS" == "200" ]; then
    echo "  ✅ Grafana is accessible"
else
    echo "  ❌ Grafana health check failed"
fi

echo ""
echo "=========================================="
echo "Quick Access Commands (Killercoda):"
echo "=========================================="
echo ""
echo "Open all monitoring tools:"
echo "  ./scripts/open-monitoring.sh"
echo ""
echo "Check monitoring status:"
echo "  ./scripts/monitoring-status.sh"
echo ""
echo "Collect current metrics:"
echo "  ./scripts/collect-metrics.sh"
echo ""
echo "Test alerts:"
echo "  ./scripts/test-alerts.sh"
echo ""
echo "=========================================="
echo "⚠️  Killercoda Reminders:"
echo "=========================================="
echo "• Use port-forward for ALL access (no NodePort)"
echo "• Keep port-forward terminals open"
echo "• Use Killercoda Traffic button → Select port"
echo "• Sessions expire - save your work!"
echo "• Storage class is local-path"
echo "• Monitor resources: kubectl top nodes/pods"
echo "=========================================="
echo "VERIFICATION COMPLETE!"
echo "=========================================="

# Phase 7 - Monitoring Verification Script
# PowerShell version for Windows

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "PHASE 7 - MONITORING VERIFICATION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    $null -ne (Get-Command $command -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow
if (-not (Test-CommandExists kubectl)) {
    Write-Host "❌ kubectl not found. Please install kubectl first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ kubectl found" -ForegroundColor Green
Write-Host ""

# Check Prometheus Stack installation
Write-Host "✓ Checking Prometheus Stack installation..." -ForegroundColor Yellow
kubectl get pods -n monitoring
Write-Host ""

# Check storage (PVCs)
Write-Host "✓ Checking storage (PVCs)..." -ForegroundColor Yellow
kubectl get pvc -n monitoring
Write-Host ""

# Check services
Write-Host "✓ Checking services..." -ForegroundColor Yellow
kubectl get svc -n monitoring | Select-String -Pattern "grafana|prometheus|alertmanager"
Write-Host ""

# Check ServiceMonitors
Write-Host "✓ Checking ServiceMonitors..." -ForegroundColor Yellow
kubectl get servicemonitor --all-namespaces
Write-Host ""

# Check PrometheusRules
Write-Host "✓ Checking PrometheusRules..." -ForegroundColor Yellow
kubectl get prometheusrule -n monitoring
Write-Host ""

# Test Prometheus accessibility
Write-Host "✓ Testing Prometheus accessibility..." -ForegroundColor Yellow
$promJob = Start-Job -ScriptBlock {
    kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
}
Start-Sleep -Seconds 3

try {
    $promResponse = Invoke-WebRequest -Uri "http://localhost:9090/-/healthy" -TimeoutSec 5 -UseBasicParsing
    if ($promResponse.Content -like "*Prometheus is Healthy*") {
        Write-Host "  ✅ Prometheus is healthy" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Prometheus health check failed" -ForegroundColor Red
    }
} catch {
    Write-Host "  ⚠️  Could not connect to Prometheus (may need more time to start)" -ForegroundColor Yellow
}

Stop-Job $promJob
Remove-Job $promJob
Write-Host ""

# Test Grafana accessibility
Write-Host "✓ Testing Grafana accessibility..." -ForegroundColor Yellow
$grafanaJob = Start-Job -ScriptBlock {
    kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
}
Start-Sleep -Seconds 3

try {
    $grafanaResponse = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 5 -UseBasicParsing
    if ($grafanaResponse.StatusCode -eq 200) {
        Write-Host "  ✅ Grafana is accessible" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Grafana health check failed" -ForegroundColor Red
    }
} catch {
    Write-Host "  ⚠️  Could not connect to Grafana (may need more time to start)" -ForegroundColor Yellow
}

Stop-Job $grafanaJob
Remove-Job $grafanaJob
Write-Host ""

# Summary
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Quick Access Commands:" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open all monitoring tools:" -ForegroundColor White
Write-Host "  .\scripts\open-monitoring.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Check monitoring status:" -ForegroundColor White
Write-Host "  .\scripts\monitoring-status.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Collect current metrics:" -ForegroundColor White
Write-Host "  .\scripts\collect-metrics.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Test alerts:" -ForegroundColor White
Write-Host "  .\scripts\test-alerts.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "Access Grafana manually:" -ForegroundColor White
Write-Host "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80" -ForegroundColor Gray
Write-Host "  Then open: http://localhost:3000" -ForegroundColor Gray
Write-Host "  Username: admin | Password: admin123" -ForegroundColor Gray
Write-Host ""
Write-Host "Access Prometheus manually:" -ForegroundColor White
Write-Host "  kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090" -ForegroundColor Gray
Write-Host "  Then open: http://localhost:9090" -ForegroundColor Gray
Write-Host ""
Write-Host "Access AlertManager manually:" -ForegroundColor White
Write-Host "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093" -ForegroundColor Gray
Write-Host "  Then open: http://localhost:9093" -ForegroundColor Gray
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan