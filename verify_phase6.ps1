# Phase 6 Verification Script

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "PHASE 6 - ARGOCD & GITOPS VERIFICATION" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking ArgoCD installation..." -ForegroundColor Yellow
kubectl get pods -n argocd

Write-Host "`nChecking ArgoCD applications..." -ForegroundColor Yellow
kubectl get applications -n argocd

Write-Host "`nChecking deployed applications..." -ForegroundColor Yellow
foreach ($ns in @("dev", "staging", "production")) {
    Write-Host "  Namespace: $ns" -ForegroundColor Cyan
    kubectl get pods -n $ns 2>$null
}

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "ArgoCD Access (Killercoda):" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "1. Port forward:"
Write-Host "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
Write-Host ""
Write-Host "2. Get password:"
Write-Host "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
Write-Host ""
Write-Host "3. Login with username: admin"
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "VERIFICATION COMPLETE!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
