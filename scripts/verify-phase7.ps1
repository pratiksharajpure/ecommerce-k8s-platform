# Phase 7 Verification
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PHASE 7 - MONITORING VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Checking kubectl..." -ForegroundColor Yellow
$kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
if ($kubectl) {
    Write-Host "kubectl found" -ForegroundColor Green
    kubectl get pods -n monitoring 2>$null
} else {
    Write-Host "kubectl not found - install before deploying" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Verification Complete!" -ForegroundColor Green
