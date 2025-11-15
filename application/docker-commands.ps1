# docker-commands.ps1
# Easy Docker commands for E-Commerce Analytics Platform
# Usage: .\docker-commands.ps1 <command>

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

function Show-Help {
    Write-Host "🐳 E-Commerce Analytics - Docker Commands" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\docker-commands.ps1 <command>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Green
    Write-Host "  start        - Start all services"
    Write-Host "  stop         - Stop all services"
    Write-Host "  restart      - Restart all services"
    Write-Host "  build        - Rebuild and start services"
    Write-Host "  logs         - Show all logs"
    Write-Host "  logs-app     - Show Streamlit app logs"
    Write-Host "  logs-db      - Show MySQL logs"
    Write-Host "  status       - Show service status"
    Write-Host "  clean        - Remove all containers and volumes"
    Write-Host "  mysql        - Connect to MySQL CLI"
    Write-Host "  shell        - Open bash in Streamlit container"
    Write-Host "  check        - Health check all services"
    Write-Host "  help         - Show this help message"
    Write-Host ""
}

switch ($Command) {
    "start" {
        Write-Host "🚀 Starting all services..." -ForegroundColor Green
        docker-compose up -d
        Write-Host "✅ Services started!" -ForegroundColor Green
        Write-Host "📊 Dashboard: http://localhost:8501" -ForegroundColor Cyan
        Write-Host "🗄️  phpMyAdmin: http://localhost:8080" -ForegroundColor Cyan
    }
    
    "stop" {
        Write-Host "🛑 Stopping all services..." -ForegroundColor Yellow
        docker-compose down
        Write-Host "✅ Services stopped!" -ForegroundColor Green
    }
    
    "restart" {
        Write-Host "🔄 Restarting all services..." -ForegroundColor Yellow
        docker-compose restart
        Write-Host "✅ Services restarted!" -ForegroundColor Green
    }
    
    "build" {
        Write-Host "🔨 Rebuilding and starting services..." -ForegroundColor Yellow
        docker-compose up -d --build
        Write-Host "✅ Build complete!" -ForegroundColor Green
    }
    
    "logs" {
        Write-Host "📋 Showing all logs (Ctrl+C to exit)..." -ForegroundColor Cyan
        docker-compose logs -f
    }
    
    "logs-app" {
        Write-Host "📋 Showing Streamlit app logs (Ctrl+C to exit)..." -ForegroundColor Cyan
        docker-compose logs -f streamlit-app
    }
    
    "logs-db" {
        Write-Host "📋 Showing MySQL logs (Ctrl+C to exit)..." -ForegroundColor Cyan
        docker-compose logs -f mysql
    }
    
    "status" {
        Write-Host "📊 Service Status:" -ForegroundColor Cyan
        docker-compose ps
    }
    
    "clean" {
        Write-Host "🧹 Cleaning up (removing containers and volumes)..." -ForegroundColor Red
        $confirm = Read-Host "Are you sure? This will delete all data! (yes/no)"
        if ($confirm -eq "yes") {
            docker-compose down -v
            docker system prune -f
            Write-Host "✅ Cleanup complete!" -ForegroundColor Green
        } else {
            Write-Host "❌ Cleanup cancelled" -ForegroundColor Yellow
        }
    }
    
    "mysql" {
        Write-Host "🗄️  Connecting to MySQL CLI..." -ForegroundColor Cyan
        docker exec -it ecommerce-mysql mysql -uroot -prootpassword ecommerce_analytics
    }
    
    "shell" {
        Write-Host "💻 Opening bash shell in Streamlit container..." -ForegroundColor Cyan
        docker exec -it ecommerce-streamlit bash
    }
    
    "check" {
        Write-Host "🔍 Health Check:" -ForegroundColor Cyan
        Write-Host ""
        
        # Check MySQL
        $mysqlHealth = docker inspect ecommerce-mysql --format='{{.State.Health.Status}}' 2>$null
        if ($mysqlHealth -eq "healthy") {
            Write-Host "✅ MySQL: Healthy" -ForegroundColor Green
        } else {
            Write-Host "❌ MySQL: $mysqlHealth" -ForegroundColor Red
        }
        
        # Check Redis
        $redisHealth = docker inspect ecommerce-redis --format='{{.State.Health.Status}}' 2>$null
        if ($redisHealth -eq "healthy") {
            Write-Host "✅ Redis: Healthy" -ForegroundColor Green
        } else {
            Write-Host "❌ Redis: $redisHealth" -ForegroundColor Red
        }
        
        # Check Streamlit
        $streamlitHealth = docker inspect ecommerce-streamlit --format='{{.State.Health.Status}}' 2>$null
        if ($streamlitHealth -eq "healthy") {
            Write-Host "✅ Streamlit: Healthy" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Streamlit: $streamlitHealth" -ForegroundColor Yellow
        }
        
        # Check phpMyAdmin
        $phpmyadminStatus = docker inspect ecommerce-phpmyadmin --format='{{.State.Status}}' 2>$null
        if ($phpmyadminStatus -eq "running") {
            Write-Host "✅ phpMyAdmin: Running" -ForegroundColor Green
        } else {
            Write-Host "❌ phpMyAdmin: $phpmyadminStatus" -ForegroundColor Red
        }
        
        Write-Host ""
        Write-Host "🌐 Access Points:" -ForegroundColor Cyan
        Write-Host "   Streamlit:  http://localhost:8501" -ForegroundColor White
        Write-Host "   phpMyAdmin: http://localhost:8080" -ForegroundColor White
    }
    
    "help" {
        Show-Help
    }
    
    default {
        Write-Host "❌ Unknown command: $Command" -ForegroundColor Red
        Write-Host ""
        Show-Help
    }
}