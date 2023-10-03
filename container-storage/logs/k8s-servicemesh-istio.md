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

k get all -n aks-istio-system
NAME                                  READY   STATUS    RESTARTS   AGE
pod/istiod-asm-1-17-cdb49b9bd-84sqk   1/1     Running   0          4m39s
pod/istiod-asm-1-17-cdb49b9bd-hst9n   1/1     Running   0          4m54s
NAME                      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)                                 AGE
service/istiod-asm-1-17   ClusterIP   10.0.232.12   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   4m54s
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istiod-asm-1-17   2/2     2            2           4m55s
NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/istiod-asm-1-17-cdb49b9bd   2         2         2       4m55s
NAME                                                  REFERENCE                    TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istiod-asm-1-17   Deployment/istiod-asm-1-17   0%/80%    2         5         2          4m55s
```

- https://kubernetes.io/blog/2017/05/managing-microservices-with-istio-service-mesh/
- https://learn.microsoft.com/en-us/azure/aks/istio-about
- https://istio.io/latest/docs/
- https://github.com/VijayRod/demo/blob/master/aks/servicemesh-istio
