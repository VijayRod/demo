## k8s-servicemesh-istio

```
rg=rgmeshistio
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize --enable-asm -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
# az aks mesh enable -g $rg -n aks
```

```
az aks show -g $rg -n aks  --query 'serviceMeshProfile'
{
  "istio": {
    "certificateAuthority": null,
    "components": {
      "ingressGateways": null
    },
    "revisions": [
      "asm-1-17"
    ]
  },
  "mode": "Istio"
}

kubectl get all -n aks-istio-egress
No resources found in aks-istio-egress namespace.

kubectl get all -n aks-istio-ingress
No resources found in aks-istio-ingress namespace.

kubectl get all -n aks-istio-system --show-labels
NAME                                   READY   STATUS    RESTARTS   AGE     LABELS
pod/istiod-asm-1-17-67d689bdf8-bzz7z   1/1     Running   0          7m38s   app=istiod,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-17,istio=istiod,kubernetes.azure.com/managedby=aks,operator.istio.io/component=Pilot,pod-template-hash=67d689bdf8,sidecar.istio.io/inject=false
pod/istiod-asm-1-17-67d689bdf8-kf874   1/1     Running   0          7m23s   app=istiod,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-17,istio=istiod,kubernetes.azure.com/managedby=aks,operator.istio.io/component=Pilot,pod-template-hash=67d689bdf8,sidecar.istio.io/inject=false

NAME                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                                 AGE     LABELS
service/istiod-asm-1-17   ClusterIP   10.0.4.163   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   7m38s   app.kubernetes.io/managed-by=Helm,app=istiod,helm.toolkit.fluxcd.io/name=azure-service-mesh-istio-discovery-helmrelease,helm.toolkit.fluxcd.io/namespace=6554954d660fc400012c5a60,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-17,istio=pilot,operator.istio.io/component=Pilot,release=azure-service-mesh-istio-discovery

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/istiod-asm-1-17   2/2     2            2           7m39s   app.kubernetes.io/managed-by=Helm,app=istiod,helm.toolkit.fluxcd.io/name=azure-service-mesh-istio-discovery-helmrelease,helm.toolkit.fluxcd.io/namespace=6554954d660fc400012c5a60,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-17,istio=pilot,kubernetes.azure.com/managedby=aks,operator.istio.io/component=Pilot,release=azure-service-mesh-istio-discovery

NAME                                         DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/istiod-asm-1-17-67d689bdf8   2         2         2       7m39s   app=istiod,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-17,istio=istiod,kubernetes.azure.com/managedby=aks,operator.istio.io/component=Pilot,pod-template-hash=67d689bdf8,sidecar.istio.io/inject=false

NAME                                                  REFERENCE                    TARGETS   MINPODS   MAXPODS   REPLICAS   AGE     LABELS
horizontalpodautoscaler.autoscaling/istiod-asm-1-17   Deployment/istiod-asm-1-17   0%/80%    2         5         2          7m39s   app.kubernetes.io/managed-by=Helm,app=istiod,helm.toolkit.fluxcd.io/name=azure-service-mesh-istio-discovery-helmrelease,helm.toolkit.fluxcd.io/namespace=6554954d660fc400012c5a60,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-17,operator.istio.io/component=Pilot,release=azure-service-mesh-istio-discovery

kubectl describe po -n aks-istio-system -l app=istiod
Image:         mcr.microsoft.com/oss/istio/pilot:1.17.8-distroless

kubectl logs -n aks-istio-system -l app=istiod
2023-11-15T19:02:27.360324Z     info    validationController    validatingwebhookconfiguration istio-validator-asm-1-17-aks-istio-system (failurePolicy=Fail, resourceVersion=6023) is up-to-date. No change required.
2023-11-15T19:02:39.721883Z     info    rootcertrotator Jitter complete, start rotator.
2023-11-15T19:03:33.559241Z     info    validationController    validatingwebhookconfiguration istio-validator-asm-1-17-aks-istio-system (failurePolicy=Fail, resourceVersion=6325) is up-to-date. No change required.

kubectl get crd
NAME                                             CREATED AT
authorizationpolicies.security.istio.io          2024-09-30T18:23:18Z
destinationrules.networking.istio.io             2024-09-30T18:23:18Z
envoyfilters.networking.istio.io                 2024-09-30T18:23:18Z
gateways.networking.istio.io                     2024-09-30T18:23:18Z
peerauthentications.security.istio.io            2024-09-30T18:23:18Z
proxyconfigs.networking.istio.io                 2024-09-30T18:23:18Z
requestauthentications.security.istio.io         2024-09-30T18:23:18Z
serviceentries.networking.istio.io               2024-09-30T18:23:18Z
sidecars.networking.istio.io                     2024-09-30T18:23:18Z
telemetries.telemetry.istio.io                   2024-09-30T18:23:18Z
virtualservices.networking.istio.io              2024-09-30T18:23:18Z
wasmplugins.extensions.istio.io                  2024-09-30T18:23:18Z
workloadentries.networking.istio.io              2024-09-30T18:23:18Z
workloadgroups.networking.istio.io               2024-09-30T18:23:18Z

kubectl get validatingwebhookconfiguration
NAME                                        WEBHOOKS   AGE
azure-service-mesh-ccp-validating-webhook   2          5s
istio-validator-asm-1-21-aks-istio-system   1          5s

kubectl describe validatingwebhookconfiguration azure-service-mesh-ccp-validating-webhook
    URL:           https://ccp-webhook.66fa976c1ba07c000117d762.svc.cluster.local.:8443/v1/validate/istio
  Failure Policy:  Ignore
  
kubectl describe validatingwebhookconfiguration istio-validator-asm-1-21-aks-istio-system
    Service:
      Name:        istiod-asm-1-21
      Namespace:   aks-istio-system
      Path:        /validate
      Port:        443
  Failure Policy:  Fail
```

- https://kubernetes.io/blog/2017/05/managing-microservices-with-istio-service-mesh/
- https://learn.microsoft.com/en-us/azure/aks/istio-about
- https://istio.io/latest/docs/
- https://github.com/VijayRod/demo/blob/master/aks/servicemesh-istio
