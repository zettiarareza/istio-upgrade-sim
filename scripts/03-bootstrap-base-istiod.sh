#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$0")/../manifests/argocd"

echo ">>> Apply istio-base dan istiod (setara MR #1 di SOP kamu)"
kubectl apply -f "${DIR}/istio-base-app.yaml"
kubectl apply -f "${DIR}/istiod-app.yaml"

echo ">>> Tunggu ArgoCD sync otomatis (automated + prune sudah di-set)..."
sleep 5

echo ">>> Menunggu istiod pod ready..."
for i in $(seq 1 30); do
  if kubectl -n istio-system get deployment istiod &>/dev/null; then
    kubectl -n istio-system rollout status deployment/istiod --timeout=180s && break
  fi
  echo "  ... istiod belum muncul, menunggu (${i}/30)"
  sleep 5
done

echo ""
echo ">>> Status Application:"
kubectl get applications -n argocd

echo ""
echo ">>> Kalau sudah Synced + Healthy, lanjut jalankan 04-bootstrap-gateway.sh"
