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

istioRevision=$(az aks show -g $rg -n aks --query serviceMeshProfile.istio.revisions -otsv); echo $istioRevision # asm-1-17

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

## k8s-servicemesh-istio.app.redis

```
# kubectl logs while attempting to connect a pod to the Redis cache in a namespace labeled for Istio: RedisConnectionException
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes#potential-connection-collision-with-istioenvoy
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-troubleshoot-connectivity#kubernetes-hosted-applications: If you're using Istio or any other service mesh, check that your service mesh proxy reserves port 13000-13019 or 15000-15019. These ports are used by clients to communicate with a clustered Azure Cache For Redis nodes and could cause connectivity issues on those ports.
- https://discuss.istio.io/t/istio-in-azure-aks-outbound-traffic-issues-over-15001-port-while-connecting-to-azure-redis-cache/10412/2: istio-iptables -p
- https://github.com/istio/cni/blob/master/tools/packaging/common/istio-iptables.sh: -p: Specify the envoy port to which redirect all TCP traffic (default $ENVOY_PORT = 15001). -z: Port to which all inbound TCP traffic to the pod/VM should be redirected to. For REDIRECT only (default $INBOUND_CAPTURE_PORT = 15006)
- https://istio.io/latest/docs/reference/commands/pilot-agent/: 150*

## k8s-servicemesh-istio.debug

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting
- https://istio.io/latest/docs/reference/commands/pilot-agent/: ads, all, ca, cache, citadelclient, default, dns, gcecred, grpc, healthcheck, iptables, klog, mockcred, monitoring, sds, security, spiffe, validation, wasm, xdsproxy

## k8s-servicemesh-istio.debug.iptables

- https://github.com/istio/istio/wiki/Understanding-IPTables-snapshot: 1337 - uid and gid used to distinguish between traffic originating from proxy vs the applications.
- https://jimmysong.io/en/blog/sidecar-injection-iptables-and-traffic-routing/
- https://github.com/istio/cni/blob/master/tools/packaging/common/istio-iptables.sh

## k8s-servicemesh-istio.example

```
po=nginx
ns=istio-ns
istioRevision=$(az aks show -g $rg -n aks --query serviceMeshProfile.istio.revisions -otsv); echo $istioRevision
kubectl delete po $po
kubectl delete ns $ns
kubectl create ns $ns
kubectl label namespace $ns istio.io/rev=$istioRevision
kubectl run $po -n $ns --image=nginx
sleep 10
kubectl get po $po -n $ns
# kubectl get po nginx -n istio-ns

kubectl describe po $po -n $ns | grep istio-
  istio-init:
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.22.5-distroless
  istio-proxy:
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.22.5-distroless
```

## k8s-servicemesh-istio.spec.other.configmap

```
istioRevision=$(az aks show -g $rg -n aks --query serviceMeshProfile.istio.revisions -otsv); echo $istioRevision
kubectl delete cm -n aks-istio-system istio-shared-configmap-$istioRevision
cat << EOF | kubectl create -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: istio-shared-configmap-$istioRevision
  namespace: aks-istio-system
data:
  mesh: |-
    accessLogFile: /dev/stdout
    defaultConfig:
      holdApplicationUntilProxyStarts: true
EOF
kubectl describe cm -n aks-istio-system istio-shared-configmap-$istioRevision
kubectl get cm -n aks-istio-system | grep istio-shared-configmap

kubectl get cm -A | grep istio
```

- https://learn.microsoft.com/en-us/azure/aks/istio-meshconfig#set-up-configuration-on-cluster
- https://learn.microsoft.com/en-us/azure/aks/istio-meshconfig#meshconfig: The values under defaultConfig are mesh-wide settings applied for Envoy sidecar proxy.

## k8s-servicemesh-istio.spec.other.configmap.MeshConfig

- https://learn.microsoft.com/en-us/azure/aks/istio-meshconfig#meshconfig
- https://learn.microsoft.com/en-us/azure/aks/istio-meshconfig#common-errors-and-troubleshooting-tips
- https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/: MeshConfig defines mesh-wide settings for the Istio service mesh.

## k8s-servicemesh-istio.spec.other.configmap.ProxyConfig

- https://learn.microsoft.com/en-us/azure/aks/istio-meshconfig#proxyconfig-meshconfigdefaultconfig
- https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig: ProxyConfig defines variables for individual Envoy instances. This can be configured on a per-workload basis as well as by the mesh-wide defaults. To set the mesh wide defaults, configure the defaultConfig section of meshConfig. 
