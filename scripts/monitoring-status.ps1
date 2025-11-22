# Monitoring Status
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " MONITORING STACK STATUS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prometheus Stack Pods:" -ForegroundColor Yellow
kubectl get pods -n monitoring 2>$null
Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
kubectl get svc -n monitoring 2>$null
Write-Host ""
