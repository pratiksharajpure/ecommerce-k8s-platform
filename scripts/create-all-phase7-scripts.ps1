# Create All Phase 7 PowerShell Scripts
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " CREATE ALL PHASE 7 SCRIPTS" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Use full path to ensure correct location
$scriptsPath = Join-Path $PSScriptRoot "scripts"
if (-not (Test-Path $scriptsPath)) {
    $scriptsPath = ".\scripts"
}

# Script 1: test-powershell.ps1
Write-Host "Creating test-powershell.ps1..." -ForegroundColor Yellow
@'
# Test Script
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  POWERSHELL TEST SCRIPT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "PowerShell is working correctly!" -ForegroundColor Green
Write-Host ""
Write-Host "System Information:" -ForegroundColor Yellow
Write-Host "  PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host "  Current Directory: $(Get-Location)" -ForegroundColor White
Write-Host ""
if (Test-Path "scripts") { Write-Host "  scripts/ folder found" -ForegroundColor Green }
if (Test-Path "monitoring") { Write-Host "  monitoring/ folder found" -ForegroundColor Green }
if (Test-Path "application") { Write-Host "  application/ folder found" -ForegroundColor Green }
Write-Host ""
Write-Host "Test Complete!" -ForegroundColor Green
'@ | Out-File -FilePath (Join-Path $scriptsPath "test-powershell.ps1") -Encoding UTF8
Write-Host "  Created" -ForegroundColor Green

# Script 2: verify-phase7.ps1
Write-Host "Creating verify-phase7.ps1..." -ForegroundColor Yellow
@'
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
'@ | Out-File -FilePath (Join-Path $scriptsPath "verify-phase7.ps1") -Encoding UTF8
Write-Host "  Created" -ForegroundColor Green

# Script 3: monitoring-status.ps1
Write-Host "Creating monitoring-status.ps1..." -ForegroundColor Yellow
@'
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
'@ | Out-File -FilePath (Join-Path $scriptsPath "monitoring-status.ps1") -Encoding UTF8
Write-Host "  Created" -ForegroundColor Green

# Script 4: verify-app-updates.ps1
Write-Host "Creating verify-app-updates.ps1..." -ForegroundColor Yellow
@'
# Verify App Updates
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " VERIFY APPLICATION UPDATES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
if (Test-Path "application\Home.py") {
    Write-Host "Home.py exists" -ForegroundColor Green
    $content = Get-Content "application\Home.py" -Raw
    if ($content -match "prometheus") {
        Write-Host "Prometheus found in Home.py" -ForegroundColor Green
    } else {
        Write-Host "Prometheus NOT found - needs update" -ForegroundColor Yellow
    }
}
if (Test-Path "application\requirements.txt") {
    Write-Host "requirements.txt exists" -ForegroundColor Green
    $content = Get-Content "application\requirements.txt" -Raw
    if ($content -match "prometheus-client") {
        Write-Host "prometheus-client found" -ForegroundColor Green
    } else {
        Write-Host "prometheus-client missing - add it" -ForegroundColor Yellow
    }
}
Write-Host ""
'@ | Out-File -FilePath (Join-Path $scriptsPath "verify-app-updates.ps1") -Encoding UTF8
Write-Host "  Created" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ALL SCRIPTS CREATED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available scripts:" -ForegroundColor Yellow
Get-ChildItem (Join-Path $scriptsPath "*.ps1") | ForEach-Object {
    Write-Host "  $($_.Name)" -ForegroundColor White
}
Write-Host ""
Write-Host "Try running:" -ForegroundColor Yellow
Write-Host "  .\scripts\test-powershell.ps1" -ForegroundColor White
Write-Host ""