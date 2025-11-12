# Architecture Documentation

## System Overview
This platform deploys an e-commerce analytics application on Kubernetes with full observability and GitOps automation.

## Components

### Application Layer
- **Streamlit Frontend**: Python-based web application
  - Runs on port 8501
  - Configured with 3 replicas for HA
  - Resource limits: 500m CPU, 512Mi memory
  
- **Redis Cache**: Session and data caching
  - Single replica (non-critical)
  - 6379 port
  - Resource limits: 200m CPU, 256Mi memory

### Data Layer
- **MySQL Database**: Primary data store
  - StatefulSet for stable network identity
  - Persistent Volume: 10Gi
  - Resource limits: 1 CPU, 2Gi memory
  - Automated backups enabled

### Monitoring Stack
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notification

### GitOps
- **ArgoCD**: Automated deployment from Git

## Network Architecture
- **Ingress**: NGINX Ingress Controller with SSL/TLS
- **Services**:
  - streamlit-service (LoadBalancer)
  - mysql-service (ClusterIP)
  - redis-service (ClusterIP)

## Storage
- **PersistentVolumes**: For MySQL data persistence
- **StorageClass**: Dynamic provisioning enabled

## Security
- **Secrets Management**: Kubernetes Secrets (upgrade to Vault in Phase 9)
- **Network Policies**: Pod-to-pod communication restrictions
- **RBAC**: Role-based access control for users

## Environments

### Development (Minikube)
- Single-node cluster
- Minimal resources
- Local storage

### Staging (Cloud)
- 2-node cluster
- t3.medium instances
- Cloud storage

### Production (Cloud)
- 3-node cluster
- t3.large instances
- Multi-AZ deployment
- Auto-scaling enabled

## CI/CD Flow
Code Push → GitHub Actions → Build Image → Push to Registry → Update GitOps Repo → ArgoCD Sync → Deploy to Cluster

## Disaster Recovery
- Database backups: Daily, retained for 30 days
- Configuration backups: Stored in Git
- RTO: 15 minutes
- RPO: 1 hour
