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
- https://istio.io/latest/docs/ops/deployment/architecture/

## k8s-servicemesh-istio.app.redis

```
# kubectl logs while attempting to connect a pod to the Redis cache in a namespace labeled for Istio: RedisConnectionException
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes#potential-connection-collision-with-istioenvoy
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-troubleshoot-connectivity#kubernetes-hosted-applications: If you're using Istio or any other service mesh, check that your service mesh proxy reserves port 13000-13019 or 15000-15019. These ports are used by clients to communicate with a clustered Azure Cache For Redis nodes and could cause connectivity issues on those ports.
- https://discuss.istio.io/t/istio-in-azure-aks-outbound-traffic-issues-over-15001-port-while-connecting-to-azure-redis-cache/10412/2: istio-iptables -p
- https://github.com/istio/cni/blob/master/tools/packaging/common/istio-iptables.sh: -p: Specify the envoy port to which redirect all TCP traffic (default $ENVOY_PORT = 15001). -z: Port to which all inbound TCP traffic to the pod/VM should be redirected to. For REDIRECT only (default $INBOUND_CAPTURE_PORT = 15006)
- https://istio.io/latest/docs/reference/commands/pilot-agent/: 150*
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes#potential-connection-collision-with-istioenvoy: When using Istio with an Azure Cache for Redis cluster, consider excluding the potential collision ports with an istio annotation. annotations: traffic.sidecar.istio.io/excludeOutboundPorts: "15000,15001,15004,15006,15008,15009,15020"
- https://github.com/istio/istio/issues/43655: Make port 15006 configurable. we may need to make all ports configurable long-term
  
## k8s-servicemesh-istio.debug

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting
- https://istio.io/latest/docs/reference/commands/pilot-agent/: ads, all, ca, cache, citadelclient, default, dns, gcecred, grpc, healthcheck, iptables, klog, mockcred, monitoring, sds, security, spiffe, validation, wasm, xdsproxy

## k8s-servicemesh-istio.debug.iptables

- https://github.com/istio/istio/wiki/Understanding-IPTables-snapshot: 1337 - uid and gid used to distinguish between traffic originating from proxy vs the applications.
- https://jimmysong.io/en/blog/sidecar-injection-iptables-and-traffic-routing/
- https://github.com/istio/cni/blob/master/tools/packaging/common/istio-iptables.sh

## k8s-servicemesh-istio.example

```
echo $rg
po=nginx
ns=istio-ns
istioRevision=$(az aks show -g $rg -n aks --query serviceMeshProfile.istio.revisions -otsv); echo $istioRevision
kubectl delete po -ns $ns $po
kubectl delete ns $ns
kubectl create ns $ns
kubectl label namespace $ns istio.io/rev=$istioRevision
kubectl run $po -n $ns --image=nginx
sleep 10
kubectl get po $po -n $ns
# kubectl get po nginx -n istio-ns

# /2
NAME    READY   STATUS    RESTARTS   AGE
nginx   2/2     Running   0          10s

kubectl describe po $po -n $ns | grep istio-
  istio-init:
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.22.5-distroless
  istio-proxy:
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.22.5-distroless
```

## k8s-servicemesh-istio.spec.other.configmap

```
echo $rg
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
- https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig: MeshConfig defines mesh-wide settings for the Istio service mesh.

## k8s-servicemesh-istio.spec.other.configmap.ProxyConfig

- https://learn.microsoft.com/en-us/azure/aks/istio-meshconfig#proxyconfig-meshconfigdefaultconfig
- https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig: ProxyConfig defines variables for individual Envoy instances. This can be configured on a per-workload basis as well as by the mesh-wide defaults. To set the mesh wide defaults, configure the defaultConfig section of meshConfig. 

## k8s-servicemesh-istio.spec.other.ports

```
# See the section on k8s-servicemesh-istio.app.redis to see the ports 15000-15019 utilized by Azure Cache for Redis

root@aks-nodepool1-33835024-vmss000004:/# iptables-save | grep 150
-A KUBE-SEP-C5BHK5WAW35LL4WX -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:https-webhook" -m tcp -j DNAT --to-destination 10.244.0.7:15017
-A KUBE-SEP-FVL7C3WAQGHN5DAN -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:https-dns" -m tcp -j DNAT --to-destination 10.244.0.10:15012
-A KUBE-SEP-H54KZ5GUNOAKYPID -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:grpc-xds" -m tcp -j DNAT --to-destination 10.244.0.7:15010
-A KUBE-SEP-LXXYVRSWACZZN2HZ -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:grpc-xds" -m tcp -j DNAT --to-destination 10.244.0.10:15010
-A KUBE-SEP-NRRV3CFSTOI47WX5 -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:https-dns" -m tcp -j DNAT --to-destination 10.244.0.7:15012
-A KUBE-SEP-RYPLX3PIOV7KXRLS -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:http-monitoring" -m tcp -j DNAT --to-destination 10.244.0.7:15014
-A KUBE-SEP-UDR3XRFX2TD4H2DU -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:http-monitoring" -m tcp -j DNAT --to-destination 10.244.0.10:15014
-A KUBE-SEP-VLQ4Z6JDWV4JRKNA -p tcp -m comment --comment "aks-istio-system/istiod-asm-1-22:https-webhook" -m tcp -j DNAT --to-destination 10.244.0.10:15017
-A KUBE-SVC-6KERD2IN6AEBO2WW -m comment --comment "aks-istio-system/istiod-asm-1-22:grpc-xds -> 10.244.0.10:15010" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-LXXYVRSWACZZN2HZ
-A KUBE-SVC-6KERD2IN6AEBO2WW -m comment --comment "aks-istio-system/istiod-asm-1-22:grpc-xds -> 10.244.0.7:15010" -j KUBE-SEP-H54KZ5GUNOAKYPID
-A KUBE-SVC-GK3BZPKCWUFYCJHE -m comment --comment "aks-istio-system/istiod-asm-1-22:https-dns -> 10.244.0.10:15012" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-FVL7C3WAQGHN5DAN
-A KUBE-SVC-GK3BZPKCWUFYCJHE -m comment --comment "aks-istio-system/istiod-asm-1-22:https-dns -> 10.244.0.7:15012" -j KUBE-SEP-NRRV3CFSTOI47WX5
-A KUBE-SVC-R6ANSUKRPKVTBBNX -m comment --comment "aks-istio-system/istiod-asm-1-22:http-monitoring -> 10.244.0.10:15014" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-UDR3XRFX2TD4H2DU
-A KUBE-SVC-R6ANSUKRPKVTBBNX -m comment --comment "aks-istio-system/istiod-asm-1-22:http-monitoring -> 10.244.0.7:15014" -j KUBE-SEP-RYPLX3PIOV7KXRLS
-A KUBE-SVC-X5AB4RUXCTLOCO67 -m comment --comment "aks-istio-system/istiod-asm-1-22:https-webhook -> 10.244.0.10:1517" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-VLQ4Z6JDWV4JRKNA
-A KUBE-SVC-X5AB4RUXCTLOCO67 -m comment --comment "aks-istio-system/istiod-asm-1-22:https-webhook -> 10.244.0.7:15017" -j KUBE-SEP-C5BHK5WAW35LL4WX
kubectl get po -n aks-istio-system -owide
NAME                               READY   STATUS    RESTARTS   AGE   IP            NODE
    NOMINATED NODE   READINESS GATES
istiod-asm-1-22-5d6d4f8b44-2k7q5   1/1     Running   0          14h   10.244.0.7    aks-nodepool1-33835024-vmss000005   <none>           <none>
istiod-asm-1-22-5d6d4f8b44-95llg   1/1     Running   0          14h   10.244.0.10   aks-nodepool1-33835024-vmss000005   <none>           <none>
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes#potential-connection-collision-with-istioenvoy: When using Istio with an Azure Cache for Redis cluster, consider excluding the potential collision ports with an istio annotation. annotations: traffic.sidecar.istio.io/excludeOutboundPorts: "15000,15001,15004,15006,15008,15009,15020"
- https://istio.io/latest/docs/reference/config/annotations/#SidecarTrafficExcludeOutboundPorts
- https://istio.io/latest/docs/ops/deployment/application-requirements/#ports-used-by-istio

## k8s-servicemesh-istio.spec.other.proxy.Envoy

1. The istio-proxy container is the Envoy sidecar injected by Istio.
   
   1a. The sidecar containers are injected using a mutating admission webhook seen with `kubectl get mutatingwebhookconfigurations | grep istio-sidecar-injector`.
   
   1b. Use `istioctl proxy-status -i aks-istio-system` to retrieve the proxy sync status for all Envoys in a mesh. Each row in the output denotes an Envoy proxy in each pod in the cluster.
   
      1b.i. `CDS`, `LDS`, `EDS`, `RDS`, and `ECDS`, seen in the output of the above command, are Envoy (the proxy underpinning Istio) services mentioned [here](https://github.com/istio/istio/issues/34139#issuecomment-1064377239) and [here](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/operations/dynamic_configuration).
       
      1b.ii. `SYNCED` and `NOT SENT` statuses are usually seen, `STALE` usually indicates a networking issue between Envoy and Istiod as indicated [here](https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/).
       
      1b.iii. The Istio service mesh architecture includes the proxy underpinning Istio, as shown [here](https://istio.io/latest/docs/ops/deployment/architecture/).


## k8s-servicemesh-istio.tool.istioctl

```
# install
cd /tmp
curl -L https://istio.io/downloadIstio | sh -
export PATH="$PATH:/tmp/istio-1.23.2/bin"

# precheck
istioctl x precheck # -n default
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/

# debug
istioctl x precheck --vklog=9 # > istioctl_logs.txt

# debug proxy-status
# If an envoy (application pod) is missing from the output, it means that it is not currently connected to an Istio Pilot instance and thus will not receive any configuration.
kubectl run nginx --image=nginx -n istio-ns
istioctl proxy-status -i aks-istio-system
NAME                  CLUSTER        CDS        LDS        EDS        RDS        ECDS         ISTIOD                               VERSION
nginx.istio-ns        Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-22-5d6d4f8b44-9xbl2     1.22-dev

```

   
   2b. `SYNCED` and `NOT SENT` are usually seen in the output. `STALE` indicates a networking issue between Envoy and Istiod or the Istio Pilot needs to be scaled.
   
   2c. Refer to the advanced user note [above](#for-advanced-users) for further information about the output if required.

3. To retrieve information about proxy configuration from an Envoy instance, run `istioctl proxy-config -i aks-istio-system all -o json hello -n default` for example for pod 'hello' in namespace 'default'. Instead of 'all', one of 'clusters|listeners|routes|endpoints|bootstrap|log|secret' can be used.

- https://istio.io/latest/docs/setup/getting-started/#download

