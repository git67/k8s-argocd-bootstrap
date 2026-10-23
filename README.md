<p align="center">
  <img src="https://raw.githubusercontent.com/kubernetes/kubernetes/master/logo/logo.png" width="100" title="Kubernetes Logo" alt="Kubernetes Logo" style="float:left;">
  <img src="https://raw.githubusercontent.com/argoproj/argo-cd/stable/docs/assets/argo.png" width="100" title="ArgoCD Logo" alt="ArgoCD Logo" style="float:right;">
</p>

<h1 align="center">K8s Bootstrap mit ArgoCD</h1>

## Monitoring

Die App `baseline-monitoring` installiert den Prometheus-Community-Stack mit
Prometheus, Grafana, Alertmanager sowie den Kubernetes-Metrik-Exportern.
Argo CD übernimmt die Installation automatisch über `start-baseline`.

Grafana ist über `http://grafana.hs.local` erreichbar. Der Hostname muss auf
die IP des Gateways zeigen (hier `192.168.56.200`); bei Bedarf kann alternativ
ein lokaler Port-Forward verwendet werden:

```sh
kubectl -n monitoring port-forward svc/baseline-monitoring-grafana 3000:80
```

Anschließend `http://localhost:3000` aufrufen. Das Grafana-Admin-Passwort liegt
im von Helm verwalteten Secret:

```sh
kubectl -n monitoring get secret baseline-monitoring-grafana \
  -o jsonpath='{.data.admin-password}' | base64 --decode
echo
```
