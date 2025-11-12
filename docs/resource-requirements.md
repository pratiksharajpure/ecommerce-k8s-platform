# Resource Requirements

## Development Environment (Minikube)
- **CPU**: 4 cores minimum
- **RAM**: 8GB minimum
- **Disk**: 40GB available space
- **OS**: Windows 10, Ubuntu 20.04+, macOS

## Staging Environment
- **Cluster**: 2 nodes
- **Node Type**: t3.medium (2 vCPU, 4GB RAM)
- **Storage**: 50GB EBS per node
- **Monthly Cost**: ~

## Production Environment
- **Cluster**: 3 nodes
- **Node Type**: t3.large (2 vCPU, 8GB RAM)
- **Storage**: 100GB EBS per node
- **Load Balancer**: Application Load Balancer
- **Monthly Cost**: ~

## Application Resource Limits

### Per Pod
| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Streamlit | 250m        | 500m      | 256Mi          | 512Mi        |
| MySQL     | 500m        | 1000m     | 1Gi            | 2Gi          |
| Redis     | 100m        | 200m      | 128Mi          | 256Mi        |
| Prometheus| 500m        | 1000m     | 1Gi            | 2Gi          |
| Grafana   | 100m        | 200m      | 128Mi          | 256Mi        |
