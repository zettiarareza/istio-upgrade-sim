#!/usr/bin/env bash
set -euo pipefail

echo ">>> Install ArgoCD di namespace argocd"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ">>> Tunggu argocd-server ready..."
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

echo ""
echo ">>> Password admin awal:"
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo ">>> Port-forward buat akses UI (terminal terpisah):"
echo "    kubectl port-forward -n argocd svc/argocd-server 8080:443"
