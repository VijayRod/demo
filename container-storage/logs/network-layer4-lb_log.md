- https://github.com/kubernetes/kubernetes/issues/125618#issuecomment-2206300812: an example for node temporarily not ready but pods running. If kubelet disconnects from the ApiServer network, the node will become notready, but the pod on the node is still running.
  
```
# Stop the kubectl service in the azure-cni cluster. The pods are using a load balancer but don't have a livenessProbe set up

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 2
az aks create -g $rg -n akscni --network-plugin azure -s $vmsize -c 2
az aks get-credentials -g $rg -n akscni --overwrite-existing

# Same with kubnet and azure-cni
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
# noderg=$(az aks show -g $rg -n akscni --query nodeResourceGroup -o tsv)
az network lb list -g $noderg # az network lb probe list -g $noderg --lb-name kubernetes
    "probes": [],
    
kubectl delete deploy nginx
kubectl create deploy nginx --image=nginx --port=80 --replicas 10
# kubectl scale deploy nginx --replicas 10
kubectl expose deploy nginx --type=LoadBalancer
kubectl get deploy
kubectl get po -l app=nginx -owide -w

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb list -g $noderg # port
    "probes": [
      {
        "etag": "W/\"10181155-974e-40a3-946f-056c1baddd09\"",
        "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/probes/aa18733e61932462a99203d13d8bf6ca-TCP-80",
        "intervalInSeconds": 5,
        "loadBalancingRules": [
          {
            "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Network/loadBalancers/kubernetes/loadBalancingRules/aa18733e61932462a99203d13d8bf6ca-TCP-80",
            "resourceGroup": "mc_rg_akscni_swedencentral"
          }
        ],
        "name": "aa18733e61932462a99203d13d8bf6ca-TCP-80",
        "numberOfProbes": 2,
        "port": 30089,
        "probeThreshold": 2,
        "protocol": "Tcp",
        "provisioningState": "Succeeded",
        "resourceGroup": "mc_rg_akscni_swedencentral",
        "type": "Microsoft.Network/loadBalancers/probes"
      }
    ],

k get svc
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
kubernetes   ClusterIP      10.0.0.1       <none>         443/TCP        6h3m
nginx        LoadBalancer   10.0.131.175   4.225.69.181   80:30089/TCP   65m

k get no -owide
NAME                                STATUS   ROLES    AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE
   KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-21231904-vmss000000   Ready    <none>   8h    v1.29.9   10.224.0.4    <none>        Ubuntu 22.04.5 LTS   5.15.0-1074-azure   containerd://1.7.23-1

tcpdump port 30089
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
18:35:00.685065 IP 168.63.129.16.63050 > aks-nodepool1-21231904-vmss000000.internal.cloudapp.net.30089: Flags [SEW], seq 3346741123, win 64240, options [mss 1440,nop,wscale 8,nop,nop,sackOK], length 0
18:35:00.685111 IP aks-nodepool1-21231904-vmss000000.internal.cloudapp.net.30089 > 168.63.129.16.63050: Flags [S.], seq 3872552363, ack 3346741124, win 64240, options [mss 1460,nop,nop,sackOK,nop,wscale 7], length 0
18:35:00.685682 IP 168.63.129.16.63050 > aks-nodepool1-21231904-vmss000000.internal.cloudapp.net.30089: Flags [.], ack 1, win 6147, length 0
18:35:06.698204 IP 168.63.129.16.63050 > aks-nodepool1-21231904-vmss000000.internal.cloudapp.net.30089: Flags [F.], seq 1, ack 1, win 6147, length 0
18:35:06.698305 IP aks-nodepool1-21231904-vmss000000.internal.cloudapp.net.30089 > 168.63.129.16.63050: Flags [F.], seq 1, ack 2, win 502, length 0
18:35:06.698424 IP 168.63.129.16.63050 > aks-nodepool1-21231904-vmss000000.internal.cloudapp.net.30089: Flags [.], ack 2, win 6147, length 0

wireshark tcp.port==30089
417	2024-12-02 19:25:28.393019	168.63.129.16	10.224.0.4	TCP	72	0x34f6 (13558)	1214465338	0	59248 ? 30089 [SYN, ECE, CWR] Seq=0 Win=64240 Len=0 MSS=1440 WS=256 SACK_PERM
420	2024-12-02 19:25:28.393061	10.224.0.4	168.63.129.16	TCP	72	0x0000 (0)	1811497637	1214465339	30089 ? 59248 [SYN, ACK] Seq=0 Ack=1 Win=64240 Len=0 MSS=1460 SACK_PERM WS=128
421	2024-12-02 19:25:28.393496	168.63.129.16	10.224.0.4	TCP	66	0x34f7 (13559)	1214465339	1811497638	59248 ? 30089 [ACK] Seq=1 Ack=1 Win=1573632 Len=0
1506	2024-12-02 19:25:34.400614	168.63.129.16	10.224.0.4	TCP	66	0x3522 (13602)	1214465339	1811497638	59248 ? 30089 [FIN, ACK] Seq=1 Ack=1 Win=1573632 Len=0
1509	2024-12-02 19:25:34.400698	10.224.0.4	168.63.129.16	TCP	60	0xba7f (47743)	1811497638	1214465340	30089 ? 59248 [FIN, ACK] Seq=1 Ack=2 Win=64256 Len=0
1510	2024-12-02 19:25:34.400850	168.63.129.16	10.224.0.4	TCP	66	0x3523 (13603)	1214465340	1811497639	59248 ? 30089 [ACK] Seq=2 Ack=2 Win=1573632 Len=0

# systemctl stop kubelet

k get no -w
NAME                                STATUS   ROLES    AGE    VERSION
aks-nodepool1-21231904-vmss000001   Ready    <none>   5h5m   v1.29.9
aks-nodepool1-21231904-vmss000001   NotReady   <none>   5h5m   v1.29.9

k get ep -w # doesn't include the endpoints from this node
NAME         ENDPOINTS                                                  AGE
kubernetes   4.225.16.107:443                                           5h10m
nginx        10.224.0.14:80,10.224.0.20:80,10.224.0.31:80 + 2 more...   12m

k get svc -w

k get po -owide -w # | grep 000001 # pods in the Terminating state
nginx-7c5ddbdf54-449dl   1/1     Terminating   0          13m     10.224.0.41   aks-nodepool1-21231904-vmss000001   <none>           <none>
nginx-7c5ddbdf54-kh4mz   1/1     Terminating   0          13m     10.224.0.45   aks-nodepool1-21231904-vmss000001   <none>           <none>
```

```
# Stop the kubectl service. azure-cni cluster. The pods have a livenessProbe

kubectl delete deploy nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 5
EOF
kubectl expose deploy nginx --type=LoadBalancer
# kubectl scale deploy nginx --replicas 10
kubectl get deploy
kubectl get po -owide -w

# systemctl stop kubelet

k get no -w
NAME                                STATUS   ROLES    AGE     VERSION
aks-nodepool1-29173261-vmss000001   Ready    <none>   11m     v1.29.9
aks-nodepool1-29173261-vmss000001   NotReady   <none>   11m     v1.29.9

k get ep -w # doesn't include the endpoints from this node
NAME         ENDPOINTS          AGE
kubernetes   135.225.2.24:443   9m43s
nginx        10.224.0.35:80     59s
nginx                           4m2s

k get po -owide -w | grep 000001 # pods in the Terminating state
NAME                    READY   STATUS    RESTARTS   AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
nginx-79465bf79-zb22n   1/1     Running   0          73s   10.224.0.35   aks-nodepool1-29173261-vmss000001   <none>           <none>

k get svc -w
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.0.0.1       <none>           443/TCP        27m
nginx        LoadBalancer   10.0.155.137   74.241.164.174   80:31033/TCP   19m

# The pod IP works fine from another node (and the pod is still in the Running state)
aks-nodepool1-29173261-vmss000000:/# curl -I 10.224.0.35
HTTP/1.1 200 OK
Server: nginx/1.27.3
# The pod IP works until the pod is terminated
k get po -owide | grep 35
nginx-79465bf79-zb22n   1/1     Terminating   0          20m     10.224.0.35   aks-nodepool1-29173261-vmss000001   <none>           <none>

# curl with the service IP is getting a connection refused
aks-nodepool1-29173261-vmss000000:/# curl -I 10.0.155.137
curl: (7) Failed to connect to 10.0.155.137 port 80 after 0 ms: Connection refused

aks-nodepool1-29173261-vmss000000:/# curl -v 10.0.155.137
*   Trying 10.0.155.137:80...
* connect to 10.0.155.137 port 80 failed: Connection refused
* Failed to connect to 10.0.155.137 port 80 after 0 ms: Connection refused
* Closing connection 0
curl: (7) Failed to connect to 10.0.155.137 port 80 after 0 ms: Connection refused
```

```
# Or power off the node
# tbd shutdown --poweroff
```

```
tbd kubectl delete no
```
