#!/bin/bash

echo "========================================="
echo "PHASE 6 - ARGOCD & GITOPS VERIFICATION"
echo "========================================="
echo ""

echo "Checking ArgoCD installation..."
kubectl get pods -n argocd
echo ""

echo "Checking ArgoCD applications..."
kubectl get applications -n argocd
echo ""

echo "Checking deployed applications..."
for ns in dev staging production; do
    echo "  Namespace: $ns"
    kubectl get all -n $ns
    echo ""
done

echo "========================================="
echo "ArgoCD Access (Killercoda):"
echo "========================================="
echo "1. Port forward:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "2. Get password:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "3. Login with username: admin"
echo ""
echo "========================================="
echo "VERIFICATION COMPLETE!"
echo "========================================="
