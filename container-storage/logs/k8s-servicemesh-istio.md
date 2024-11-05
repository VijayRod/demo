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

To reproduce the issue, change the port number in the Redis connection string to 15001 from the usual 6380. Also, make sure to deploy the app in the Istio labelled namespace without adding the excludeOutboundPorts mitigation annotation.

Non-working environment: NO traffic observed to Azure Cache for Redis in tcpdump taken in the Kubernetes worker node that runs the app pod with the proxy container - tcpdump host redisfqdn
Non-working environment: NO entry in either the default (info) or debug logs for the istio-proxy container logs - k logs consoleapp115001 -n istio-ns -c istio-proxy -f

Working environment: When using the excludeOutboundPorts annotation, or in a namespace not labelled for Istio, or within a non-clustered Redis environment, the Istio proxy container's logs in the app pod are referencing the redis IP: 

Non-working environment RedisConnectionException in the app logs:
Ping test:PING 10/31/2024 22:20:28 +00:00
Unhandled exception. StackExchange.Redis.RedisConnectionException: The message timed out in the backlog attempting to send because no connection became available (5000ms) - Last Connection Exception: SocketFailure on redis3696.redis.cache.windows.net:15001/Interactive, Initializing/NotStarted, last: NONE, origin: ConnectedAsync, outstanding: 0, last-read: 0s ago, last-write: 0s ago, keep-alive: 60s, state: Connecting, mgr: 10 of 10 available, last-heartbeat: never, global: 0s ago, v: 2.6.116.40240, command=UNKNOWN, timeout: 5000, inst: 0, qu: 1, qs: 0, aw: False, bw: SpinningDown, last-in: 0, cur-in: 0, sync-ops: 1, async-ops: 1, serverEndpoint: redis3696.redis.cache.windows.net:15001, conn-sec: n/a, aoc: 0, mc: 1/1/0, mgr: 10 of 10 available, clientName: l300app1(SE.Redis-v2.6.116.40240), IOCP: (Busy=0,Free=1000,Min=1,Max=1000), WORKER: (Busy=1,Free=32766,Min=2,Max=32767), POOL: (Threads=5,QueuedItems=0,CompletedItems=171), v: 2.6.116.40240 (Please take a look at this article for some common client-side issues that can cause timeouts: https://stackexchange.github.io/StackExchange.Redis/Timeouts)
 ---> StackExchange.Redis.RedisConnectionException: SocketFailure on redis3696.redis.cache.windows.net:15001/Interactive, Initializing/NotStarted, last: NONE, origin: ConnectedAsync, outstanding: 0, last-read: 0s ago, last-write: 0s ago, keep-alive: 60s, state: Connecting, mgr: 10 of 10 available, last-heartbeat: never, global: 0s ago, v: 2.6.116.40240
 ---> System.IO.IOException:  Received an unexpected EOF or 0 bytes from the transport stream.
   at System.Net.Security.SslStream.ReceiveBlobAsync[TIOAdapter](CancellationToken cancellationToken)
   at System.Net.Security.SslStream.ForceAuthenticationAsync[TIOAdapter](Boolean receiveFirst, Byte[] reAuthenticationData, CancellationToken cancellationToken)
   at System.Net.Security.SslStream.AuthenticateAsClient(SslClientAuthenticationOptions sslClientAuthenticationOptions)
   at StackExchange.Redis.ExtensionMethods.AuthenticateAsClientUsingDefaultProtocols(SslStream ssl, String host) in /_/src/StackExchange.Redis/ExtensionMethods.cs:line 206
   at StackExchange.Redis.ExtensionMethods.AuthenticateAsClient(SslStream ssl, String host, Nullable`1 allowedProtocols, Boolean checkCertificateRevocation) in /_/src/StackExchange.Redis/ExtensionMethods.cs:line 196
   at StackExchange.Redis.PhysicalConnection.ConnectedAsync(Socket socket, LogProxy log, SocketManager manager) in /_/src/StackExchange.Redis/PhysicalConnection.cs:line 1500
   --- End of inner exception stack trace ---
   --- End of inner exception stack trace ---
   at StackExchange.Redis.ConnectionMultiplexer.ExecuteSyncImpl[T](Message message, ResultProcessor`1 processor, ServerEndPoint server, T defaultValue) in /_/src/StackExchange.Redis/ConnectionMultiplexer.cs:line 2093
   at StackExchange.Redis.RedisBase.ExecuteSync[T](Message message, ResultProcessor`1 processor, ServerEndPoint server, T defaultValue) in /_/src/StackExchange.Redis/RedisBase.cs:line 62
   at StackExchange.Redis.RedisDatabase.Execute(String command, ICollection`1 args, CommandFlags flags) in /_/src/StackExchange.Redis/RedisDatabase.cs:line 1502
   at StackExchange.Redis.RedisDatabase.Execute(String command, Object[] args) in /_/src/StackExchange.Redis/RedisDatabase.cs:line 1497
   at RedisConnectionTest.Program.Main() in /src/l300app1/Program.cs:line 60
   at RedisConnectionTest.Program.<Main>()

Working environment default (/logging?level=info) logs: kubectl logs -n istio-ns l300app1 -c istio-proxy # 135.225.122.191 is IP for Redis, and the IP for the app pod is 10.244.1.24
[2024-10-31T23:17:18.912Z] "- - -" 0 - - - "-" 150559686 86191 62101 - "-" "-" "-" "-" "135.225.122.191:15002" PassthroughCluster 10.244.1.24:54872 135.225.122.191:15002 10.244.1.24:54864 - -
[2024-10-31T23:17:18.929Z] "- - -" 0 - - - "-" 116660592 72350 62085 - "-" "-" "-" "-" "135.225.122.191:15000" PassthroughCluster 10.244.1.24:33578 135.225.122.191:15000 10.244.1.24:33566 - -
[2024-10-31T23:17:18.927Z] "- - -" 0 - - - "-" 1243 6468 62095 - "-" "-" "-" "-" "135.225.122.191:15002" PassthroughCluster 10.244.1.24:54890 135.225.122.191:15002 10.244.1.24:54876 - -
[2024-10-31T23:17:18.755Z] "- - -" 0 - - - "-" 1265 6490 62268 - "-" "-" "-" "-" "135.225.122.191:6380" PassthroughCluster 10.244.1.24:38440 135.225.122.191:6380 10.244.1.24:38430 - -

Working environment - /logging?level=debug for the Envoy proxy logs (in addition to the /logging?level=info logs): kubectl logs -n istio-ns l300app1 -c istio-proxy | grep 13:26
2024-10-31T23:13:26.000076Z     debug   envoy filter external/envoy/source/extensions/filters/listener/original_dst/original_dst.cc:69      original_dst: set destination to 135.225.122.191:15001  thread=32
2024-10-31T23:13:26.000105Z     debug   envoy filter external/envoy/source/extensions/filters/listener/original_dst/original_dst.cc:69      original_dst: set destination to 135.225.122.191:15001  thread=32
2024-10-31T23:13:26.000143Z     debug   envoy filter external/envoy/source/common/tcp_proxy/tcp_proxy.cc:264    [Tags: "ConnectionId":"267"] new tcp proxy session  thread=32
2024-10-31T23:13:26.000160Z     debug   envoy filter external/envoy/source/common/tcp_proxy/tcp_proxy.cc:459    [Tags: "ConnectionId":"267"] Creating connection to cluster BlackHoleCluster        thread=32
2024-10-31T23:13:26.000176Z     debug   envoy upstream external/envoy/source/common/upstream/cluster_manager_impl.cc:2143   no healthy host for TCP connection pool thread=32
2024-10-31T23:13:26.000184Z     debug   envoy connection external/envoy/source/common/network/connection_impl.cc:149[Tags: "ConnectionId":"267"] closing data_to_write=0 type=1     thread=32
2024-10-31T23:13:26.000189Z     debug   envoy connection external/envoy/source/common/network/connection_impl.cc:281[Tags: "ConnectionId":"267"] closing socket: 1  thread=32
2024-10-31T23:13:26.000677Z     debug   envoy filter external/envoy/source/extensions/filters/listener/original_dst/original_dst.cc:69      original_dst: set destination to 135.225.122.191:15001  thread=33
2024-10-31T23:13:26.000700Z     debug   envoy filter external/envoy/source/extensions/filters/listener/original_dst/original_dst.cc:69      original_dst: set destination to 135.225.122.191:15001  thread=33
2024-10-31T23:13:26.000730Z     debug   envoy filter external/envoy/source/common/tcp_proxy/tcp_proxy.cc:264    [Tags: "ConnectionId":"268"] new tcp proxy session  thread=33
2024-10-31T23:13:26.000745Z     debug   envoy filter external/envoy/source/common/tcp_proxy/tcp_proxy.cc:459    [Tags: "ConnectionId":"268"] Creating connection to cluster BlackHoleCluster        thread=33
2024-10-31T23:13:26.000757Z     debug   envoy upstream external/envoy/source/common/upstream/cluster_manager_impl.cc:2143   no healthy host for TCP connection pool thread=33
2024-10-31T23:13:26.000763Z     debug   envoy connection external/envoy/source/common/network/connection_impl.cc:149[Tags: "ConnectionId":"268"] closing data_to_write=0 type=1     thread=33
2024-10-31T23:13:26.000767Z     debug   envoy connection external/envoy/source/common/network/connection_impl.cc:281[Tags: "ConnectionId":"268"] closing socket: 1  thread=33

Non-working environment - running tcpdump on the worker node that hosts the app pod (10.244.0.5) (which includes the connection string 15001) along with its istio-envoy container i.e. no TCP requests to Redis.
No	Time				Source		Destination  Protocol	Length	Identification	Interface index 	Type	Name
30672	2024-11-04 23:10:00.247690	10.244.0.5	10.244.1.6	DNS	99	0xb6a1 (46753)	3	A	redis3696.redis.cache.windows.net
30673	2024-11-04 23:10:00.247701	10.244.0.5	10.244.1.6	DNS	99	0xb6a1 (46753)	2	A	redis3696.redis.cache.windows.net
30675	2024-11-04 23:10:00.247706	10.244.0.5	10.244.1.6	DNS	99	0xb6a2 (46754)	3	AAAA	redis3696.redis.cache.windows.net
30676	2024-11-04 23:10:00.247710	10.244.0.5	10.244.1.6	DNS	99	0xb6a2 (46754)	2	AAAA	redis3696.redis.cache.windows.net
30677	2024-11-04 23:10:00.248643	10.244.1.6	10.244.0.5	DNS	194	0xe167 (57703)	2	AAAA	redis3696.redis.cache.windows.net
30678	2024-11-04 23:10:00.248643	10.244.1.6	10.244.0.5	DNS	258	0xe168 (57704)	2	A	redis3696.redis.cache.windows.net

Non-working environment - When running tcpdump in the app pod (which includes the connection string 15001) along with its istio-envoy container, we're consistently only observing repeated DNS queries similar to the ones below i.e. no TCP requests to Redis.
23:27:28.383652 IP consoleapp115001.59880 > kube-dns.kube-system.svc.cluster.local.53: 1521+ PTR? 10.0.0.10.in-addr.arpa. (40)
23:27:28.386150 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.59880: 1521*- 1/0/0 PTR kube-dns.kube-system.svc.cluster.local. (114)
23:27:29.331417 IP consoleapp115001.47342 > kube-dns.kube-system.svc.cluster.local.53: 63079+ A? redis3696.redis.cache.windows.net.istio-ns.svc.cluster.local. (78)
23:27:29.331494 IP consoleapp115001.47342 > kube-dns.kube-system.svc.cluster.local.53: 8803+ AAAA? redis3696.redis.cache.windows.net.istio-ns.svc.cluster.local. (78)
23:27:29.332714 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.47342: 8803 NXDomain*- 0/1/0 (171)
23:27:29.332718 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.47342: 63079 NXDomain*- 0/1/0 (171)
23:27:29.332814 IP consoleapp115001.50027 > kube-dns.kube-system.svc.cluster.local.53: 31868+ A? redis3696.redis.cache.windows.net.svc.cluster.local. (69)
23:27:29.332860 IP consoleapp115001.50027 > kube-dns.kube-system.svc.cluster.local.53: 16251+ AAAA? redis3696.redis.cache.windows.net.svc.cluster.local. (69)
23:27:29.333775 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.50027: 16251 NXDomain*- 0/1/0 (162)
23:27:29.333779 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.50027: 31868 NXDomain*- 0/1/0 (162)
23:27:29.333845 IP consoleapp115001.45092 > kube-dns.kube-system.svc.cluster.local.53: 13825+ A? redis3696.redis.cache.windows.net.cluster.local. (65)
23:27:29.333868 IP consoleapp115001.45092 > kube-dns.kube-system.svc.cluster.local.53: 61471+ AAAA? redis3696.redis.cache.windows.net.cluster.local. (65)
23:27:29.334654 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.45092: 61471 NXDomain*- 0/1/0 (158)
23:27:29.334657 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.45092: 13825 NXDomain*- 0/1/0 (158)
23:27:29.334716 IP consoleapp115001.39706 > kube-dns.kube-system.svc.cluster.local.53: 62384+ A? redis3696.redis.cache.windows.net.iadvu1gt1enejea4k3is5a0h3d.gvxx.internal.cloudapp.net. (105)
23:27:29.334736 IP consoleapp115001.39706 > kube-dns.kube-system.svc.cluster.local.53: 54965+ AAAA? redis3696.redis.cache.windows.net.iadvu1gt1enejea4k3is5a0h3d.gvxx.internal.cloudapp.net. (105)
23:27:29.335635 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.39706: 54965 NXDomain* 0/1/0 (215)
23:27:29.335639 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.39706: 62384 NXDomain* 0/1/0 (215)
23:27:29.335693 IP consoleapp115001.42641 > kube-dns.kube-system.svc.cluster.local.53: 46017+ A? redis3696.redis.cache.windows.net. (51)
23:27:29.335711 IP consoleapp115001.42641 > kube-dns.kube-system.svc.cluster.local.53: 9414+ AAAA? redis3696.redis.cache.windows.net. (51)
23:27:29.337259 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.42641: 9414* 1/0/0 CNAME sec-49880-762198531.vnet.redis.cache.windows.net. (146)
23:27:29.337263 IP kube-dns.kube-system.svc.cluster.local.53 > consoleapp115001.42641: 46017* 2/0/0 CNAME sec-49880-762198531.vnet.redis.cache.windows.net., A 135.225.122.191 (210)
```

- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes#potential-connection-collision-with-istioenvoy
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-troubleshoot-connectivity#kubernetes-hosted-applications: If you're using Istio or any other service mesh, check that your service mesh proxy reserves port 13000-13019 or 15000-15019. These ports are used by clients to communicate with a clustered Azure Cache For Redis nodes and could cause connectivity issues on those ports.
- https://discuss.istio.io/t/istio-in-azure-aks-outbound-traffic-issues-over-15001-port-while-connecting-to-azure-redis-cache/10412/2: istio-iptables -p
- https://github.com/istio/cni/blob/master/tools/packaging/common/istio-iptables.sh: -p: Specify the envoy port to which redirect all TCP traffic (default $ENVOY_PORT = 15001). -z: Port to which all inbound TCP traffic to the pod/VM should be redirected to. For REDIRECT only (default $INBOUND_CAPTURE_PORT = 15006)
- https://istio.io/latest/docs/reference/commands/pilot-agent/: 150*
- https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-best-practices-kubernetes#potential-connection-collision-with-istioenvoy: When using Istio with an Azure Cache for Redis cluster, consider excluding the potential collision ports with an istio annotation. annotations: traffic.sidecar.istio.io/excludeOutboundPorts: "15000,15001,15004,15006,15008,15009,15020"
- https://github.com/istio/istio/issues/43655: Make port 15006 configurable. we may need to make all ports configurable long-term
- https://stackoverflow.com/questions/67394030/istio-in-azure-aks-connection-issues-over-15001-port-while-connecting-to-azure: I could not see any entry in istio-proxy logs when trying from 15001 port. However when trying for other ports we can see entry
- - https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-scale?#can-i-directly-connect-to-the-individual-shards-of-my-cache: For non-TLS Premium tier caches, ports are available in the 130XX range. For TLS enabled Premium tier caches, ports are available in the 150XX range
  
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

- https://istio.io/latest/docs/ops/deployment/architecture/: The data plane is composed of a set of intelligent proxies (Envoy) deployed as sidecars. These proxies mediate and control all network communication between microservices. They also collect and report telemetry on all mesh traffic. The control plane manages and configures the proxies to route traffic.
- https://istio.io/latest/docs/ops/deployment/architecture/#envoy
- https://www.envoyproxy.io/docs/envoy/latest/

## k8s-servicemesh-istio.spec.other.proxy.Envoy.debug

```
# sidecar
# The istio-proxy container is the Envoy sidecar injected by Istio.
kubectl run nginx --image=nginx -n istio-ns
kubectl describe po nginx -n istio-ns | grep proxy # mcr.microsoft.com/oss/istio/proxyv2:1.22.5-distroless

# webhook
# The sidecar containers are injected using a mutating admission webhook seen with `kubectl get mutatingwebhookconfigurations | grep istio-sidecar-injector`.
kubectl get mutatingwebhookconfigurations --show-labels | grep istio-sidecar-injector
istio-sidecar-injector-asm-1-22-aks-istio-system   3          6d8h   admissions.enforcer/disabled=true,app.kubernetes.io/managed-by=Helm,app=sidecar-injector,helm.toolkit.fluxcd.io/name=azure-service-mesh-istio-discovery-helmrelease,helm.toolkit.fluxcd.io/namespace=671b6f9eecf8e1000192e150,install.operator.istio.io/owning-resource=unknown,istio.io/rev=asm-1-22,operator.istio.io/component=Pilot,release=azure-service-mesh-istio-discovery
# kubectl describe mutatingwebhookconfigurations -l app=sidecar-injector

# debug proxy-status
# If an envoy (application pod) is missing from the output, it means that it is not currently connected to an Istio Pilot instance and thus will not receive any configuration.
kubectl run nginx --image=nginx -n istio-ns
istioctl proxy-status -i aks-istio-system
NAME                  CLUSTER        CDS        LDS        EDS        RDS        ECDS         ISTIOD                               VERSION
nginx.istio-ns        Kubernetes     SYNCED     SYNCED     SYNCED     SYNCED     NOT SENT     istiod-asm-1-22-5d6d4f8b44-9xbl2     1.22-dev
# To retrieve information about proxy configuration from an Envoy instance, run `istioctl proxy-config -i aks-istio-system all -o json hello -n default` for example for pod 'hello' in namespace 'default'. Instead of 'all', one of 'clusters|listeners|routes|endpoints|bootstrap|log|secret' can be used.
istioctl proxy-config -i aks-istio-system all -o json -n istio-ns nginx
```

- `CDS`, `LDS`, `EDS`, `RDS`, and `ECDS`, seen in the output of the above command, are Envoy (the proxy underpinning Istio) services mentioned [here](https://github.com/istio/istio/issues/34139#issuecomment-1064377239) and [here](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/operations/dynamic_configuration
- `SYNCED` and `NOT SENT` statuses are usually seen, `STALE` usually indicates a networking issue between Envoy and Istiod as indicated [here](https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/).
- https://istio.io/latest/docs/ops/diagnostic-tools/proxy-cmd/#deep-dive-into-envoy-configuration

## k8s-servicemesh-istio.spec.other.proxy.Envoy.debug.level=debug

```
# The fastest method involves using curl if it's supported by the application image.
# kubectl delete po -n istio-ns nginx; kubectl run --image=nginx -n istio-ns nginx
kubectl exec -n istio-ns nginx -c istio-proxy -- curl -XPOST http://localhost:15000/logging?level=debug
# kubectl logs -n istio-ns nginx -c istio-proxy # (debug) proxy logs from the same pod

# Another option is using a debug pod.
# kubectl delete po -n istio-ns nginx; kubectl run --image=nginx -n istio-ns nginx
kubectl debug -it --image=debian:latest -n istio-ns nginx
apt-get update -y && apt-get install curl -y
# curl -XPOST http://localhost:9901/logging?level=debug # curl: (7) Failed to connect to localhost port 9901 after 0 ms: Couldn't connect to server
curl -XPOST http://localhost:15000/logging?level=debug # active loggers: admin: debug...
# kubectl logs -n istio-ns nginx -c istio-proxy # (debug) proxy logs from the same pod

# Another option is using a debug pod - one-liner to set the envoy proxy's verbosity level to debug
# kubectl debug -it --image=debian:latest -n istio-ns nginx
apt update -y && apt install curl -y && curl -XPOST http://localhost:15000/logging?level=debug
# kubectl logs -n istio-ns nginx -c istio-proxy
2024-10-31T22:48:01.361008Z     info    envoy misc external/envoy/source/common/common/logger.cc:220    change all log levels: level='debug'        thread=25
...

# Another option is using a debug pod - one-liner to set the envoy proxy's verbosity level to info (default)
# kubectl debug -it --image=debian:latest -n istio-ns nginx
apt update -y && apt install curl -y && curl -XPOST http://localhost:15000/logging?level=info
# kubectl logs -n istio-ns nginx -c istio-proxy
2024-10-31T22:45:57.528118Z     debug   envoy admin external/envoy/source/server/admin/admin_filter.cc:85       [Tags: "ConnectionId":"374","StreamId":"15789722398203259145"] request complete: path: /logging?level=info  thread=25
2024-10-31T22:45:57.528133Z     info    envoy misc external/envoy/source/common/common/logger.cc:220    change all log levels: level='info' thread=25
```

```
/logging?level=info
[2024-10-31T23:17:18.912Z] "- - -" 0 - - - "-" 150559686 86191 62101 - "-" "-" "-" "-" "135.225.122.191:15002" PassthroughCluster 10.244.1.24:54872 135.225.122.191:15002 10.244.1.24:54864 - -
[2024-10-31T23:17:18.929Z] "- - -" 0 - - - "-" 116660592 72350 62085 - "-" "-" "-" "-" "135.225.122.191:15000" PassthroughCluster 10.244.1.24:33578 135.225.122.191:15000 10.244.1.24:33566 - -

/logging?level=debug (in addition to the /logging?level=info logs)
2024-10-31T23:13:26.000076Z     debug   envoy filter external/envoy/source/extensions/filters/listener/original_dst/original_dst.cc:69      original_dst: set destination to 135.225.122.191:15001  thread=32
2024-10-31T23:13:26.000176Z     debug   envoy upstream external/envoy/source/common/upstream/cluster_manager_impl.cc:2143   no healthy host for TCP connection pool thread=32
2024-10-31T23:13:26.000184Z     debug   envoy connection external/envoy/source/common/network/connection_impl.cc:149[Tags: "ConnectionId":"267"] closing data_to_write=0 type=1     thread=32
...
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting#step-6-get-more-information-about-the-envoy-configuration: -- curl -s localhost:15000/clusters
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/extensions/istio-add-on-general-troubleshooting#step-7-get-the-sidecar-logs-for-the-source-and-destination-sidecars: kubectl logs <pod-name> --namespace <pod-namespace> --container istio-proxy
- https://layer5.io/blog/service-mesh/debug-envoy-proxy: curl -X POST \ http://localhost:15000/logging?level=debug
- https://stackoverflow.com/questions/77134294/how-to-change-log-level-of-envoy-proxy-with-environment-variable: curl -XPOST http://localhost:9901/logging?level=debug
- https://www.envoyproxy.io/docs/envoy/latest/start/quick-start/run-envoy#debugging-envoy

## k8s-servicemesh-istio.tool.istioctl

```
# See the section on Envoy.debug (istioctl proxy-status)

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

istioctl admin log -i aks-istio-egress --level ads:debug,authorization:debug # Error: no pods found
istioctl admin log -i aks-istio-system --reset # Error: no pods found

istioctl bug-report -i aks-istio-system
...
Creating an archive at /tmp/bug-report.tar.gz.
Time used for creating the tar file is 87.176402ms.
Cleaning up temporary files in /tmp/bug-report.
Done.
```

- https://istio.io/latest/docs/setup/getting-started/#download

