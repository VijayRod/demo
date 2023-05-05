This is an unsupported scenario as mentioned [here](../../servicemesh-istio#installing-istio-using-istioctl-upgrade-and-istio-based-service-mesh-add-on).

### Istio installed *before* the AKS Istio add-on is enabled.

```
~# istioctl upgrade
This will install the Istio 1.17.2 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
 Istio core installed
 Istiod installed
 Ingress gateways installed
 Installation complete
Making this installation the default for injection and validation.
Thank you for installing Istio 1.17.  Please take a few minutes to tell us about your install/upgrade experience!

~# kubectl get crd | grep istio
authorizationpolicies.security.istio.io          2023-05-04T09:22:23Z
destinationrules.networking.istio.io             2023-05-04T09:22:23Z
envoyfilters.networking.istio.io                 2023-05-04T09:22:23Z
gateways.networking.istio.io                     2023-05-04T09:22:23Z
istiooperators.install.istio.io                  2023-05-04T09:22:24Z
peerauthentications.security.istio.io            2023-05-04T09:22:24Z
proxyconfigs.networking.istio.io                 2023-05-04T09:22:24Z
requestauthentications.security.istio.io         2023-05-04T09:22:24Z
serviceentries.networking.istio.io               2023-05-04T09:22:24Z
sidecars.networking.istio.io                     2023-05-04T09:22:24Z
telemetries.telemetry.istio.io                   2023-05-04T09:22:24Z
virtualservices.networking.istio.io              2023-05-04T09:22:24Z
wasmplugins.extensions.istio.io                  2023-05-04T09:22:24Z
workloadentries.networking.istio.io              2023-05-04T09:22:24Z
workloadgroups.networking.istio.io               2023-05-04T09:22:25Z

~# kubectl get mutatingwebhookconfigurations | grep istio
istio-revision-tag-default         4          14m
istio-sidecar-injector             4          14m

~# kubectl get ns -l kubernetes.io/metadata.name=istio-system
NAME           STATUS   AGE
istio-system   Active   3m19s

~# kubectl get po -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-6974766b9c-77nlh   1/1     Running   0          47m
istiod-5987b4bb4f-mp7hr                 1/1     Running   0          47m

~# kubectl create ns istiotest
namespace/istiotest created

~# kubectl label ns istiotest istio-injection=enabled
namespace/istiotest labeled

~# kubectl get ns -l istio-injection=enabled
NAME        STATUS   AGE
istiotest   Active   29s

~# kubectl run nginx --image=nginx -n istiotest
pod/nginx created

~# kubectl get po nginx -n istiotest
NAME    READY   STATUS    RESTARTS   AGE
nginx   2/2     Running   0          21s

~# kubectl describe po nginx -n istiotest | grep -e istio-proxy: -e istio/proxy
  istio-proxy:
    Image:         docker.io/istio/proxyv2:1.17.2
```

After running the `istioctl upgrade` command, the AKS Istio add-on was enabled. However, when testing a pod, the `istio-proxy` container was found to be in an unhealthy state.

```
~# az aks mesh enable -g myResourceGroupName -n aksbefore 
### The above command has run successfully.

~# kubectl get crd | grep istio
### crds have the earlier create date.
authorizationpolicies.security.istio.io          2023-05-04T09:22:23Z
destinationrules.networking.istio.io             2023-05-04T09:22:23Z
envoyfilters.networking.istio.io                 2023-05-04T09:22:23Z
gateways.networking.istio.io                     2023-05-04T09:22:23Z
istiooperators.install.istio.io                  2023-05-04T09:22:24Z
peerauthentications.security.istio.io            2023-05-04T09:22:24Z
proxyconfigs.networking.istio.io                 2023-05-04T09:22:24Z
requestauthentications.security.istio.io         2023-05-04T09:22:24Z
serviceentries.networking.istio.io               2023-05-04T09:22:24Z
sidecars.networking.istio.io                     2023-05-04T09:22:24Z
telemetries.telemetry.istio.io                   2023-05-04T09:22:24Z
virtualservices.networking.istio.io              2023-05-04T09:22:24Z
wasmplugins.extensions.istio.io                  2023-05-04T09:22:24Z
workloadentries.networking.istio.io              2023-05-04T09:22:24Z
workloadgroups.networking.istio.io               2023-05-04T09:22:25Z

~# kubectl get mutatingwebhookconfigurations | grep istio
istio-revision-tag-default                         4          40m
istio-sidecar-injector                             4          41m
istio-sidecar-injector-asm-1-17-aks-istio-system   2          5m29s

~# kubectl get ns -l kubernetes.io/metadata.name=aks-istio-system,mesh.aks.azure.com/managed=true
NAME               STATUS   AGE
aks-istio-system   Active   10m

~# kubectl get po -n aks-istio-system
NAME                               READY   STATUS    RESTARTS   AGE
istiod-asm-1-17-67f9f55ccb-8gvg6   1/1     Running   0          12m
istiod-asm-1-17-67f9f55ccb-cc9jb   1/1     Running   0          20s

~# kubectl create ns istioaddontest
namespace/istioaddontest created

~# kubectl label ns istioaddontest istio.io/rev=asm-1-17
namespace/istioaddontest labeled

~# kubectl get ns -l istio.io/rev=asm-1-17
NAME             STATUS   AGE
istioaddontest   Active   4m

~# kubectl run nginx --image=nginx -n istioaddontest
pod/nginx created

~# kubectl get po nginx -n istioaddontest
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/2     Running   0          63s

~# kubectl describe po nginx -n istioaddontest | grep -e istio-proxy: -e istio/proxy -e healthz
  istio-proxy:
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.17.1-distroless
    Readiness:  http-get http://:15021/healthz/ready delay=1s timeout=3s period=2s #success=1 #failure=30

~# kubectl describe po nginx -n istioaddontest
  Normal   Started    118s                 kubelet            Started container istio-proxy
  Warning  Unhealthy  95s (x14 over 117s)  kubelet            Readiness probe failed: Get "http://10.244.1.6:15021/healthz/ready": dial tcp 10.244.1.6:15021: connect: connection refused

~# kubectl logs nginx -n istioaddontest -c istio-proxy
2023-05-04T10:13:28.905589Z     info    sds     Starting SDS grpc server
2023-05-04T10:13:28.905785Z     info    starting Http service at 127.0.0.1:15004
2023-05-04T10:13:29.038253Z     warn    ca      ca request failed, starting attempt 1 in 98.41741ms
2023-05-04T10:13:29.137587Z     warn    ca      ca request failed, starting attempt 2 in 209.365979ms
2023-05-04T10:13:29.348030Z     warn    ca      ca request failed, starting attempt 3 in 424.263326ms
2023-05-04T10:13:29.772673Z     warn    ca      ca request failed, starting attempt 4 in 773.221137ms
2023-05-04T10:13:30.563882Z     warn    sds     failed to warm certificate: failed to generate workload certificate: create certificate: rpc error: code = Unavailable desc = connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority (possibly because of \"crypto/rsa: verification error\" while trying to verify candidate authority certificate \"cluster.local\")"
2023-05-04T10:18:55.134527Z     warning envoy config external/envoy/source/common/config/grpc_stream.h:201      StreamAggregatedResources gRPC config stream to xds-grpc closed since 326s ago: 14, connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority (possibly because of \"crypto/rsa: verification error\" while trying to verify candidate authority certificate \"cluster.local\")"  thread=13
```

### Istio installed *after* the AKS Istio add-on is enabled.

```
~# az aks mesh enable -g myResourceGroupName -n aksafter
### The above command has run successfully.

~# istioctl upgrade
This will install the Istio 1.17.2 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
 Istio core installed
 Istiod installed
 Ingress gateways encountered an error: failed to wait for resource: resources not ready after 5m0s: timed out waiting for the condition
  Deployment/istio-system/istio-ingressgateway (containers with unready status: [istio-proxy])
- Pruning removed resources
Error: failed to install manifests: errors occurred during operation

~# kubectl get po -n istio-system
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-6974766b9c-25hc5   0/1     Running   0          2m3s
istiod-5987b4bb4f-tpfbj                 1/1     Running   0          2m10s

~# kubectl get po -n aks-istio-system
NAME                               READY   STATUS    RESTARTS   AGE
istiod-asm-1-17-67f9f55ccb-4zxnz   1/1     Running   0          3h42m
istiod-asm-1-17-67f9f55ccb-h6bl5   1/1     Running   0          39s

~# kubectl get ns --show-labels
NAME                STATUS   AGE     LABELS
istio-system        Active   129m    kubernetes.io/metadata.name=istio-system

~# kubectl create ns istioaddontest
namespace/istioaddontest created

~# kubectl label ns istioaddontest istio.io/rev=asm-1-17
namespace/istioaddontest labeled

~# kubectl run nginx --image=nginx -n istioaddontest
pod/nginx created

~# kubectl get po nginx -n istioaddontest
NAME    READY   STATUS    RESTARTS   AGE
nginx   0/2     Pending   0          10s

~# kubectl describe po nginx -n istioaddontest | grep -e istio-proxy: -e istio/proxy -e healthz
  istio-proxy:
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.17.1-distroless
    Readiness:  http-get http://:15021/healthz/ready delay=1s timeout=3s period=2s #success=1 #failure=30
      
~# kubectl describe po nginx -n istioaddontest
  Normal   Started           <invalid>                      kubelet            Started container istio-proxy
  Warning  Unhealthy         <invalid> (x9 over <invalid>)  kubelet            Readiness probe failed: Get "http://10.244.0.212:15021/healthz/ready": dial tcp 10.244.0.212:15021: connect: connection refused

 ~# kubectl logs nginx -n istioaddontest -c istio-proxy | tail
2023-05-05T00:53:38.273721Z     warn    ca      ca request failed, starting attempt 3 in 407.989929ms
2023-05-05T00:53:38.682543Z     warn    ca      ca request failed, starting attempt 4 in 796.11504ms
2023-05-05T00:53:39.479868Z     warn    sds     failed to warm certificate: failed to generate workload certificate: create certificate: rpc error: code = Unavailable desc = connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority (possibly because of \"crypto/rsa: verification error\" while trying to verify candidate authority certificate \"cluster.local\")"
2023-05-05T00:53:42.607386Z     info    ads     ADS: new connection for node:nginx.istioaddontest-18
2023-05-05T00:53:42.958116Z     warn    ca      ca request failed, starting attempt 1 in 98.774281ms
2023-05-05T00:53:43.057542Z     warn    ca      ca request failed, starting attempt 2 in 202.852812ms
2023-05-05T00:53:43.261025Z     warn    ca      ca request failed, starting attempt 3 in 386.076186ms
2023-05-05T00:53:43.647643Z     warn    ca      ca request failed, starting attempt 4 in 776.988066ms
2023-05-05T00:53:44.425989Z     warning envoy config external/envoy/source/common/config/grpc_stream.h:163      StreamSecrets gRPC config stream to sds-grpc closed: 2, failed to generate secret for ROOTCA: failed to generate workload certificate: create certificate: rpc error: code = Unavailable desc = connection error: desc = "transport: authentication handshake failed: x509: certificate signed by unknown authority (possibly because of \"crypto/rsa: verification error\" while trying to verify candidate authority certificate \"cluster.local\")"  thread=15
2023-05-05T00:53:44.425793Z     info    ads     ADS: "@" nginx.istioaddontest-18 terminated
```
