# Local Development Guide

## Prerequisites

### Required Software
- **Docker Desktop** (v20.10+): [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (v2.0+): Included with Docker Desktop
- **Git**: For cloning the repository
- **PowerShell** (Windows) or Bash (Linux/Mac)

### System Requirements
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: 10GB free space
- **CPU**: 2+ cores recommended

### Required Ports
Ensure these ports are available on your machine:
- `3306` - MySQL Database
- `6379` - Redis Cache
- `8501` - Streamlit Application
- `8080` - phpMyAdmin (optional)

---

## Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/pratiksha3/ecommerce-k8s-platform.git
cd ecommerce-k8s-platform/application
```

### 2. Verify Prerequisites
```powershell
# Check Docker is running
docker --version
docker-compose --version

# Check available ports
netstat -ano | findstr :3306
netstat -ano | findstr :6379
netstat -ano | findstr :8501
netstat -ano | findstr :8080
```

### 3. Start All Services
```powershell
# Start with full-stack profile (MySQL in Docker)
docker-compose --profile full-stack up -d

# Wait for services to be healthy (2-3 minutes)
docker-compose --profile full-stack ps
```

### 4. Initialize Database
```powershell
# Create tables
Get-Content .\sql\setup\create_tables.sql | docker exec -i ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics

# Create indexes
Get-Content .\sql\setup\create_indexes.sql | docker exec -i ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics

# Verify tables
docker exec ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics -e "SHOW TABLES;"
```

### 5. Access Applications
- **Streamlit App**: http://localhost:8501
- **phpMyAdmin**: http://localhost:8080
  - Server: `mysql`
  - Username: `root`
  - Password: `Root@123`

---

## Development Modes

### Mode 1: Full-Stack (Recommended for Testing)
All services run in Docker containers.

```powershell
# Start
docker-compose --profile full-stack up -d

# Check status
docker-compose --profile full-stack ps

# View logs
docker-compose --profile full-stack logs -f

# Stop
docker-compose --profile full-stack down
```

**Use when:**
- You want a complete isolated environment
- Testing production-like setup
- Don't have MySQL installed locally
- Sharing setup with team members

### Mode 2: Dev Mode (For Active Development)
Uses host MySQL, enables hot-reload for code changes.

```powershell
# Ensure MySQL is running on host
net start MySQL80

# Start dev services
docker-compose --profile dev up -d

# Code changes auto-reload (no rebuild needed)
```

**Use when:**
- Actively developing Streamlit code
- Want fast iteration cycles
- Already have MySQL on your machine
- Need to debug database directly

---

## Common Tasks

### View Logs
```powershell
# All services
docker-compose --profile full-stack logs -f

# Specific service
docker logs -f ecommerce-mysql
docker logs -f ecommerce-streamlit-prod
docker logs -f ecommerce-redis
```

### Database Operations
```powershell
# Connect to MySQL CLI
docker exec -it ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics

# Run SQL query
docker exec ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics -e "SELECT COUNT(*) FROM customers;"

# Import data
Get-Content .\data\sample_data.sql | docker exec -i ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics

# Export database
docker exec ecommerce-mysql mysqldump -u root -pRoot@123 ecommerce_analytics > backup.sql

# Backup database
docker exec ecommerce-mysql mysqldump -u root -pRoot@123 --all-databases > full_backup.sql
```

### Redis Operations
```powershell
# Connect to Redis CLI
docker exec -it ecommerce-redis redis-cli

# Check Redis keys
docker exec ecommerce-redis redis-cli KEYS '*'

# Flush Redis cache
docker exec ecommerce-redis redis-cli FLUSHALL
```

### Restart Services
```powershell
# Restart all
docker-compose --profile full-stack restart

# Restart specific service
docker-compose restart ecommerce-streamlit-prod
docker restart ecommerce-mysql
```

### Rebuild Application
```powershell
# Stop services
docker-compose --profile full-stack down

# Rebuild Streamlit app
docker-compose --profile full-stack build --no-cache

# Start with new build
docker-compose --profile full-stack up -d
```

---

## Troubleshooting

### Issue: Port Already in Use
**Error:** `bind: Only one usage of each socket address is normally permitted`

**Solution:**
```powershell
# Find process using the port
netstat -ano | findstr :3306

# Kill the process (replace PID)
taskkill /PID <PID> /F

# Or stop your local MySQL
net stop MySQL80
```

### Issue: MySQL Container Unhealthy
**Error:** `container ecommerce-mysql is unhealthy`

**Solution:**
```powershell
# Check logs
docker logs ecommerce-mysql --tail 50

# Remove corrupted volume
docker-compose --profile full-stack down -v
docker volume rm application_mysql_data

# Restart fresh
docker-compose --profile full-stack up -d
```

### Issue: Streamlit Not Starting
**Error:** `dependency failed to start`

**Solution:**
```powershell
# Check if MySQL is healthy first
docker-compose --profile full-stack ps

# Wait for MySQL (it takes 2-3 minutes on first start)
docker logs -f ecommerce-mysql

# Once you see "ready for connections", restart Streamlit
docker-compose restart ecommerce-streamlit-prod
```

### Issue: Code Changes Not Reflecting
**Problem:** Updated code but app shows old version

**Solution (Full-Stack Mode):**
```powershell
# Rebuild the image
docker-compose --profile full-stack build

# Restart with new image
docker-compose --profile full-stack up -d
```

**Solution (Dev Mode):**
```powershell
# Dev mode should auto-reload
# If not, check volume mounts in docker-compose.yml
docker-compose --profile dev restart streamlit-app-dev
```

### Issue: Permission Denied Errors
**Error:** `Permission denied` when accessing files

**Solution:**
```powershell
# Windows: Run PowerShell as Administrator
# Or adjust file permissions
icacls .\sql /grant Everyone:F /T
```

### Issue: Out of Disk Space
**Error:** `no space left on device`

**Solution:**
```powershell
# Clean up unused Docker resources
docker system prune -a --volumes

# Remove old images
docker images | grep ecommerce-app | awk '{print $3}' | xargs docker rmi

# Check disk usage
docker system df
```

---

## Testing

### Manual Testing Checklist
- [ ] All containers start successfully
- [ ] Streamlit app loads at http://localhost:8501
- [ ] phpMyAdmin accessible at http://localhost:8080
- [ ] Database tables exist and have correct schema
- [ ] Can insert/query data in MySQL
- [ ] Redis cache is working
- [ ] Application pages load without errors

### Automated Tests
```powershell
# Run tests (if you have test suite)
docker-compose --profile full-stack run --rm streamlit-app-prod pytest tests/

# Health checks
curl http://localhost:8501/_stcore/health
curl http://localhost:8080/
```

### Performance Testing
```powershell
# Check resource usage
docker stats

# Check MySQL performance
docker exec ecommerce-mysql mysql -u root -pRoot@123 -e "SHOW PROCESSLIST;"

# Check Redis memory
docker exec ecommerce-redis redis-cli INFO memory
```

---

## Environment Variables

### MySQL Configuration
```env
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_DATABASE=ecommerce_analytics
MYSQL_USER=root
MYSQL_PASSWORD=Root@123
```

### Redis Configuration
```env
REDIS_HOST=redis
REDIS_PORT=6379
```

### Application Settings
```env
APP_ENV=development
STREAMLIT_SERVER_PORT=8501
PYTHONUNBUFFERED=1
```

### Customizing Variables
Edit `docker-compose.yml` environment section:
```yaml
environment:
  DB_HOST: mysql
  DB_PORT: "3306"
  DB_NAME: your_database_name
  # ... other variables
```

---

## Database Schema

### Tables
- **customers** - Customer information
- **orders** - Order transactions
- **order_items** - Individual items in orders
- **products** - Product catalog
- **product_categories** - Product categories
- **inventory** - Stock levels
- **vendors** - Vendor information
- **vendor_contracts** - Vendor agreements
- **warehouses** - Warehouse locations
- **campaigns** - Marketing campaigns

### Sample Queries
```sql
-- Get total orders
SELECT COUNT(*) FROM orders;

-- Get customer order count
SELECT c.name, COUNT(o.id) as order_count
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.id, c.name;

-- Get product inventory
SELECT p.name, i.quantity, w.name as warehouse
FROM products p
JOIN inventory i ON p.id = i.product_id
JOIN warehouses w ON i.warehouse_id = w.id;
```

---

## Development Workflow

### Daily Workflow
1. **Start services**
   ```powershell
   docker-compose --profile dev up -d
   ```

2. **Make code changes**
   - Edit files in `Home.py`, `pages/`, `utils/`
   - Changes auto-reload in dev mode

3. **Test changes**
   - Visit http://localhost:8501
   - Check logs: `docker logs -f ecommerce-streamlit-dev`

4. **Commit changes**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   git push
   ```

5. **Stop services** (end of day)
   ```powershell
   docker-compose --profile dev down
   ```

### Release Workflow
1. **Test locally** with full-stack mode
2. **Update version** in code
3. **Build new image**
   ```powershell
   docker build -t pratiksha3/ecommerce-app:v1.0.1 .
   ```
4. **Push to Docker Hub**
   ```powershell
   docker push pratiksha3/ecommerce-app:v1.0.1
   ```
5. **Deploy to staging/production**

---

## Best Practices

### ✅ DO
- Use `--profile dev` for development
- Use `--profile full-stack` for testing
- Commit `.env` files to `.gitignore`
- Regularly backup database
- Monitor container logs
- Clean up old images/volumes
- Document code changes
- Test before pushing

### ❌ DON'T
- Don't commit sensitive passwords
- Don't run production on localhost
- Don't skip database migrations
- Don't ignore error logs
- Don't push untested code
- Don't use `root` password in production
- Don't delete volumes without backup

---

## Useful Commands Cheat Sheet

```powershell
# Start
docker-compose --profile full-stack up -d

# Stop
docker-compose --profile full-stack down

# Restart
docker-compose --profile full-stack restart

# Logs
docker-compose --profile full-stack logs -f

# Status
docker-compose --profile full-stack ps

# Rebuild
docker-compose --profile full-stack build --no-cache

# Clean everything
docker-compose --profile full-stack down -v
docker system prune -a

# Shell access
docker exec -it ecommerce-mysql bash
docker exec -it ecommerce-streamlit-prod bash

# Database backup
docker exec ecommerce-mysql mysqldump -u root -pRoot@123 ecommerce_analytics > backup.sql

# Database restore
Get-Content backup.sql | docker exec -i ecommerce-mysql mysql -u root -pRoot@123 ecommerce_analytics
```

---

## Getting Help

### Resources
- **Docker Docs**: https://docs.docker.com/
- **Streamlit Docs**: https://docs.streamlit.io/
- **MySQL Docs**: https://dev.mysql.com/doc/

### Support
- **Issues**: Report bugs in GitHub repository
- **Questions**: Contact maintainer
- **Docker Hub**: https://hub.docker.com/r/pratiksha3/ecommerce-app

---

## Current Version
* **Latest Stable**: v1.0.0
* **Repository**: https://hub.docker.com/r/pratiksha3/ecommerce-app
* **Last Updated**: November 15, 2025

---

**Happy Coding! 🚀**