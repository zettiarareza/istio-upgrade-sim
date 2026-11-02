#!/usr/bin/env bash
set -euo pipefail

FAKE_IP="${1:-34.101.252.126}"

echo ">>> Patch status Service istio-ingressgateway dengan IP simulasi: ${FAKE_IP}"
echo "    (Ini murni kosmetik/simulasi -- IP tidak perlu reachable/valid."
echo "     Kind tidak punya cloud provider, jadi loadBalancerIP di values"
echo "     Helm tidak akan pernah difulfill otomatis tanpa langkah ini.)"

kubectl patch svc istio-ingressgateway -n istio-system \
  --type=merge --subresource=status \
  -p "{\"status\":{\"loadBalancer\":{\"ingress\":[{\"ip\":\"${FAKE_IP}\"}]}}}"

echo ""
echo ">>> Verifikasi:"
kubectl get svc istio-ingressgateway -n istio-system

echo ""
echo ">>> CATATAN: patch status ini akan HILANG lagi kalau pod/Service"
echo "    di-recreate atau ArgoCD sync ulang (karena status bukan bagian"
echo "    dari desired state Helm). Jalankan ulang script ini kapanpun"
echo "    EXTERNAL-IP balik <pending>, untuk mengecek konsistensi IP"
echo "    yang kamu masukkan tetap sama sebelum/sesudah upgrade."
