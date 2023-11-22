```
az aks mesh enable-ingress-gateway --ingress-gateway-type external -g $rg -n aks
# az aks mesh disable-ingress-gateway --ingress-gateway-type external -g $rg -n aks
```

- https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/
- https://istio.io/latest/docs/examples/microservices-istio/istio-ingress-gateway/
- https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress#enable-external-ingress-gateway
