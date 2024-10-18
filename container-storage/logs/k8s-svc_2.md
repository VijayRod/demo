```
kubectl delete po nginx
kubectl run nginx --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-38494683-vmss000000"}}}'
kubectl expose po nginx
kubectl delete po nginx2
kubectl run nginx2 --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-38494683-vmss000004"}}}'
kubectl expose po nginx2
sleep 10

kubectl get no -owide
kubectl get po -owide | grep -E 'nginx|coredns'
kubectl get svc | grep nginx

aks-nodepool1-38494683-vmss000000   Ready    agent   4h21m   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-38494683-vmss000003   Ready    agent   43m     v1.28.10   10.224.0.6    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-38494683-vmss000004   Ready    agent   43m     v1.28.10   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
default       nginx                                 1/1     Running   0          9m16s   10.244.0.16   aks-nodepool1-38494683-vmss000000   <none>           <none>
default       nginx2                                1/1     Running   0          9m14s   10.244.2.5    aks-nodepool1-38494683-vmss000004   <none>           <none>
kube-system   coredns-6745896b65-5swvh              1/1     Running   0          4h47m   10.244.0.8    aks-nodepool1-38494683-vmss000000   <none>           <none>
kube-system   coredns-6745896b65-nw87l              1/1     Running   0          4h49m   10.244.0.6    aks-nodepool1-38494683-vmss000000   <none>
nginx        ClusterIP   10.0.99.92   <none>        80/TCP    45s
nginx2       ClusterIP   10.0.84.71   <none>        80/TCP    44s

kubectl exec -it nginx -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local ib5kedtkaf2udoxrc5h1huub5a.gvxx.internal.cloudapp.net
nameserver 10.0.0.10
options ndots:5

kubectl exec -it nginx2 -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local ib5kedtkaf2udoxrc5h1huub5a.gvxx.internal.cloudapp.net
nameserver 10.0.0.10
options ndots:5

kubectl exec -it nginx2 -- curl -I nginx # HTTP/1.1 200 OK

root@aks-nodepool1-38494683-vmss000000:/# tcpdump # grep nginx|10.244.0.16
18:19:03.610276 IP 10.244.2.5.44982 > 10.244.0.8.domain: 64045+ A? nginx.default.svc.cluster.local. (49)
18:19:03.610276 IP 10.244.2.5.44982 > 10.244.0.8.domain: 10546+ AAAA? nginx.default.svc.cluster.local. (49)
18:19:03.610531 IP 10.244.0.8.domain > 10.244.2.5.44982: 10546*- 0/1/0 (142)
18:19:03.610564 IP 10.244.0.8.domain > 10.244.2.5.44982: 64045*- 1/0/0 A 10.0.99.92 (96)
18:19:03.611883 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [S], seq 1148863852, win 64240, options [mss 1418,sackOK,TS val 2767677373 ecr 0,nop,wscale 7], length 0
18:19:03.612050 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [S.], seq 2205957194, ack 1148863853, win 65160, options [mss 1460,sackOK,TS val 2249285958 ecr 2767677373,nop,wscale 7], length 0
18:19:03.613018 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 2767677375 ecr 2249285958], length 0
18:19:03.613018 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [P.], seq 1:70, ack 1, win 502, options [nop,nop,TS val 2767677375 ecr 2249285958], length 69: HTTP: GET / HTTP/1.1
18:19:03.613043 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [.], ack 70, win 509, options [nop,nop,TS val 2249285959 ecr 2767677375], length 0
18:19:03.613231 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [P.], seq 1:239, ack 70, win 509, options [nop,nop,TS val 2249285959 ecr 2767677375], length 238: HTTP: HTTP/1.1 200 OK
18:19:03.613279 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [P.], seq 239:854, ack 70, win 509, options [nop,nop,TS val 2249285959 ecr 2767677375], length 615: HTTP
18:19:03.614131 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 239, win 501, options [nop,nop,TS val 2767677376 ecr 2249285959], length 0
18:19:03.614131 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 854, win 501, options [nop,nop,TS val 2767677376 ecr 2249285959], length 0
18:19:03.614131 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [F.], seq 70, ack 854, win 501, options [nop,nop,TS val 2767677376 ecr 2249285959], length 0
18:19:03.614196 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [F.], seq 854, ack 71, win 509, options [nop,nop,TS val 2249285960 ecr 2767677376], length 0
18:19:03.614857 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 855, win 501, options [nop,nop,TS val 2767677376 ecr 2249285960], length 0

aks-nodepool1-38494683-vmss000004:/# tcpdump # grep nginx|10.244.0.16
18:19:03.609139 IP 10.244.2.5.44982 > 10.244.0.8.domain: 64045+ A? nginx.default.svc.cluster.local. (49)
18:19:03.609154 IP 10.244.2.5.44982 > 10.244.0.8.domain: 10546+ AAAA? nginx.default.svc.cluster.local. (49)
18:19:03.611085 IP 10.244.0.8.domain > 10.244.2.5.44982: 10546*- 0/1/0 (142)
18:19:03.611085 IP 10.244.0.8.domain > 10.244.2.5.44982: 64045*- 1/0/0 A 10.0.99.92 (96)
18:19:03.611243 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [S], seq 1148863852, win 64240, options [mss 1460,sackOK,TS val 2767677373 ecr 0,nop,wscale 7], length 0
18:19:03.612584 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [S.], seq 2205957194, ack 1148863853, win 65160, options [mss 1418,sackOK,TS val 2249285958 ecr 2767677373,nop,wscale 7], length 0
18:19:03.612617 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 2767677375 ecr 2249285958], length 0
18:19:03.612656 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [P.], seq 1:70, ack 1, win 502, options [nop,nop,TS val 2767677375 ecr 2249285958], length 69: HTTP: GET / HTTP/1.1
18:19:03.613263 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [.], ack 70, win 509, options [nop,nop,TS val 2249285959 ecr 2767677375], length 0
18:19:03.613503 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [P.], seq 1:239, ack 70, win 509, options [nop,nop,TS val 2249285959 ecr 2767677375], length 238: HTTP: HTTP/1.1 200 OK
18:19:03.613504 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [P.], seq 239:854, ack 70, win 509, options [nop,nop,TS val 2249285959 ecr 2767677375], length 615: HTTP
18:19:03.613522 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 239, win 501, options [nop,nop,TS val 2767677376 ecr 2249285959], length 0
18:19:03.613526 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 854, win 501, options [nop,nop,TS val 2767677376 ecr 2249285959], length 0
18:19:03.613685 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [F.], seq 70, ack 854, win 501, options [nop,nop,TS val 2767677376 ecr 2249285959], length 0
18:19:03.614439 IP 10.244.0.16.http > 10.244.2.5.57766: Flags [F.], seq 854, ack 71, win 509, options [nop,nop,TS val 2249285960 ecr 2767677376], length 0
18:19:03.614473 IP 10.244.2.5.57766 > 10.244.0.16.http: Flags [.], ack 855, win 501, options [nop,nop,TS val 2767677376 ecr 2249285960], length 0
```
