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
