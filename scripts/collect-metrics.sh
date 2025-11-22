#!/bin/bash
# Collect Key Metrics for Killercoda

echo "=========================================="
echo "  KEY METRICS SNAPSHOT (Killercoda)"
echo "=========================================="
echo ""

kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090 &
PF_PID=$!
sleep 3

echo "🖥️  CPU Usage:"
curl -s 'http://localhost:9090/api/v1/query?query=rate(container_cpu_usage_seconds_total{namespace="dev",pod=~"streamlit.*"}[5m])' | jq -r '.data.result[] | "\(.metric.pod): \(.value[1])"'

echo ""
echo "💾 Memory Usage:"
curl -s 'http://localhost:9090/api/v1/query?query=container_memory_usage_bytes{namespace="dev",pod=~"streamlit.*"}' | jq -r '.data.result[] | "\(.metric.pod): \(.value[1] | tonumber / 1024 / 1024 | round)MB"'

echo ""
echo "🔄 Pod Restarts:"
curl -s 'http://localhost:9090/api/v1/query?query=kube_pod_container_status_restarts_total{namespace="dev"}' | jq -r '.data.result[] | "\(.metric.pod): \(.value[1])"'

echo ""
echo "📊 Request Rate (if available):"
curl -s 'http://localhost:9090/api/v1/query?query=rate(streamlit_page_views_total[5m])' | jq -r '.data.result[] | "\(.metric.page): \(.value[1])"'

kill $PF_PID

echo ""
echo "=========================================="
