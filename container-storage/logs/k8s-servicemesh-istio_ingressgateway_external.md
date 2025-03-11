
- https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/
- https://istio.io/latest/docs/examples/microservices-istio/istio-ingress-gateway/
- https://learn.microsoft.com/en-us/azure/aks/istio-deploy-ingress#enable-external-ingress-gateway

```
az aks mesh enable-ingress-gateway --ingress-gateway-type external -g $rg -n aks
# az aks mesh disable-ingress-gateway --ingress-gateway-type external -g $rg -n aks
```

```
k get all -A | grep istio | grep ext
aks-istio-ingress   pod/aks-istio-ingressgateway-external-asm-1-22-7f49647c55-c22dc   1/1     Running   0          34s
aks-istio-ingress   pod/aks-istio-ingressgateway-external-asm-1-22-7f49647c55-wtbq6   1/1     Running   0          19s
aks-istio-ingress   service/aks-istio-ingressgateway-external   LoadBalancer   10.0.189.151   9.223.83.76   15021:32305/TCP,80:31978/TCP,443:31388/TCP   34s
aks-istio-ingress   deployment.apps/aks-istio-ingressgateway-external-asm-1-22   2/2     2            2           34s
aks-istio-ingress   replicaset.apps/aks-istio-ingressgateway-external-asm-1-22-7f49647c55   2         2         2       34s
aks-istio-ingress   horizontalpodautoscaler.autoscaling/aks-istio-ingressgateway-external-asm-1-22   Deployment/aks-istio-ingressgateway-external-asm-1-22   cpu: <unknown>/80%   2         5         2          35s

k get all -A --show-labels | grep istio | grep ext
aks-istio-ingress   pod/aks-istio-ingressgateway-external-asm-1-22-7f49647c55-c22dc   1/1     Running   0          116s    app=aks-istio-ingressgateway-external,istio.io/rev=asm-1-22,istio=aks-istio-ingressgateway-external,kubernetes.azure.com/managedby=aks,pod-template-hash=7f49647c55,service.istio.io/canonical-name=aks-istio-ingressgateway-external,service.istio.io/canonical-revision=latest,sidecar.istio.io/inject=true
aks-istio-ingress   pod/aks-istio-ingressgateway-external-asm-1-22-7f49647c55-wtbq6   1/1     Running   0          101s    app=aks-istio-ingressgateway-external,istio.io/rev=asm-1-22,istio=aks-istio-ingressgateway-external,kubernetes.azure.com/managedby=aks,pod-template-hash=7f49647c55,service.istio.io/canonical-name=aks-istio-ingressgateway-external,service.istio.io/canonical-revision=latest,sidecar.istio.io/inject=true
aks-istio-ingress   service/aks-istio-ingressgateway-external   LoadBalancer   10.0.189.151   9.223.83.76   15021:32305/TCP,80:31978/TCP,443:31388/TCP   116s   app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=aks-istio-ingressgateway-external,app.kubernetes.io/version=1.0.0,app=aks-istio-ingressgateway-external,helm.sh/chart=azure-service-mesh-istio-ingress-gateway-addon-1.0.0-731f77a7f1,helm.toolkit.fluxcd.io/name=asm-ingress-aks-istio-ingressgateway-external,helm.toolkit.fluxcd.io/namespace=67c070eb396bc50001b592c5,istio=aks-istio-ingressgateway-external,kubernetes.azure.com/managedby=aks
aks-istio-ingress   deployment.apps/aks-istio-ingressgateway-external-asm-1-22   2/2     2            2           116s   app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=aks-istio-ingressgateway-external,app.kubernetes.io/version=1.0.0,app=aks-istio-ingressgateway-external,helm.sh/chart=azure-service-mesh-istio-ingress-gateway-addon-1.0.0-731f77a7f1,helm.toolkit.fluxcd.io/name=asm-ingress-aks-istio-ingressgateway-external,helm.toolkit.fluxcd.io/namespace=67c070eb396bc50001b592c5,istio=aks-istio-ingressgateway-external,kubernetes.azure.com/managedby=aks
aks-istio-ingress   replicaset.apps/aks-istio-ingressgateway-external-asm-1-22-7f49647c55   2         2         2       116s   app=aks-istio-ingressgateway-external,istio.io/rev=asm-1-22,istio=aks-istio-ingressgateway-external,kubernetes.azure.com/managedby=aks,pod-template-hash=7f49647c55,sidecar.istio.io/inject=true
aks-istio-ingress   horizontalpodautoscaler.autoscaling/aks-istio-ingressgateway-external-asm-1-22   Deployment/aks-istio-ingressgateway-external-asm-1-22   cpu: 2%/80%   2         5         2          116s   app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=aks-istio-ingressgateway-external,app.kubernetes.io/version=1.0.0,app=aks-istio-ingressgateway-external,helm.sh/chart=azure-service-mesh-istio-ingress-gateway-addon-1.0.0-731f77a7f1,helm.toolkit.fluxcd.io/name=asm-ingress-aks-istio-ingressgateway-external,helm.toolkit.fluxcd.io/namespace=67c070eb396bc50001b592c5,istio=aks-istio-ingressgateway-external,kubernetes.azure.com/managedby=aks

k get envoyfilters -A # No resources found

# The number of CRDs and validating webhook configurations are the same, with or without an ingress gateway.

az aks show -g $rg -n aks --query serviceMeshProfile.istio.components.ingressGateways
[
  {
    "enabled": true,
    "mode": "External"
  }
]
```
