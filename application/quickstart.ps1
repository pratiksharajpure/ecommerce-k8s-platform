# Quick Start Script for E-Commerce Analytics Platform
# Run this to set up and start everything

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 E-Commerce Analytics Platform - Quick Start         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check Docker is running
Write-Host "📋 Step 1: Checking Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>$null
if (-not $dockerRunning) {
    Write-Host "❌ Docker is not running! Please start Docker Desktop." -ForegroundColor Red
    Write-Host "   1. Open Docker Desktop" -ForegroundColor Yellow
    Write-Host "   2. Wait for it to start" -ForegroundColor Yellow
    Write-Host "   3. Run this script again" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Docker is running!" -ForegroundColor Green
Write-Host ""

# Step 2: Check for port conflicts
Write-Host "📋 Step 2: Checking ports..." -ForegroundColor Yellow
$ports = @(3308, 8501, 8080, 6379)
$portsInUse = @()

foreach ($port in $ports) {
    $portInUse = netstat -ano | Select-String ":$port " | Select-Object -First 1
    if ($portInUse) {
        $portsInUse += $port
    }
}

if ($portsInUse.Count -gt 0) {
    Write-Host "⚠️  Warning: Some ports are in use: $($portsInUse -join ', ')" -ForegroundColor Yellow
    Write-Host "   This is OK if your local MySQL is on 3307 (Docker will use 3308)" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (yes/no)"
    if ($continue -ne "yes") {
        Write-Host "❌ Setup cancelled" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ All ports are available!" -ForegroundColor Green
}
Write-Host ""

# Step 3: Clean up old containers
Write-Host "📋 Step 3: Cleaning up old containers..." -ForegroundColor Yellow
docker-compose down -v 2>$null
Write-Host "✅ Cleanup complete!" -ForegroundColor Green
Write-Host ""

# Step 4: Create .env file if it doesn't exist
Write-Host "📋 Step 4: Creating environment file..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "✅ Created .env file from template" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}
Write-Host ""

# Step 5: Build and start services
Write-Host "📋 Step 5: Building and starting services..." -ForegroundColor Yellow
Write-Host "   This may take a few minutes on first run..." -ForegroundColor Cyan
docker-compose up -d --build

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ All services started!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to start services. Check errors above." -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 6: Wait for services to be healthy
Write-Host "📋 Step 6: Waiting for services to be healthy..." -ForegroundColor Yellow
Write-Host "   This may take 30-60 seconds..." -ForegroundColor Cyan

$maxWait = 120
$waited = 0
$allHealthy = $false

while ($waited -lt $maxWait -and -not $allHealthy) {
    Start-Sleep -Seconds 5
    $waited += 5
    
    $mysqlHealth = docker inspect ecommerce-mysql --format='{{.State.Health.Status}}' 2>$null
    $redisHealth = docker inspect ecommerce-redis --format='{{.State.Health.Status}}' 2>$null
    $streamlitHealth = docker inspect ecommerce-streamlit --format='{{.State.Health.Status}}' 2>$null
    
    Write-Host "   ⏳ MySQL: $mysqlHealth | Redis: $redisHealth | Streamlit: $streamlitHealth" -ForegroundColor Gray
    
    if ($mysqlHealth -eq "healthy" -and $redisHealth -eq "healthy") {
        $allHealthy = $true
    }
}

if ($allHealthy) {
    Write-Host "✅ All services are healthy!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Some services may still be starting..." -ForegroundColor Yellow
    Write-Host "   Check logs with: docker-compose logs -f" -ForegroundColor Yellow
}
Write-Host ""

# Step 7: Show access information
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ Setup Complete! Access your services:               ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Streamlit Dashboard:" -ForegroundColor Cyan
Write-Host "   http://localhost:8501" -ForegroundColor White
Write-Host ""
Write-Host "🗄️  phpMyAdmin (Database UI):" -ForegroundColor Cyan
Write-Host "   http://localhost:8080" -ForegroundColor White
Write-Host "   Username: root" -ForegroundColor Gray
Write-Host "   Password: rootpassword" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Service Status:" -ForegroundColor Cyan
docker-compose ps
Write-Host ""
Write-Host "💡 Useful Commands:" -ForegroundColor Cyan
Write-Host "   View logs:        docker-compose logs -f" -ForegroundColor Gray
Write-Host "   Stop services:    docker-compose down" -ForegroundColor Gray
Write-Host "   Restart:          docker-compose restart" -ForegroundColor Gray
Write-Host "   MySQL CLI:        docker exec -it ecommerce-mysql mysql -uroot -prootpassword" -ForegroundColor Gray
Write-Host ""
Write-Host "🎉 Happy analyzing! 🎉" -ForegroundColor Green
Write-Host ""

# Open browser automatically
$openBrowser = Read-Host "Open dashboard in browser? (yes/no)"
if ($openBrowser -eq "yes") {
    Start-Process "http://localhost:8501"
}