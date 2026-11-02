#!/usr/bin/env bash
set -euo pipefail

DIR="$(dirname "$0")/../manifests/argocd"

echo ">>> Apply istio-gateway (setara MR #2 di SOP kamu)"
echo ">>> Dijalankan TERPISAH dan SETELAH istio-base + istiod sehat,"
echo "    sesuai urutan di SOP PDF kamu."
kubectl apply -f "${DIR}/istio-gateway-app.yaml"

echo ">>> Tunggu rollout gateway..."
sleep 5
for i in $(seq 1 30); do
  if kubectl -n istio-system get deployment istio-ingressgateway &>/dev/null; then
    kubectl -n istio-system rollout status deployment/istio-ingressgateway --timeout=180s && break
  fi
  echo "  ... gateway belum muncul, menunggu (${i}/30)"
  sleep 5
done

echo ""
echo ">>> Status Service (EXTERNAL-IP kemungkinan <pending>, ini normal di kind):"
kubectl get svc istio-ingressgateway -n istio-system

echo ""
echo ">>> Lanjut jalankan 05-fake-external-ip.sh untuk simulasi IP tanpa perlu MetalLB"
