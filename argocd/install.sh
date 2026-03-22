#!/bin/bash
# ─────────────────────────────────────────
#  ARGOCD — Install Script
#  Installs ArgoCD on Kubernetes
#  AND installs ArgoCD CLI on this server
#
#  Run: bash install.sh
#
#  CHANGE IF NEEDED:
#    EXPOSE_TYPE — how to access ArgoCD UI
# ─────────────────────────────────────────

EXPOSE_TYPE="port-forward"   # ← change to "loadbalancer" if on cloud (EKS/GKE/AKS)
                             #   change to "nodeport" if on bare metal / local cluster

set -euo pipefail

echo ""
echo "================================="
echo "  Installing ArgoCD on Kubernetes"
echo "================================="
echo ""

echo "► Step 1 — Check kubectl connection"
kubectl cluster-info --request-timeout=5s | head -1 \
  || { echo "  ❌ Cannot connect to cluster. Check your kubeconfig."; exit 1; }
echo "  ✅ Cluster connected"

echo ""
echo "► Step 2 — Create argocd namespace"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
echo "  ✅ Namespace ready"

echo ""
echo "► Step 3 — Install ArgoCD"
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo "  ✅ Manifest applied"

echo ""
echo "► Step 4 — Wait for pods to be ready"
echo "  ⏳ This takes 2-3 minutes..."
kubectl wait --for=condition=Available deployment \
  --all -n argocd --timeout=300s
echo "  ✅ All ArgoCD pods ready"

echo ""
echo "► Step 5 — Expose ArgoCD (${EXPOSE_TYPE})"
case "${EXPOSE_TYPE}" in
  loadbalancer)
    kubectl patch svc argocd-server -n argocd \
      -p '{"spec":{"type":"LoadBalancer"}}'
    echo "  ✅ LoadBalancer service set"
    ;;
  nodeport)
    kubectl patch svc argocd-server -n argocd \
      -p '{"spec":{"type":"NodePort"}}'
    echo "  ✅ NodePort service set"
    ;;
  *)
    echo "  ✅ Use port-forward (see README for command)"
    ;;
esac

echo ""
echo "► Step 6 — Install ArgoCD CLI"
ARGOCD_VERSION=$(curl -s \
  https://api.github.com/repos/argoproj/argo-cd/releases/latest \
  | grep '"tag_name"' | cut -d'"' -f4)
curl -sSL \
  "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64" \
  -o /tmp/argocd
sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
rm /tmp/argocd
echo "  ✅ CLI installed: $(argocd version --client --short)"

echo ""
echo "► Step 7 — Get initial admin password"
PASS=$(kubectl get secret argocd-initial-admin-secret \
  -n argocd -o jsonpath='{.data.password}' | base64 -d)

echo ""
echo "================================="
echo "  ✅ ARGOCD READY"
echo "================================="
echo ""
echo "  Username : admin"
echo "  Password : ${PASS}"
echo ""
echo "  Start port-forward to access UI:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then open: https://localhost:8080"
echo ""
echo "  Next: read README.md for Jenkins setup + pipeline code"
echo "================================="
