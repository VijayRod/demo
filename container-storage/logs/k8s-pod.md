## pod.containers.livenessProbe

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/

### pod.containers.livenessProbe.command

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
```

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command

### pod.containers.livenessProbe.http

```
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
```

- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-http-request
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/: A common pattern for liveness probes is to use the same low-cost HTTP endpoint as for readiness probes, but with a higher failureThreshold. This ensures that the pod is observed as not-ready for some period of time before it is hard killed...
