#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="istio-upgrade-sim"

echo ">>> Membuat kind cluster: ${CLUSTER_NAME}"

cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
EOF

kubectl cluster-info --context "kind-${CLUSTER_NAME}"
echo ">>> Cluster siap. Context aktif: kind-${CLUSTER_NAME}"
