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

## annotation: ingress.kubernetes.io
## namespace is vendor-specific
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    namespace.ingress.kubernetes.io/key: value
```

```
# ing.multi-tenant
Tenant: A different customer, team, or department; environment (e.g., dev, staging, prod)
Tenant defined with: A unique hostname (e.g., tenant1.example.com), a dedicated path or namespace, optional custom headers or rewrites to identify the tenant

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tenant1-ingress
  namespace: tenant1
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      proxy_set_header x-tenant-id "tenant1-id";
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
    - host: tenant1.example.com
      http:
        paths:
          - path: /?(.*)
            pathType: ImplementationSpecific
            backend:
              service:
                name: tenant1-service
                port:
                  number: 80
```

> ## ing.controller (ingress controller)

```
(kubectl get ingress).CONTROLLER
```

> ## ing.controller.agic..ingressclass

```
kubectl get ingressclass
NAME                        CONTROLLER                  PARAMETERS   AGE
azure-application-gateway   azure/application-gateway   <none>       9s
```

> ## ing.controller.agic..listener
- https://learn.microsoft.com/en-us/azure/application-gateway/configuration-listeners

> ## ing.controller.agic.annotation

- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/
- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations
- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/migrate-from-agic-to-agc#feature-dependencies-and-mappings
- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview#load-balancing-features

```
# agic.annotation.hostname-extension

k get ing -oyaml
k edit ing # appgw.ingress.kubernetes.io/hostname-extension: "hostname1, hostname2"
az network application-gateway show -g MC_rg_aksagic_swedencentral -n myApplicationGateway --query httpListeners[0].hostNames # [  "hostname1",  "hostname2"]
```
- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#hostname-extension

```
# agic.annotation.appgw-trusted-root-certificate
# appgw.ingress.kubernetes.io/appgw-trusted-root-certificate
# Refer to the https sample with agic since the appgw-trusted-root-certificate annotation is required for https
```
- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations#application-gateway-trusted-root-certificate
- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#appgw-trusted-root-certificate

> ## ing.controller.nginx

- https://github.com/nginx/nginx?tab=readme-ov-file
- https://nginx.org/en/docs/beginners_guide.html

```
# nginx.debug
# check if the issue occurs with the nginx.official ingress controller

# nginx.official ingress controller
helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx \
  --set controller.logLevel=debug --set controller.extraArgs.v=3 # "DEBUG:" lines in k logs # --namespace ingress-nginx --create-namespace
kubectl get deploy -l app.kubernetes.io/instance=nginx-ingress -o jsonpath='{.items[0].spec.template.spec.containers[0].args}'
## (no change) ["/nginx-ingress-controller","--publish-service=$(POD_NAMESPACE)/nginx-ingress-ingress-nginx-controller","--election-id=nginx-ingress-ingress-nginx-leader","--controller-class=k8s.io/ingress-nginx","--ingress-class=nginx","--configmap=$(POD_NAMESPACE)/nginx-ingress-ingress-nginx-controller","--enable-metrics=false"]

## using any ingress class of nginx ingress controller
kubectl exec -n ingress-nginx ingress-nginx-controller-7fcbcb8d8d-9s5mn -- tail -f /var/log/nginx/error.log
kubectl exec -n ingress-nginx ingress-nginx-controller-XXXX -- nginx -t # check active nginx configuration
kubectl exec -n ingress-nginx ingress-nginx-controller-XXXX -- nginx -T # dump including the .config file, then "error_log /var/log/nginx/error.log debug;"
kubectl exec -it -n ingress-nginx ingress-nginx-controller-XXXX -- nginx-debug -T
kubectl port-forward -n ingress-nginx pod/ingress-nginx-controller-xxxxxx 8080:80 # expose local port 8080 to container port 80, then the ingress curl test in this window
kubectl port-forward -n ingress-nginx pod/ingress-nginx-controller-xxxxxx 8443:443
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 8080:80 # equivalent to nginx pod 8080:80, but using the service instead of the pod

## ingress test
curl -iv -H "Host: tenant1.sports" http://localhost:8080/rluOKg6kHU # http, -i to inspect headers
curl -iv -H "Host: tenant1.sports" http://localhost:8443/rluOKg6kHU # https

# more
kubectl delete ing --all
kubectl delete po --all
```

```
# nginx.debug.config
k exec -it -n app-routing-system nginx-7f6784b4b5-rjkm4 -- cat /etc/nginx/nginx.conf
```
- https://learn.microsoft.com/en-us/azure/aks/app-routing-nginx-configuration?tabs=azurecli
- https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/
- https://nginx.org/en/docs/beginners_guide.html: Starting, Stopping, and Reloading Configuration

```
# debug.logLevel

## default: --set controller.logLevel=info
## default: --set controller.extraArgs.v=2 # https://github.com/kubernetes/component-base/blob/master/logs/api/v1/options.go
```
- controller.extraArgs.v: https://github.com/kubernetes/component-base/blob/master/logs/api/v1/options.go

```
# debug.reload
# after deploying an ingress yaml (it does not restart the nginx ingress controller pods)
kubectl logs -n kube-system -l app.kubernetes.io/component=controller
I0526 18:42:10.693239       8 event.go:377] Event(v1.ObjectReference{Kind:"Pod", Namespace:"default", Name:"nginx-ingress-ingress-nginx-controller-6cf667bcb7-d284w", UID:"6e2a2054-e6b7-4663-a33a-58f694a5158f", APIVersion:"v1", ResourceVersion:"487616", FieldPath:""}): type: 'Normal' reason: 'RELOAD' NGINX reload triggered due to a change in configuration
kubectl describe po -l app.kubernetes.io/component=controller
  Normal  RELOAD     7m19s (x3 over 10m)  nginx-ingress-controller  NGINX reload triggered due to a change in configuration
```

> ## ing.controller.nginx..ingressclass

```
# nginx.official
# Refer to the nginx.conf section for debugging

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --set controller.admissionWebhooks.enabled=false # --namespace ingress-nginx --create-namespace

kubectl get ingressclass
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       145m

kubectl get po -A -owide | grep nginx # nginx-ingress-ingress-nginx-controller-
kubectl get po -l app.kubernetes.io/instance=nginx-ingress -w
kubectl logs -l app.kubernetes.io/instance=nginx-ingress -f

apiVersion: networking.k8s.io/v1
kind: Ingress
spec:
  ingressClassName: nginx

kubectl get po -l app.kubernetes.io/component=controller 
Labels:           app.kubernetes.io/component=controller
                  app.kubernetes.io/instance=nginx-ingress
                  app.kubernetes.io/managed-by=Helm
                  app.kubernetes.io/name=ingress-nginx
                  app.kubernetes.io/part-of=ingress-nginx
                  app.kubernetes.io/version=1.11.3
                  helm.sh/chart=ingress-nginx-4.11.3
                  pod-template-hash=6cf667bcb7
kubectl get deploy -l app.kubernetes.io/instance=nginx-ingress -w # nginx-ingress-ingress-nginx-controller

k get mutatingwebhookconfigurations
NAME                               WEBHOOKS   AGE
aks-webhook-admission-controller   1          5d2h
k get validatingwebhookconfigurations
NAME                                    WEBHOOKS   AGE
nginx-ingress-ingress-nginx-admission   1          16m
k describe mutatingwebhookconfigurations aks-webhook-admission-controller
k describe validatingwebhookconfigurations nginx-ingress-ingress-nginx-admission
```

```
# nginx.webapprouting

kubectl get ingressclass
NAME                                 CONTROLLER                                 PARAMETERS   AGE
webapprouting.kubernetes.azure.com   webapprouting.kubernetes.azure.com/nginx   <none>       79s
```

> ## ing.controller.nginx..ingressclass.multiple

- https://learn.microsoft.com/en-us/azure/aks/app-routing-nginx-configuration?tabs=azurecli#configuration-of-the-nginx-ingress-controller
- https://github.com/Azure/aks-app-routing-operator/blob/main/config/crd/bases/approuting.kubernetes.azure.com_nginxingresscontrollers.yaml

```
k describe crd nginxingresscontrollers.approuting.kubernetes.azure.com

k get nginxingresscontrollers
# k get nginxingresscontrollers.approuting.kubernetes.azure.com
NAME      INGRESSCLASS                         CONTROLLERNAMEPREFIX   AVAILABLE
default   webapprouting.kubernetes.azure.com   nginx                  True

k describe nginxingresscontrollers default

k delete nginxingresscontrollers nginx-my
cat << EOF | kubectl create -f -
apiVersion: approuting.kubernetes.azure.com/v1alpha1
kind: NginxIngressController
metadata:
  name: nginx-my
spec:
  ingressClassName: nginx-my
  controllerNamePrefix: nginx-my
  scaling:
    threshold: rapid 
EOF
k get nginxingresscontrollers

NAME       INGRESSCLASS                         CONTROLLERNAMEPREFIX   AVAILABLE
default    webapprouting.kubernetes.azure.com   nginx                  True
nginx-my   nginx-my                             nginx-my               False

k get po -n app-routing-system -l app.kubernetes.io/component=ingress-controller -owide -w
NAME                          READY   STATUS    RESTARTS   AGE   IP             NODE                                NOMINATED NODE   READINESS GATES
nginx-7f6784b4b5-cbjfx        1/1     Running   0          22m   10.244.0.223   aks-nodepool1-61189898-vmss000000   <none>           <none>
nginx-7f6784b4b5-wglwv        1/1     Running   0          22m   10.244.3.230   aks-nodepool1-61189898-vmss000003   <none>           <none>
nginx-my-0-5f86ffcbb8-fv4hh   1/1     Running   0          54s   10.244.4.66    aks-nodepool1-61189898-vmss000004   <none>           <none>
nginx-my-0-5f86ffcbb8-vzd4l   1/1     Running   0          39s   10.244.1.51    aks-nodepool1-61189898-vmss000002   <none>           <none>

k delete ing aks-helloworld
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: aks-helloworld
spec:
  ingressClassName: nginx-my
  rules:
  - 
    http:
      paths:
      - backend:
          service:
            name: aks-helloworld
            port:
              number: 80
        path: /
        pathType: Prefix
EOF
date
sleep 60
```

> ## ing.controller.nginx.annotation

- https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md
- https://learn.microsoft.com/en-us/azure/aks/app-routing-nginx-configuration?tabs=azurecli#configuration-of-the-nginx-ingress-controller

```
# nginx.annotation.configuration.snippet

## nginx.official.helm.deploy
--set controller.allowSnippetAnnotations=true
```


```
# nginx.annotation.rewrite-target
```
- https://medium.com/ww-engineering/kubernetes-nginx-ingress-traffic-redirect-using-annotations-demystified-b7de846fb43d
- https://blog.nginx.org/blog/creating-nginx-rewrite-rules

