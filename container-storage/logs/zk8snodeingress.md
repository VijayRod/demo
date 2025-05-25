> ## ing
- https://kubernetes.io/docs/concepts/services-networking/ingress/

```
kubectl delete ing example-ingress
kubectl delete deploy example-deployment
kubectl delete svc example-service
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example
  template:
    metadata:
      labels:
        app: example
    spec:
      containers:
      - name: web
        image: hashicorp/http-echo
        args:
        - "-text=Hello from ingress!"
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: example-service
spec:
  selector:
    app: example
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5678
EOF
kubectl get ing -w

echo "$(ingress ip) example.local" | sudo tee -a /etc/hosts # for instance, in a k8s node
curl http://example.local # Hello from ingress!  
```

```
# ing.annotation

# ingress.kubernetes.io
```

> ## ing.controller (ingress controller)

```
(kubectl get ingress).ANNOTATION
```

> ## ing.controller.agic..core.listener
- https://learn.microsoft.com/en-us/azure/application-gateway/configuration-listeners

> ## ing.controller.agic.annotation

- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/
- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations
- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/migrate-from-agic-to-agc#feature-dependencies-and-mappings
- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview#load-balancing-features
- https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md

> ## ing.controller.agic.annotation.hostname-extension

```
k get ing -oyaml
k edit ing # appgw.ingress.kubernetes.io/hostname-extension: "hostname1, hostname2"
az network application-gateway show -g MC_rg_aksagic_swedencentral -n myApplicationGateway --query httpListeners[0].hostNames # [  "hostname1",  "hostname2"]
```
- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#hostname-extension

> ## ing.controller.nginx.annotation.rewrite-target

```

```
- https://medium.com/ww-engineering/kubernetes-nginx-ingress-traffic-redirect-using-annotations-demystified-b7de846fb43d
- https://blog.nginx.org/blog/creating-nginx-rewrite-rules
