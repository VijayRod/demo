```
kubectl get cm -n ingress-basic ingress-nginx-controller -oyaml
apiVersion: v1
data:
  allow-snippet-annotations: "false"
kind: ConfigMap
metadata:
  annotations:
    meta.helm.sh/release-name: ingress-nginx
    meta.helm.sh/release-namespace: ingress-basic
  creationTimestamp: "2023-12-04T19:41:19Z"
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.9.4
    helm.sh/chart: ingress-nginx-4.8.4
  name: ingress-nginx-controller
  
# To update (or edit) the ConfigMap (ignore the kubectl apply warning)
# kubectl edit cm -n ingress-basic ingress-nginx-controller
kubectl get cm -n ingress-basic ingress-nginx-controller -oyaml # backup
cat << EOF | kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: ingress-nginx-controller
  namespace: ingress-basic
data:
  keepalive_timeout: "75"
EOF
kubectl get cm -n ingress-basic ingress-nginx-controller -oyaml
```

- https://docs.nginx.com/nginx-ingress-controller/configuration/global-configuration/configmap-resource/
- https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
- https://www.nginx.com/resources/wiki/start/topics/examples/full/: Full Example Configuration
- https://stackoverflow.com/questions/37695036/cannot-use-vim-vi-nano-yum-inside-docker-container
- https://wiki.nginx.org/Configuration
