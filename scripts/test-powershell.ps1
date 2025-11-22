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
