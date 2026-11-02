#!/usr/bin/env bash
set -euo pipefail

echo ">>> Enable istio-injection di namespace default"
kubectl label namespace default istio-injection=enabled --overwrite

echo ">>> Deploy sample workloads (analog hris, hris-mq, nsq-nsqlookupd)"
kubectl apply -f "$(dirname "$0")/../manifests/apps/sample-workloads.yaml"

echo ">>> Tunggu rollout..."
kubectl rollout status deployment/hris-sim --timeout=120s
kubectl rollout status deployment/hris-mq-sim --timeout=120s
kubectl rollout status statefulset/nsq-nsqlookupd-sim --timeout=120s

echo ""
echo ">>> Verifikasi sidecar ter-inject (harus 2/2 container tiap pod):"
kubectl get pods -n default -o wide
