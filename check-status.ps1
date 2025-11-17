# Phase 2 Status Check Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   PHASE 2 STATUS CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Docker Images
Write-Host "`n=== Docker Images ===" -ForegroundColor Green
docker images | Select-String "ecommerce"

# Running Containers
Write-Host "`n=== Running Containers ===" -ForegroundColor Green
docker-compose --profile full-stack ps

# App Health
Write-Host "`n=== App Health Check ===" -ForegroundColor Green
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8501/_stcore/health" -TimeoutSec 5
    Write-Host "✅ Streamlit: HEALTHY" -ForegroundColor Green
} catch {
    Write-Host "❌ Streamlit: NOT RESPONDING" -ForegroundColor Red
}

# Database Test
Write-Host "`n=== Database Status ===" -ForegroundColor Green
try {
    $dbTest = docker exec ecommerce-mysql mysql -u root -pRoot@123 -e "SELECT 'Connected' as status;" 2>$null
    if ($dbTest -match "Connected") {
        Write-Host "✅ MySQL: CONNECTED" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ MySQL: NOT RESPONDING" -ForegroundColor Red
}

# Redis Test
Write-Host "`n=== Redis Status ===" -ForegroundColor Green
try {
    $redisTest = docker exec ecommerce-redis redis-cli ping 2>$null
    if ($redisTest -match "PONG") {
        Write-Host "✅ Redis: CONNECTED" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Redis: NOT RESPONDING" -ForegroundColor Red
}

Write-Host "`n=== Access URLs ===" -ForegroundColor Green
Write-Host "Streamlit App:  http://localhost:8501" -ForegroundColor Cyan
Write-Host "phpMyAdmin:     http://localhost:8080" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   STATUS CHECK COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
