# Monitoring & Observability Guide (Killercoda Edition)

## Overview

Comprehensive monitoring stack using Prometheus, Grafana, and AlertManager for the e-commerce platform, optimized for Killercoda environment.

## Architecture
```
Application Pods → Metrics Endpoint
        ↓
Prometheus (Scrapes every 15s)
        ↓
    ┌────┴────┐
    ↓         ↓
Grafana   AlertManager
(Dashboards) (Notifications)
```

## Components

### Prometheus
- **Purpose**: Time-series metrics database
- **Retention**: 7 days (Killercoda optimized)
- **Scrape Interval**: 15 seconds
- **Storage**: 10GB PVC (local-path)

### Grafana
- **Purpose**: Visualization and dashboarding
- **Dashboards**:
  - Kubernetes Cluster (ID: 7249)
  - Node Exporter (ID: 1860)
  - Kubernetes Pods (ID: 6417)
  - Custom E-commerce Dashboard
  - Business Metrics Dashboard

### AlertManager
- **Purpose**: Alert routing and notifications
- **Features**:
  - Alert grouping
  - Deduplication
  - Silencing
  - Inhibition rules

## Accessing Monitoring Tools (Killercoda Method)

⚠️ **IMPORTANT**: Killercoda does NOT support NodePort external access or `minikube service` commands. You MUST use port-forward + Traffic button method!

### Grafana
```bash
# Port forward (REQUIRED for Killercoda)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Keep terminal open!
```

**In Killercoda UI:**
1. Click **"Traffic"** button at top right
2. Select **"Port 3000"**
3. Grafana opens in new tab

**Credentials:**
- Username: `admin`
- Password: `admin123`

### Prometheus
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
```

**In Killercoda UI:**
1. Click **"Traffic"** button
2. Select **"Port 9090"**
3. Prometheus UI opens

### AlertManager
```bash
# Port forward
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
```

**In Killercoda UI:**
1. Click **"Traffic"** button
2. Select **"Port 9093"**
3. AlertManager UI opens

## Key Metrics

### Application Metrics
- `streamlit_page_views_total` - Total page views by page
- `streamlit_request_duration_seconds` - Request latency
- `streamlit_active_users` - Current active users
- `streamlit_errors_total` - Application errors

### Infrastructure Metrics
- `container_cpu_usage_seconds_total` - Container CPU usage
- `container_memory_usage_bytes` - Container memory usage
- `kube_pod_container_status_restarts_total` - Pod restarts
- `up` - Service availability

### Database Metrics
- `mysql_global_status_threads_connected` - Active connections
- `mysql_global_status_queries` - Query rate
- `mysql_global_status_slow_queries` - Slow queries

### Cache Metrics
- `redis_memory_used_bytes` - Redis memory usage
- `redis_connected_clients` - Connected clients
- `redis_keyspace_hits_total` - Cache hits
- `redis_keyspace_misses_total` - Cache misses

## Alert Rules

### Critical Alerts

| Alert | Threshold | Action |
|-------|-----------|--------|
| ApplicationDown | Service down for 2 min | Immediate investigation |
| PodRestartingTooOften | > 0 restarts in 15 min | Check logs |
| HighErrorRate | > 0.1 errors/sec | Check application |

### Warning Alerts

| Alert | Threshold | Action |
|-------|-----------|--------|
| HighCPUUsage | > 80% for 5 min | Consider scaling |
| HighMemoryUsage | > 85% for 5 min | Check memory leaks |
| DatabaseConnectionHigh | > 150 connections | Optimize queries |
| RedisMemoryHigh | > 90% memory | Clear cache |
| LowDiskSpace | < 15% free | Clean up disk (Killercoda) |

## Quick Commands (Killercoda)
```bash
# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Then: Killercoda Traffic → Port 3000

# Access Prometheus
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
# Then: Killercoda Traffic → Port 9090

# Access AlertManager
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
# Then: Killercoda Traffic → Port 9093

# Check resource usage
kubectl top nodes
kubectl top pods -n monitoring
kubectl top pods -n dev

# Check storage
kubectl get pvc -n monitoring
```

## Troubleshooting

### Pods Not Starting
```bash
# Check pod status
kubectl get pods -n monitoring

# Describe pending pod
kubectl describe pod <pod-name> -n monitoring

# Check events
kubectl get events -n monitoring --sort-by='.lastTimestamp'
```

### Port-Forward Not Working
```bash
# Check service exists
kubectl get svc -n monitoring

# Check pod is running
kubectl get pods -n monitoring

# Try different port
kubectl port-forward -n monitoring svc/prometheus-grafana 3001:80
```

## Best Practices for Killercoda

1. ✅ Keep port-forward terminals open
2. ✅ Use separate terminal tabs for each service
3. ✅ Save screenshots before session expires
4. ✅ Monitor resources with `kubectl top`
5. ✅ Use local-path storage class
6. ✅ Document everything

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Killercoda Kubernetes Playground](https://killercoda.com/playgrounds/scenario/kubernetes)
