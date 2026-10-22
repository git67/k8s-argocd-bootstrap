helm repo update

helm upgrade cilium cilium/cilium --version 1.20.3 --install \
   --namespace kube-system \
   --reuse-values \
   --set kubeProxyReplacement=true \
   --set gatewayAPI.enabled=true \
   --set l2announcements.enabled=true
kubectl -n kube-system rollout restart deployment/cilium-operator
kubectl -n kube-system rollout restart ds/cilium

sleep 10

kubectl get gatewayclass


# --- Hubble (Observability) ---
helm upgrade cilium cilium/cilium --version 1.20.3 --install \
   --namespace kube-system \
   --reuse-values \
   --set hubble.enabled=true \
   --set hubble.relay.enabled=true \
   --set hubble.ui.enabled=true \
   --set hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,httpV2}"
kubectl -n kube-system rollout restart ds/cilium
kubectl -n kube-system rollout status deployment/hubble-relay
kubectl -n kube-system rollout status deployment/hubble-ui
cilium status --wait

# Hubble CLI installieren
HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-amd64.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-amd64.tar.gz /usr/local/bin
rm hubble-linux-amd64.tar.gz{,.sha256sum}

# Flows per CLI (Port-Forward auf hubble-relay -> localhost:4245)
cilium hubble port-forward &
hubble status
hubble observe --namespace argocd --follow
hubble observe --namespace kube-system --protocol http --follow


kubectl patch configmap argocd-cmd-params-cm -n argocd \
  --type merge \
  -p '{"data":{"server.insecure":"true"}}'

kubectl rollout restart deployment argocd-server -n argocd

kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server | head -20
