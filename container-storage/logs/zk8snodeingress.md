> ## ing
- https://kubernetes.io/docs/concepts/services-networking/ingress/

> ## ing..core.listener
- https://learn.microsoft.com/en-us/azure/application-gateway/configuration-listeners

> ## ing.annotation
```
# ingress.kubernetes.io
```
- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/
- https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-annotations
- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/migrate-from-agic-to-agc#feature-dependencies-and-mappings
- https://learn.microsoft.com/en-us/azure/application-gateway/for-containers/overview#load-balancing-features
- https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md

> ## ing.annotation.hostname-extension

```
k get ing -oyaml
k edit ing # appgw.ingress.kubernetes.io/hostname-extension: "hostname1, hostname2"
az network application-gateway show -g MC_rg_aksagic_swedencentral -n myApplicationGateway --query httpListeners[0].hostNames # [  "hostname1",  "hostname2"]
```
- https://azure.github.io/application-gateway-kubernetes-ingress/annotations/#hostname-extension

> ## ing.annotation.rewrite-target

```

```
- https://medium.com/ww-engineering/kubernetes-nginx-ingress-traffic-redirect-using-annotations-demystified-b7de846fb43d
- https://blog.nginx.org/blog/creating-nginx-rewrite-rules
