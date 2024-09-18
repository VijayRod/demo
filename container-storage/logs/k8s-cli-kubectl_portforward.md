## kubectl.tools/portforward

```
kubectl delete po nginx
kubectl delete svc nginx
kubectl run nginx --image=nginx
kubectl expose po nginx --port=8080 --target-port=80
kubectl get po,svc

kubectl port-forward pod/nginx :8080
Forwarding from 127.0.0.1:36373 -> 8080
Forwarding from [::1]:36373 -> 8080
# Or
kubectl port-forward pod/nginx 8081:8080
Forwarding from 127.0.0.1:8081 -> 8080
Forwarding from [::1]:8081 -> 8080
```

- https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_port-forward/
- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward
- https://k8s-docs.netlify.app/en/docs/tasks/access-application-cluster/port-forward-access-application-cluster/

```
kubectl port-forward pod/nginx :8080 -v=9
...
I0918 19:56:33.878755    4438 request.go:1188] Response Body: {"kind":"Pod",...
I0918 19:56:33.882219    4438 round_trippers.go:466] curl -v -XPOST  -H "User-Agent: kubectl/v1.27.1 (linux/amd64) kubernetes/4c94112" -H "Authorization: Bearer <masked>" -H "X-Stream-Protocol-Version: portforward.k8s.io" 'https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx/portforward'
I0918 19:56:33.967719    4438 round_trippers.go:495] HTTP Trace: DNS Lookup for aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io resolved to [{20.240.159.12 }]
I0918 19:56:34.054893    4438 round_trippers.go:510] HTTP Trace: Dial to tcp:20.240.159.12:443 succeed
I0918 19:56:34.271636    4438 round_trippers.go:553] POST https://aks-rg-efec8e-tgdhcfxs.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/default/pods/nginx/portforward 101 Switching Protocols in 389 milliseconds
I0918 19:56:34.271720    4438 round_trippers.go:570] HTTP Statistics: DNSLookup 85 ms Dial 87 ms TLSHandshake 0 ms Duration 389 ms
I0918 19:56:34.271732    4438 round_trippers.go:577] Response Headers:
I0918 19:56:34.271746    4438 round_trippers.go:580]     X-Stream-Protocol-Version: portforward.k8s.io
I0918 19:56:34.271756    4438 round_trippers.go:580]     Date: Wed, 18 Sep 2024 19:56:34 GMT
I0918 19:56:34.271766    4438 round_trippers.go:580]     Connection: Upgrade
I0918 19:56:34.271776    4438 round_trippers.go:580]     Upgrade: SPDY/3.1
Forwarding from 127.0.0.1:42345 -> 8080
Forwarding from [::1]:42345 -> 8080
# tbd kubectl exec -it nginx -- curl localhost -I # HTTP/1.1 200 OK
```

- tbd https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/tools/portforward/portforward.go
- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/client-go/transport/round_trippers.go

```
kubectl port-forward pod/nginx :8080 -v=9
Forwarding from 127.0.0.1:43097 -> 8080
Forwarding from [::1]:43097 -> 8080
Handling connection for 43097
E0918 19:12:09.017100    4512 portforward.go:409] an error occurred forwarding 43097 -> 8080: error forwarding port 8080 to pod 80c8c5d701fd37ee2af53f478c71bac6a843f28e3c1cd6647e849476f0ca757f, uid : failed to execute portforward in network namespace "/var/run/netns/cni-771664c9-98d5-1f98-f9ec-dc59bbc317b8": failed to connect to localhost:8080 inside namespace "80c8c5d701fd37ee2af53f478c71bac6a843f28e3c1cd6647e849476f0ca757f", IPv4: dial tcp4 127.0.0.1:8080: connect: connection refused IPv6 dial tcp6: address localhost: no suitable address found
I0918 19:12:09.017443    4512 connection.go:198] SPDY Ping failed: connection closed
error: lost connection to pod
# curl http://127.0.0.1:43097 # curl: (52) Empty reply from server


kubectl delete po mongo
kubectl delete svc mongo
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: mongo
  labels:
    app.kubernetes.io/name: mongo
    app.kubernetes.io/component: backend
spec:
  containers:
  - image: mongo:4.2
    name: mongo
    args:
      - --bind_ip
      - 0.0.0.0
    ports:
      - containerPort: 27017
EOF
kubectl expose po mongo --port=27017 --target-port=27017
kubect get po,svc

kubectl dumpy capture node aks-nodepool1-30589603-vmss000001
# tbd for loopback traffic tcpdump -w /tmp/tcpdump/capture # wireshark tcp.port=7000 and capture traffic on the loopback adapter
kubectl port-forward pod/mongo 7000:27017 # Browser: http://127.0.0.1:7000/ # It looks like you are trying to access MongoDB over HTTP on the native driver port.
Forwarding from 127.0.0.1:7000 -> 27017
Forwarding from [::1]:7000 -> 27017
Handling connection for 7000
Handling connection for 7000

tbd ssl from apiserver
kubectl dumpy export dumpy-55278020 /tmp/tcpdump
kubectl dumpy stop dumpy-55278020
kubectl dumpy delete dumpy-55278020
ls /tmp/tcpdump/

# wireshark tcp.port=7000 and capture traffic on the loopback adapter
1546	2024-09-18 18:04:31.165374	127.0.0.1	127.0.0.1	TCP	56	56834 ? 7000 [SYN] Seq=0 Win=65535 Len=0 MSS=65495 WS=256 SACK_PERM
1547	2024-09-18 18:04:31.165452	127.0.0.1	127.0.0.1	TCP	56	7000 ? 56834 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=65495 WS=256 SACK_PERM
1548	2024-09-18 18:04:31.165495	127.0.0.1	127.0.0.1	TCP	44	56834 ? 7000 [ACK] Seq=1 Ack=1 Win=327424 Len=0
1549	2024-09-18 18:04:31.165777	127.0.0.1	127.0.0.1	TCP	765	56834 ? 7000 [PSH, ACK] Seq=1 Ack=1 Win=327424 Len=721
E@X	l3PGET / HTTP/1.1
Host: 127.0.0.1:7000
Connection: keep-alive
sec-ch-ua: "Chromium";v="128", "Not;A=Brand";v="24", "Microsoft Edge";v="128"
1550	2024-09-18 18:04:31.165805	127.0.0.1	127.0.0.1	TCP	44	7000 ? 56834 [ACK] Seq=1 Ack=722 Win=2160384 Len=0
1551	2024-09-18 18:04:31.169423	127.0.0.1	127.0.0.1	TCP	56	56835 ? 7000 [SYN] Seq=0 Win=65535 Len=0 MSS=65495 WS=256 SACK_PERM
1552	2024-09-18 18:04:31.169548	127.0.0.1	127.0.0.1	TCP	56	7000 ? 56835 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=65495 WS=256 SACK_PERM
1553	2024-09-18 18:04:31.169599	127.0.0.1	127.0.0.1	TCP	44	56835 ? 7000 [ACK] Seq=1 Ack=1 Win=327424 Len=0
1554	2024-09-18 18:04:31.388836	127.0.0.1	127.0.0.1	TCP	213	7000 ? 56834 [PSH, ACK] Seq=1 Ack=722 Win=2160384 Len=169
E@Xl3P HTTP/1.0 200 OK
Connection: close
Content-Type: text/plain
Content-Length: 85
It looks like you are trying to access MongoDB over HTTP on the native driver port.
1555	2024-09-18 18:04:31.388896	127.0.0.1	127.0.0.1	TCP	44	56834 ? 7000 [ACK] Seq=722 Ack=170 Win=327168 Len=0
1556	2024-09-18 18:04:31.389887	127.0.0.1	127.0.0.1	TCP	44	56834 ? 7000 [FIN, ACK] Seq=722 Ack=170 Win=327168 Len=0
1557	2024-09-18 18:04:31.389939	127.0.0.1	127.0.0.1	TCP	44	7000 ? 56834 [ACK] Seq=170 Ack=723 Win=2160384 Len=0
1558	2024-09-18 18:04:31.390225	127.0.0.1	127.0.0.1	TCP	44	7000 ? 56834 [FIN, ACK] Seq=170 Ack=723 Win=2160384 Len=0
1559	2024-09-18 18:04:31.390308	127.0.0.1	127.0.0.1	TCP	44	56834 ? 7000 [ACK] Seq=723 Ack=171 Win=327168 Len=0
1560	2024-09-18 18:04:31.470479	127.0.0.1	127.0.0.1	TCP	691	56835 ? 7000 [PSH, ACK] Seq=1 Ack=1 Win=327424 Len=647
E@XlPGET /favicon.ico HTTP/1.1
Host: 127.0.0.1:7000
Connection: keep-alive
sec-ch-ua: "Chromium";v="128", "Not;A=Brand";v="24", "Microsoft Edge";v="128"
Referer: http://127.0.0.1:7000/
1561	2024-09-18 18:04:31.470551	127.0.0.1	127.0.0.1	TCP	44	7000 ? 56835 [ACK] Seq=1 Ack=648 Win=2160640 Len=0
1562	2024-09-18 18:04:31.541897	127.0.0.1	127.0.0.1	TCP	213	7000 ? 56835 [PSH, ACK] Seq=1 Ack=648 Win=2160640 Len=169
E@XlgP |HTTP/1.0 200 OK
Connection: close
Content-Type: text/plain
Content-Length: 85
It looks like you are trying to access MongoDB over HTTP on the native driver port.
1563	2024-09-18 18:04:31.541942	127.0.0.1	127.0.0.1	TCP	44	56835 ? 7000 [ACK] Seq=648 Ack=170 Win=327168 Len=0
1564	2024-09-18 18:04:31.542507	127.0.0.1	127.0.0.1	TCP	44	56835 ? 7000 [FIN, ACK] Seq=648 Ack=170 Win=327168 Len=0
1565	2024-09-18 18:04:31.542547	127.0.0.1	127.0.0.1	TCP	44	7000 ? 56835 [ACK] Seq=170 Ack=649 Win=2160640 Len=0
1566	2024-09-18 18:04:31.542812	127.0.0.1	127.0.0.1	TCP	44	7000 ? 56835 [FIN, ACK] Seq=170 Ack=649 Win=2160640 Len=0
1567	2024-09-18 18:04:31.542855	127.0.0.1	127.0.0.1	TCP	44	56835 ? 7000 [ACK] Seq=649 Ack=171 Win=327168 Len=0
```

- https://prefetch.net/blog/2018/02/03/how-the-kubectl-port-forward-command-works/
- https://stackoverflow.com/questions/51468491/how-does-kubectl-port-forward-create-a-connection
- https://docs.giantswarm.io/vintage/getting-started/connectivity/exposing-workloads/: Forwarding a port with kubectl is fairly easy, however, it should be only used for debugging purposes.
- * https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-services-running-on-the-cluster: The kubectl proxy...
