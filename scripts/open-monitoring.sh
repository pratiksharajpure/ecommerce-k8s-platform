#!/bin/bash
# Quick Access to Monitoring Tools (Killercoda)

echo "=========================================="
echo "  MONITORING TOOLS - QUICK ACCESS"
echo "  (Killercoda Edition)"
echo "=========================================="
echo ""

# Menu
echo "Select monitoring tool to access:"
echo ""
echo "1. Grafana (Dashboards)"
echo "2. Prometheus (Metrics)"
echo "3. AlertManager (Alerts)"
echo "4. All Tools (Separate Terminals Recommended)"
echo "5. Exit"
echo ""

read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        echo "Opening Grafana..."
        echo ""
        echo "Run this command:"
        echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
        echo ""
        echo "Then in Killercoda UI:"
        echo "  - Click 'Traffic' button"
        echo "  - Select 'Port 3000'"
        echo ""
        echo "Credentials:"
        echo "  Username: admin"
        echo "  Password: admin123"
        echo ""
        read -p "Press Enter to start port-forward..."
        kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
        ;;
    
    2)
        echo "Opening Prometheus..."
        echo ""
        echo "Run this command:"
        echo "  kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090"
        echo ""
        echo "Then in Killercoda UI:"
        echo "  - Click 'Traffic' button"
        echo "  - Select 'Port 9090'"
        echo ""
        read -p "Press Enter to start port-forward..."
        kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
        ;;
    
    3)
        echo "Opening AlertManager..."
        echo ""
        echo "Run this command:"
        echo "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
        echo ""
        echo "Then in Killercoda UI:"
        echo "  - Click 'Traffic' button"
        echo "  - Select 'Port 9093'"
        echo ""
        read -p "Press Enter to start port-forward..."
        kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
        ;;
    
    4)
        echo "=========================================="
        echo "⚠️  IMPORTANT: Open Separate Terminal Tabs!"
        echo "=========================================="
        echo ""
        echo "To access all tools simultaneously:"
        echo ""
        echo "Terminal Tab 1 - Grafana:"
        echo "  kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80"
        echo "  Traffic → Port 3000"
        echo ""
        echo "Terminal Tab 2 - Prometheus:"
        echo "  kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090"
        echo "  Traffic → Port 9090"
        echo ""
        echo "Terminal Tab 3 - AlertManager:"
        echo "  kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093"
        echo "  Traffic → Port 9093"
        echo ""
        echo "Keep all terminals open while monitoring!"
        echo "=========================================="
        ;;
    
    5)
        echo "Exiting..."
        exit 0
        ;;
    
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "⚠️  Keep this terminal open!"
echo "Press Ctrl+C to stop port forwarding"
echo "=========================================="
wait
