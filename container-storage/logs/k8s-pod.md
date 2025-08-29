- https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/

## pod.containers.livenessProbe

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

### pod.containers.livenessProbe.command

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command
  
```
kubectl delete po liveness-exec
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-exec
spec:
  containers:
  - name: liveness
    image: registry.k8s.io/busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command: # To perform a probe, the kubelet executes the command cat /tmp/healthy in the target container i.e. kubelet and non-http probe
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5 # tells the kubelet that it should wait 5 seconds before performing the first probe
      periodSeconds: 5 # kubelet should perform a liveness probe every 5 seconds
EOF
k get po -owide -w

k describe po liveness-exec
Containers:
  liveness:
    State:          Running
      Started:      Fri, 16 May 2025 12:36:35 +0000
    Last State:     Terminated
      Reason:       Error
      Exit Code:    137
      Started:      Fri, 16 May 2025 12:35:20 +0000
      Finished:     Fri, 16 May 2025 12:36:34 +0000
    Ready:          True
    Restart Count:  2
    Liveness:       exec [cat /tmp/healthy] delay=5s timeout=1s period=5s #success=1 #failure=3

# 'prober.go:107] "Probe failed" probeType="Liveness"', 'probeResult="failure" output=<'
# 'kubelet.go:2528] "SyncLoop (probe)" probe="liveness" status="unhealthy"'
# 'containerMessage="Container liveness failed liveness probe, will be restarted"'
# '"Killing container with a grace period"'
May 16 18:34:04 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:04.558677    4052 kubelet.go:2407] "SyncLoop ADD" source="api" pods=["default/liveness-exec"]
..
May 16 18:34:06 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:06.951598    4052 kubelet.go:2439] "SyncLoop (PLEG): event for pod" pod="default/liveness-exec" event={"ID":"93e17ecc-ab55-461a-b526-29248d2554ad","Type":"ContainerStarted","Data":"05657a9c673d612aedd955a65136ccca36b82ba987831de7844cdc0238f1d707"}
May 16 18:34:06 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:06.965438    4052 pod_startup_latency_tracker.go:104] "Observed pod startup duration" pod="default/liveness-exec" podStartSLOduration=2.066691337 podStartE2EDuration="2.965419007s" podCreationTimestamp="2025-05-16 18:34:04 +0000 UTC" firstStartedPulling="2025-05-16 18:34:05.069571752 +0000 UTC m=+13458.285732079" lastFinishedPulling="2025-05-16 18:34:05.968299422 +0000 UTC m=+13459.184459749" observedRunningTime="2025-05-16 18:34:06.965398807 +0000 UTC m=+13460.181559234" watchObservedRunningTime="2025-05-16 18:34:06.965419007 +0000 UTC m=+13460.181579634"
May 16 18:34:39 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:39.885628    4052 prober.go:107] "Probe failed" probeType="Liveness" pod="default/liveness-exec" podUID="93e17ecc-ab55-461a-b526-29248d2554ad" containerName="liveness" probeResult="failure" output=<
May 16 18:34:44 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:44.887534    4052 prober.go:107] "Probe failed" probeType="Liveness" pod="default/liveness-exec" podUID="93e17ecc-ab55-461a-b526-29248d2554ad" containerName="liveness" probeResult="failure" output=<
May 16 18:34:49 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:49.885197    4052 prober.go:107] "Probe failed" probeType="Liveness" pod="default/liveness-exec" podUID="93e17ecc-ab55-461a-b526-29248d2554ad" containerName="liveness" probeResult="failure" output=<
May 16 18:34:49 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:49.885264    4052 kubelet.go:2528] "SyncLoop (probe)" probe="liveness" status="unhealthy" pod="default/liveness-exec"
May 16 18:34:49 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:49.885576    4052 kuberuntime_manager.go:1027] "Message for Container of pod" containerName="liveness" containerStatusID={"Type":"containerd","ID":"05657a9c673d612aedd955a65136ccca36b82ba987831de7844cdc0238f1d707"} pod="default/liveness-exec" containerMessage="Container liveness failed liveness probe, will be restarted"
May 16 18:34:49 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:34:49.885621    4052 kuberuntime_container.go:808] "Killing container with a grace period" pod="default/liveness-exec" podUID="93e17ecc-ab55-461a-b526-29248d2554ad" containerName="liveness" containerID="containerd://05657a9c673d612aedd955a65136ccca36b82ba987831de7844cdc0238f1d707" gracePeriod=30
May 16 18:35:20 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:35:20.075426    4052 kubelet.go:2439] "SyncLoop (PLEG): event for pod" pod="default/liveness-exec" event={"ID":"93e17ecc-ab55-461a-b526-29248d2554ad","Type":"ContainerDied","Data":"05657a9c673d612aedd955a65136ccca36b82ba987831de7844cdc0238f1d707"}
May 16 18:35:21 aks-nodepool1-29985679-vmss00000A kubelet[4052]: I0516 18:35:21.078268    4052 kubelet.go:2439] "SyncLoop (PLEG): event for pod" pod="default/liveness-exec" event={"ID":"93e17ecc-ab55-461a-b526-29248d2554ad","Type":"ContainerStarted","Data":"c6f825e51b97cba5742a8a857c789ed287ecd4bec7775e92473559d56026ef09"}

# pod: tcpdump - none since the liveness probe is a command
# node: tcpdump (remove "rm -f /tmp/healthy" from the liveness command to prevent the pod from restarting soon) - none since the liveness probe is a command
```

### pod.containers.livenessProbe.http

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/: A common pattern for liveness probes is to use the same low-cost HTTP endpoint as for readiness probes, but with a higher failureThreshold. This ensures that the pod is observed as not-ready for some period of time before it is hard killed...
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#http-probes: the kubelet sends an HTTP request to the specified port and path to perform the check. The kubelet sends the probe to the Pod's IP address

```
# probe.liveness.http

kubectl delete po liveness-http
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: registry.k8s.io/e2e-test-images/agnhost:2.40
    args:
    - liveness
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
EOF
kubectl get pod/liveness-http
kubectl describe pod/liveness-http

NAME            READY   STATUS             RESTARTS      AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
liveness-http   0/1     CrashLoopBackOff   6 (28s ago)   4m31s   10.244.0.14   aks-nodepool1-63915749-vmss000001   <none>           <none>
  Normal   Started    13s (x4 over 70s)  kubelet            Started container liveness
  Warning  Unhealthy  13s (x9 over 58s)  kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    13s (x3 over 52s)  kubelet            Container liveness failed liveness probe, will be restarted
  Normal   Pulled     13s (x3 over 50s)  kubelet            Container image "registry.k8s.io/e2e-test-images/agnhost:2.40" already present on machine
  
tcpdump node
wireshark tcp.port==8080 and ip.addr==10.244.0.14
5083	2024-09-30 18:28:44.709076	10.244.0.1	10.244.0.14	TCP	80	58150 ? 8080 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=4215903182 TSecr=0 WS=128
5085	2024-09-30 18:28:44.709100	10.244.0.14	10.244.0.1	TCP	80	8080 ? 58150 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1558158114 TSecr=4215903182 WS=128
5087	2024-09-30 18:28:44.709119	10.244.0.1	10.244.0.14	TCP	72	58150 ? 8080 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4215903183 TSecr=1558158114
5089	2024-09-30 18:28:44.709436	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
5091	2024-09-30 18:28:44.709462	10.244.0.14	10.244.0.1	TCP	72	8080 ? 58150 [ACK] Seq=1 Ack=135 Win=65152 Len=0 TSval=1558158114 TSecr=4215903183
5093	2024-09-30 18:28:44.709591	10.244.0.14	10.244.0.1	HTTP	209	HTTP/1.1 200 OK  (text/plain)
5095	2024-09-30 18:28:44.709605	10.244.0.1	10.244.0.14	TCP	72	58150 ? 8080 [ACK] Seq=135 Ack=138 Win=64128 Len=0 TSval=4215903183 TSecr=1558158114
5097	2024-09-30 18:28:44.709664	10.244.0.14	10.244.0.1	TCP	72	8080 ? 58150 [FIN, ACK] Seq=138 Ack=135 Win=65152 Len=0 TSval=1558158114 TSecr=4215903183
5099	2024-09-30 18:28:44.709742	10.244.0.1	10.244.0.14	TCP	72	58150 ? 8080 [FIN, ACK] Seq=135 Ack=139 Win=64128 Len=0 TSval=4215903183 TSecr=1558158114
5101	2024-09-30 18:28:44.709750	10.244.0.14	10.244.0.1	TCP	72	8080 ? 58150 [ACK] Seq=139 Ack=136 Win=65152 Len=0 TSval=1558158114 TSecr=4215903183
5422	2024-09-30 18:28:47.709070	10.244.0.1	10.244.0.14	TCP	80	58158 ? 8080 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=4215906182 TSecr=0 WS=128
5424	2024-09-30 18:28:47.709098	10.244.0.14	10.244.0.1	TCP	80	8080 ? 58158 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=1558161114 TSecr=4215906182 WS=128
5426	2024-09-30 18:28:47.709118	10.244.0.1	10.244.0.14	TCP	72	58158 ? 8080 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=4215906183 TSecr=1558161114
5428	2024-09-30 18:28:47.709233	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
5430	2024-09-30 18:28:47.709243	10.244.0.14	10.244.0.1	TCP	72	8080 ? 58158 [ACK] Seq=1 Ack=135 Win=65152 Len=0 TSval=1558161114 TSecr=4215906183
5432	2024-09-30 18:28:47.709339	10.244.0.14	10.244.0.1	HTTP	209	HTTP/1.1 200 OK  (text/plain)
i.e.
5089	2024-09-30 18:28:44.709436	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
I\"GET /healthz HTTP/1.1
Host: 10.244.0.14:8080
User-Agent: kube-probe/1.29
Accept: */*
Custom-Header: Awesome
Connection: close
5093	2024-09-30 18:28:44.709591	10.244.0.14	10.244.0.1	HTTP	209	HTTP/1.1 200 OK  (text/plain)
5428	2024-09-30 18:28:47.709233	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
5432	2024-09-30 18:28:47.709339	10.244.0.14	10.244.0.1	HTTP	209	HTTP/1.1 200 OK  (text/plain)
6158	2024-09-30 18:28:50.708980	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
6162	2024-09-30 18:28:50.709143	10.244.0.14	10.244.0.1	HTTP	209	HTTP/1.1 200 OK  (text/plain)
6531	2024-09-30 18:28:53.709303	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
6535	2024-09-30 18:28:53.709430	10.244.0.14	10.244.0.1	HTTP	246	HTTP/1.1 500 Internal Server Error  (text/plain)
6724	2024-09-30 18:28:56.709092	10.244.0.1	10.244.0.14	HTTP	206	GET /healthz HTTP/1.1 
6728	2024-09-30 18:28:56.709196	10.244.0.14	10.244.0.1	HTTP	245	HTTP/1.1 500 Internal Server Error  (text/plain)

az network vnet subnet show -g MC_rg_aks_swedencentral --vnet-name aks-vnet-92427521 -n aks-subnet --query addressPrefix -otsv
10.224.0.0/16

# node (kubenet cluster): tcpdump - tbd there is no traffic to the pod since the request is being sent by the kubelet within the same node (note that no lb service defined here)

# pod (kubenet cluster): tcpdump - node ip to pod ip
kubectl netshoot debug liveness-http
tcpdump | grep HTTP
18:57:08.912728 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.46410 > liveness-http.8080: Flags [P.], seq 1:136, ack 1, win 502, options [nop,nop,TS val 4053454415 ecr 1003138986], length 135: HTTP: GET /healthz HTTP/1.1
18:57:08.913053 IP liveness-http.8080 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.46410: Flags [P.], seq 1:138, ack 136, win 509, options [nop,nop,TS val 1003138987 ecr 4053454415], length 137: HTTP: HTTP/1.1 200 OK
18:57:11.911973 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.34410 > liveness-http.8080: Flags [P.], seq 1:136, ack 1, win 502, options [nop,nop,TS val 4053457415 ecr 1003141985], length 135: HTTP: GET /healthz HTTP/1.1
18:57:11.912215 IP liveness-http.8080 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.34410: Flags [P.], seq 1:138, ack 136, win 509, options [nop,nop,TS val 1003141986 ecr 4053457415], length 137: HTTP: HTTP/1.1 200 OK
PING aks-nodepool1-14724824-vmss000001.internal.cloudapp.net (10.224.0.4) 56(84) bytes of data.
```

```
# probe.liveness.http.lb

kubectl delete svc liveness-agnhost
kubectl delete po liveness-agnhost
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: agnhost
  name: liveness-agnhost
spec:
  containers:
    - name: agnhost
      image: registry.k8s.io/e2e-test-images/agnhost:2.39
      args:
        - serve-hostname
        - --http=true
        - --port=8080
      ports:
        - containerPort: 8080
      livenessProbe:
        httpGet:
          path: /healthz
          port: 8080
        initialDelaySeconds: 5
        periodSeconds: 5
        timeoutSeconds: 2
EOF
kubectl get po -owide -w
kubectl describe po liveness-agnhost | tail
kubectl expose pod/liveness-agnhost --type=LoadBalancer --port 8080; kubectl get svc -w
k get po liveness-agnhost -owide; kubectl get no -owide


# node: tcpdump - lb to node ip
root@aks-nodepool1-14724824-vmss000001:/# tcpdump port 31229
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:09:00.914189 IP 168.63.129.16.56360 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [SEW], seq 2714777894, win 64240, options [mss 1440,nop,wscale 8,nop,nop,sackOK], length 0
18:09:00.914255 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229 > 168.63.129.16.56360: Flags [S.], seq 3881067145, ack 2714777895, win 64240, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0
18:09:00.914532 IP 168.63.129.16.56360 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [.], ack 1, win 16385, length 0
18:09:05.916887 IP 168.63.129.16.56360 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [F.], seq 1, ack 1, win 16385, length 0
18:09:05.917108 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229 > 168.63.129.16.56360: Flags [F.], seq 1, ack 2, win 502, length 0
18:09:05.917342 IP 168.63.129.16.56360 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [.], ack 2, win 16385, length 0

18:09:05.918020 IP 168.63.129.16.56450 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [SEW], seq 2455653299, win 64240, options [mss 1440,nop,wscale 8,nop,nop,sackOK], length 0
18:09:05.918079 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229 > 168.63.129.16.56450: Flags [S.], seq 3042026384, ack 2455653300, win 64240, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0
18:09:05.918310 IP 168.63.129.16.56450 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [.], ack 1, win 16385, length 0
18:09:10.920414 IP 168.63.129.16.56450 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [F.], seq 1, ack 1, win 16385, length 0
18:09:10.920664 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229 > 168.63.129.16.56450: Flags [F.], seq 1, ack 2, win 502, length 0
18:09:10.920960 IP 168.63.129.16.56450 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.31229: Flags [.], ack 2, win 16385, length 0


# node: tcpdump - from node ip to pod ip 10.244.1.228 on httpGet.port 8080
root@aks-nodepool1-14724824-vmss000001:/# tcpdump port 8080
18:57:18.500113 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.31041 > 10.244.1.228.http-alt: Flags [SEW], seq 1238502879, win 64240, options [mss 1390,nop,wscale 8,nop,nop,sackOK], length 0
18:57:18.500255 IP 10.244.1.228.http-alt > aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.31041: Flags [S.], seq 3296570580, ack 1238502880, win 64240, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0
18:57:18.500903 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.31041 > 10.244.1.228.http-alt: Flags [.], ack 1, win 49157, length 0
18:57:23.515570 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.31041 > 10.244.1.228.http-alt: Flags [F.], seq 1, ack 1, win 49157, length 0
18:57:23.515787 IP 10.244.1.228.http-alt > aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.31041: Flags [F.], seq 1, ack 2, win 502, length 0
18:57:23.517591 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.31041 > 10.244.1.228.http-alt: Flags [.], ack 2, win 49157, length 0

18:57:23.520546 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.22876 > 10.244.1.228.http-alt: Flags [SEW], seq 4206141713, win 64240, options [mss 1390,nop,wscale 8,nop,nop,sackOK], length 0
18:57:23.520608 IP 10.244.1.228.http-alt > aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.22876: Flags [S.], seq 3972370641, ack 4206141714, win 64240, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0
18:57:23.522142 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.22876 > 10.244.1.228.http-alt: Flags [.], ack 1, win 49157, length 0
18:57:28.525020 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.22876 > 10.244.1.228.http-alt: Flags [F.], seq 1, ack 1, win 49157, length 0
18:57:28.525253 IP 10.244.1.228.http-alt > aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.22876: Flags [F.], seq 1, ack 2, win 502, length 0
18:57:28.526992 IP aks-nodepool1-14724824-vmss000000.internal.cloudapp.net.22876 > 10.244.1.228.http-alt: Flags [.], ack 2, win 49157, length 0

PING aks-nodepool1-14724824-vmss000000.internal.cloudapp.net (10.224.0.5) 56(84) bytes of data.


# pod: tcpdump
k netshoot debug liveness-agnhost
tcpdump | grep HTTP
18:06:24.056327 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.38920 > liveness-agnhost.8080: Flags [P.], seq 1:112, ack 1, win 502, options [nop,nop,TS val 1925199290 ecr 1060421532], length 111: HTTP: GET /healthz HTTP/1.1
18:06:24.056335 IP liveness-agnhost.8080 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.38920: Flags [.], ack 112, win 509, options [nop,nop,TS val 1060421532 ecr 1925199290], length 0
18:06:24.056500 IP liveness-agnhost.8080 > aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.38920: Flags [P.], seq 1:153, ack 112, win 509, options [nop,nop,TS val 1060421532 ecr 1925199290], length 152: HTTP: HTTP/1.1 200 OK
18:06:24.056521 IP aks-nodepool1-14724824-vmss000001.internal.cloudapp.net.38920 > liveness-agnhost.8080: Flags [.], ack 153, win 501, options [nop,nop,TS val 1925199290 ecr 1060421532], length 0
```
  
## pod.error

### Error 'spec.initContainers: Forbidden: pod updates may not add or remove containers'

```
Error: "The Pod "web-nginx" is invalid: spec.initContainers: Forbidden: pod updates may not add or remove containers'

Error2: "The Pod "web-nginx" is invalid: spec.Containers: Forbidden: pod updates may not add or remove containers'
```

```
# tbd https://github.com/hashicorp/vault/issues/11064: a MutatingWebHook on the pod.
kubectl get mutatingwebhookconfiguration
kubectl get validatingwebhookconfiguration
```
