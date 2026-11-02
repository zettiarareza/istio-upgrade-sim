#!/usr/bin/env bash
set -euo pipefail

echo "=== Versi control plane & data plane ==="
istioctl version || true

echo ""
echo "=== Proxy status (semua harus SYNCED, tidak ada STALE) ==="
istioctl proxy-status || true

echo ""
echo "=== Image per pod (pastikan semua konsisten satu versi setelah rollout) ==="
kubectl get pods -A -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,PROXY_IMAGE:.spec.containers[?(@.name=="istio-proxy")].image' \
  | grep -v '<none>'

echo ""
echo "=== Service istio-ingressgateway (cek EXTERNAL-IP konsisten) ==="
kubectl get svc istio-ingressgateway -n istio-system

echo ""
echo "=== EnvoyFilter tersisa (pastikan versi lama sudah ter-prune) ==="
kubectl get envoyfilter -n istio-system

echo ""
echo "=== Selesai ==="
