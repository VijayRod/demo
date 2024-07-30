- Logging has not been enabled for coredns i.e. the default.

```
kubectl get po -A -owide | grep coredns
kube-system   coredns-6745896b65-2r94j              1/1     Running   0          97m   10.244.0.3    aks-nodepool1-14036957-vmss000002   <none>           <none>
kube-system   coredns-6745896b65-9gd89              1/1     Running   0          95m   10.244.0.8    aks-nodepool1-14036957-vmss000002   <none>           <none>
kube-system   coredns-autoscaler-dcbf9c474-n7c9n    1/1     Running   0          97m   10.244.0.4    aks-nodepool1-14036957-vmss000002   <none>           <none>

kubectl get no -owide
NAME                                STATUS   ROLES   AGE    VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE
    KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14036957-vmss000000   Ready    agent   106m   v1.28.10   10.224.0.6    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000001   Ready    agent   106m   v1.28.10   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000002   Ready    agent   106m   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

kubectl run --image=nginx nginx --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-14036957-vmss000001" } } } } }' # non-coredns node
sleep 10
kubectl get po nginx -owide
# nginx   1/1     Running   0          11m   10.244.1.3   aks-nodepool1-14036957-vmss000001   <none>           <none>

# additional windows
kubectl logs -n kube-system -l k8s-app=kube-dns -f # no additional related rows
kubectl exec -it nginx -- curl google.com

# non-coredns app node
tcpdump port 53 # no rows

# coredns node
tcpdump port 53 # grep google
13:07:57.245700 IP 10.244.1.3.44426 > 10.244.0.3.domain: 38489+ A? google.com.default.svc.cluster.local. (54)
13:07:57.245700 IP 10.244.1.3.44426 > 10.244.0.3.domain: 20826+ AAAA? google.com.default.svc.cluster.local. (54)
13:07:57.246025 IP 10.244.0.3.domain > 10.244.1.3.44426: 20826 NXDomain*- 0/1/0 (147)
13:07:57.246107 IP 10.244.0.3.domain > 10.244.1.3.44426: 38489 NXDomain*- 0/1/0 (147)
13:07:57.246846 IP 10.244.1.3.46358 > 10.244.0.8.domain: 36606+ A? google.com.svc.cluster.local. (46)
13:07:57.246846 IP 10.244.1.3.46358 > 10.244.0.8.domain: 19704+ AAAA? google.com.svc.cluster.local. (46)
13:07:57.247045 IP 10.244.0.8.domain > 10.244.1.3.46358: 19704 NXDomain*- 0/1/0 (139)
13:07:57.247083 IP 10.244.0.8.domain > 10.244.1.3.46358: 36606 NXDomain*- 0/1/0 (139)
13:07:57.247804 IP 10.244.1.3.44677 > 10.244.0.8.domain: 9510+ A? google.com.cluster.local. (42)
13:07:57.247804 IP 10.244.1.3.44677 > 10.244.0.8.domain: 46119+ AAAA? google.com.cluster.local. (42)
13:07:57.248109 IP 10.244.0.8.domain > 10.244.1.3.44677: 46119 NXDomain*- 0/1/0 (135)
13:07:57.248207 IP 10.244.0.8.domain > 10.244.1.3.44677: 9510 NXDomain*- 0/1/0 (135)
13:07:57.249269 IP 10.244.1.3.38416 > 10.244.0.3.domain: 12774+ A? google.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (82)
13:07:57.249269 IP 10.244.1.3.38416 > 10.244.0.3.domain: 38633+ AAAA? google.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (82)
13:07:57.249593 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.48159 > 168.63.129.16.domain: 3309+ [1au] AAAA? google.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (93)
13:07:57.249637 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36994 > 168.63.129.16.domain: 25957+ [1au] A? google.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (93)
13:07:57.253219 IP 168.63.129.16.domain > aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.48159: 3309 NXDomain 0/1/1 (179)
13:07:57.253219 IP 168.63.129.16.domain > aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36994: 25957 NXDomain 0/1/1 (179)
13:07:57.253532 IP 10.244.0.3.domain > 10.244.1.3.3841
```

- Logging has been enabled for coredns
  - https://learn.microsoft.com/en-us/azure/aks/coredns-custom#enable-dns-query-logging
  - https://coredns.io/plugins/log/

```
kubectl get no -owide
NAME                                STATUS   ROLES   AGE     VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14036957-vmss000000   Ready    agent   3h44m   v1.28.10   10.224.0.6    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000001   Ready    agent   3h44m   v1.28.10   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000002   Ready    agent   3h45m   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  log.override: | # you may select any name here, but it must end with the .override file extension
        log
EOF
kubectl get cm -n kube-system coredns-custom -oyaml
kubectl -n kube-system rollout restart deployment coredns
kubectl get po -n kube-system -l k8s-app=kube-dns -owide

kubectl get po -A -owide | grep -E 'coredns|nginx'
default       nginx                                 1/1     Running   0          30m     10.244.0.11   aks-nodepool1-14036957-vmss000002   <none>           <none>
kube-system   coredns-7797c54ccb-dtf4g              1/1     Running   0          41m     10.244.1.4    aks-nodepool1-14036957-vmss000001   <none>           <none>
kube-system   coredns-7797c54ccb-ttxx9              1/1     Running   0          41m     10.244.2.3    aks-nodepool1-14036957-vmss000000   <none>           <none>
kube-system   coredns-autoscaler-dcbf9c474-n7c9n    1/1     Running   0          4h2m    10.244.0.4    aks-nodepool1-14036957-vmss000002   <none>           <none>

kubectl delete po nginx
kubectl run --image=nginx nginx --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-14036957-vmss000002" } } } } }' # non-coredns node
sleep 10
kubectl get po nginx -owide

# additional windows
kubectl exec -it nginx -- curl openai.com

kubectl logs -n kube-system -l k8s-app=kube-dns -f # no additional related rows
[INFO] 10.244.0.11:55528 - 3059 "AAAA IN openai.com.svc.cluster.local. udp 46 false 512" NXDOMAIN qr,aa,rd 139 0.000169502s
[INFO] 10.244.0.11:55528 - 32241 "A IN openai.com.svc.cluster.local. udp 46 false 512" NXDOMAIN qr,aa,rd 139 0.000153102s
[INFO] 10.244.0.11:33753 - 41293 "AAAA IN openai.com.default.svc.cluster.local. udp 54 false 512" NXDOMAIN qr,aa,rd 147 0.000191804s
[INFO] 10.244.0.11:33753 - 31567 "A IN openai.com.default.svc.cluster.local. udp 54 false 512" NXDOMAIN qr,aa,rd 147 0.000222904s
[INFO] 10.244.0.11:45069 - 25968 "A IN openai.com.cluster.local. udp 42 false 512" NXDOMAIN qr,aa,rd 135 0.000124402s
[INFO] 10.244.0.11:45069 - 38515 "AAAA IN openai.com.cluster.local. udp 42 false 512" NXDOMAIN qr,aa,rd 135 0.000084001s
[INFO] 10.244.0.11:46853 - 52501 "AAAA IN openai.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. udp 82 false 512" NXDOMAIN qr,rd,ra 192 0.002997758s
[INFO] 10.244.0.11:46853 - 39707 "A IN openai.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. udp 82 false 512" NXDOMAIN qr,rd,ra 192 0.002916556s
[INFO] 10.244.0.11:60564 - 7220 "A IN openai.com. udp 28 false 512" NOERROR qr,rd,ra 80 0.001285425s
[INFO] 10.244.0.11:60564 - 36406 "AAAA IN openai.com. udp 28 false 512" NOERROR qr,rd,ra 127 0.026874816s

# non-coredns app node
tcpdump # grep openai
18:58:39.398011 IP 10.244.0.11.33753 > 10.244.1.4.domain: 31567+ A? openai.com.default.svc.cluster.local. (54)
18:58:39.398028 IP 10.244.0.11.33753 > 10.244.1.4.domain: 41293+ AAAA? openai.com.default.svc.cluster.local. (54)
18:58:39.399347 IP 10.244.1.4.domain > 10.244.0.11.33753: 41293 NXDomain*- 0/1/0 (147)
18:58:39.399347 IP 10.244.1.4.domain > 10.244.0.11.33753: 31567 NXDomain*- 0/1/0 (147)
18:58:39.399444 IP 10.244.0.11.55528 > 10.244.2.3.domain: 32241+ A? openai.com.svc.cluster.local. (46)
18:58:39.399453 IP 10.244.0.11.55528 > 10.244.2.3.domain: 3059+ AAAA? openai.com.svc.cluster.local. (46)
18:58:39.400598 IP 10.244.2.3.domain > 10.244.0.11.55528: 3059 NXDomain*- 0/1/0 (139)
18:58:39.400598 IP 10.244.2.3.domain > 10.244.0.11.55528: 32241 NXDomain*- 0/1/0 (139)
18:58:39.400683 IP 10.244.0.11.45069 > 10.244.2.3.domain: 25968+ A? openai.com.cluster.local. (42)
18:58:39.400691 IP 10.244.0.11.45069 > 10.244.2.3.domain: 38515+ AAAA? openai.com.cluster.local. (42)
18:58:39.401373 IP 10.244.2.3.domain > 10.244.0.11.45069: 25968 NXDomain*- 0/1/0 (135)
18:58:39.401387 IP 10.244.2.3.domain > 10.244.0.11.45069: 38515 NXDomain*- 0/1/0 (135)
18:58:39.401431 IP 10.244.0.11.46853 > 10.244.1.4.domain: 39707+ A? openai.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (82)
18:58:39.401440 IP 10.244.0.11.46853 > 10.244.1.4.domain: 52501+ AAAA? openai.com.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (82)
18:58:39.405343 IP 10.244.1.4.domain > 10.244.0.11.46853: 52501 NXDomain 0/1/0 (192)
18:58:39.405343 IP 10.244.1.4.domain > 10.244.0.11.46853: 39707 NXDomain 0/1/0 (192)
18:58:39.405454 IP 10.244.0.11.60564 > 10.244.1.4.domain: 7220+ A? openai.com. (28)
18:58:39.405463 IP 10.244.0.11.60564 > 10.244.1.4.domain: 36406+ AAAA? openai.com. (28)
18:58:39.407783 IP 10.244.1.4.domain > 10.244.0.11.60564: 7220 2/0/0 A 104.18.33.45, A 172.64.154.211 (80)
18:58:39.433269 IP 10.244.1.4.domain > 10.244.0.11.60564: 36406 0/1/0 (127)

# non-coredns app node (Another example)
kubectl get po -A -owide | grep -E 'coredns|nginx'
default       nginx                                 1/1     Running   0          7m20s   10.244.0.12   aks-nodepool1-14036957-vmss000002   <none>           <none>
kube-system   coredns-7797c54ccb-dtf4g              1/1     Running   0          166m    10.244.1.4    aks-nodepool1-14036957-vmss000001   <none>           <none>
kube-system   coredns-7797c54ccb-ttxx9              1/1     Running   0          166m    10.244.2.3    aks-nodepool1-14036957-vmss000000   <none>           <none>
kube-system   coredns-autoscaler-dcbf9c474-n7c9n    1/1     Running   0          6h7m    10.244.0.4    aks-nodepool1-14036957-vmss000002   <none>           <none>
kubectl get no -owide
NAME                                STATUS   ROLES   AGE    VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE    KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14036957-vmss000000   Ready    agent   6h8m   v1.28.10   10.224.0.6    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000001   Ready    agent   6h8m   v1.28.10   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000002   Ready    agent   6h8m   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
kubectl exec -it nginx -- curl kubernetes.io
aks-nodepool1-14036957-vmss000002:/# tcpdump # grep 'kubernetes|147.75.40.148|148.40.75.147'
17:39:54.850466 IP 10.244.0.12.52872 > 10.244.2.3.domain: 50502+ A? kubernetes.io.default.svc.cluster.local. (57)
17:39:54.850481 IP 10.244.0.12.52872 > 10.244.2.3.domain: 33624+ AAAA? kubernetes.io.default.svc.cluster.local. (57)
17:39:54.852113 IP 10.244.2.3.domain > 10.244.0.12.52872: 33624 NXDomain*- 0/1/0 (150)
17:39:54.852113 IP 10.244.2.3.domain > 10.244.0.12.52872: 50502 NXDomain*- 0/1/0 (150)
17:39:54.852249 IP 10.244.0.12.57972 > 10.244.1.4.domain: 10667+ A? kubernetes.io.svc.cluster.local. (49)
17:39:54.852261 IP 10.244.0.12.57972 > 10.244.1.4.domain: 7061+ AAAA? kubernetes.io.svc.cluster.local. (49)
17:39:54.853487 IP 10.244.1.4.domain > 10.244.0.12.57972: 7061 NXDomain*- 0/1/0 (142)
17:39:54.853487 IP 10.244.1.4.domain > 10.244.0.12.57972: 10667 NXDomain*- 0/1/0 (142)
17:39:54.853547 IP 10.244.0.12.34143 > 10.244.1.4.domain: 13574+ A? kubernetes.io.cluster.local. (45)
17:39:54.853554 IP 10.244.0.12.34143 > 10.244.1.4.domain: 39481+ AAAA? kubernetes.io.cluster.local. (45)
17:39:54.854418 IP 10.244.1.4.domain > 10.244.0.12.34143: 39481 NXDomain*- 0/1/0 (138)
17:39:54.854418 IP 10.244.1.4.domain > 10.244.0.12.34143: 13574 NXDomain*- 0/1/0 (138)
17:39:54.854459 IP 10.244.0.12.37447 > 10.244.1.4.domain: 9994+ A? kubernetes.io.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (85)
17:39:54.854465 IP 10.244.0.12.37447 > 10.244.1.4.domain: 12552+ AAAA? kubernetes.io.oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net. (85)
17:39:54.859162 IP 10.244.1.4.domain > 10.244.0.12.37447: 9994 NXDomain 0/1/0 (195)
17:39:54.870073 IP 10.244.1.4.domain > 10.244.0.12.37447: 12552 NXDomain 0/1/0 (195)
17:39:54.870286 IP 10.244.0.12.42608 > 10.244.1.4.domain: 38165+ A? kubernetes.io. (31)
17:39:54.870298 IP 10.244.0.12.42608 > 10.244.1.4.domain: 59159+ AAAA? kubernetes.io. (31)
17:39:55.122301 IP 10.244.1.4.domain > 10.244.0.12.42608: 38165 1/0/0 A 147.75.40.148 (60)
17:39:55.123865 IP 10.244.1.4.domain > 10.244.0.12.42608: 59159 0/1/0 (140)
17:39:55.124358 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014 > 147.75.40.148.http: Flags [S], seq 2357588904, win 64240, options [mss 1460,sackOK,TS val 2307560587 ecr 0,nop,wscale 7], length 0
17:39:55.154304 IP 147.75.40.148.http > aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014: Flags [S.], seq 2111880295, ack 2357588905, win 65084, options [mss 1240,sackOK,TS val 4265684918 ecr 2307560587,nop,wscale 9], length 0
17:39:55.154406 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014 > 147.75.40.148.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 2307560617 ecr 4265684918], length 0
17:39:55.154555 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014 > 147.75.40.148.http: Flags [P.], seq 1:78, ack 1, win 502, options [nop,nop,TS val 2307560618 ecr 4265684918], length 77: HTTP: GET / HTTP/1.1
17:39:55.184237 IP 147.75.40.148.http > aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014: Flags [.], ack 78, win 127, options [nop,nop,TS val 4265684948 ecr 2307560618], length 0
17:39:55.185712 IP 147.75.40.148.http > aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014: Flags [P.], seq 1:266, ack 78, win 127, options [nop,nop,TS val 4265684949 ecr 2307560618], length 265: HTTP: HTTP/1.1 301 Moved Permanently
17:39:55.185753 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014 > 147.75.40.148.http: Flags [.], ack 266, win 501, options [nop,nop,TS val 2307560649 ecr 4265684949], length 0
17:39:55.185929 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014 > 147.75.40.148.http: Flags [F.], seq 78, ack 266, win 501, options [nop,nop,TS val 2307560649 ecr 4265684949], length 0
17:39:55.215580 IP 147.75.40.148.http > aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014: Flags [F.], seq 266, ack 79, win 127, options [nop,nop,TS val 4265684979 ecr 2307560649], length 0
17:39:55.215676 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.36014 > 147.75.40.148.http: Flags [.], ack 267, win 501, options [nop,nop,TS val 2307560679 ecr 4265684979], length 0
17:39:55.220570 IP aks-nodepool1-14036957-vmss000002.internal.cloudapp.net.56695 > 168.63.129.16.domain: 8802+ PTR? 148.40.75.147.in-addr.arpa. (44)
```

- resolv.conf

```
kubectl exec -it nginx -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net
nameserver 10.0.0.10
options ndots:5

cat /etc/resolv.conf # Same output on all nodes
nameserver 168.63.129.16
search oe5jefibyttubb2dmdwiufuhah.gvxx.internal.cloudapp.net
```

- iptables

```
iptables-save | grep nginx # no rows

iptables-save | grep kube-system/kube-dns # Same output on all nodes
-A KUBE-SEP-222YD7DQOUNKFRLL -s 10.244.1.4/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-222YD7DQOUNKFRLL -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.1.4:53
-A KUBE-SEP-5BME6LXGYWTVD5D3 -s 10.244.1.4/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-5BME6LXGYWTVD5D3 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.1.4:53
-A KUBE-SEP-DLP2S2N3HX5UKLVP -s 10.244.2.3/32 -m comment --comment "kube-system/kube-dns:dns-tcp" -j KUBE-MARK-MASQ
-A KUBE-SEP-DLP2S2N3HX5UKLVP -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp" -m tcp -j DNAT --to-destination 10.244.2.3:53
-A KUBE-SEP-ZHICQ2ODADGCY7DS -s 10.244.2.3/32 -m comment --comment "kube-system/kube-dns:dns" -j KUBE-MARK-MASQ
-A KUBE-SEP-ZHICQ2ODADGCY7DS -p udp -m comment --comment "kube-system/kube-dns:dns" -m udp -j DNAT --to-destination 10.244.2.3:53
-A KUBE-SERVICES -d 10.0.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES -d 10.0.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SVC-ERIFXISQEP7F7OF4 ! -s 10.244.0.0/16 -d 10.0.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.1.4:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-5BME6LXGYWTVD5D3
-A KUBE-SVC-ERIFXISQEP7F7OF4 -m comment --comment "kube-system/kube-dns:dns-tcp -> 10.244.2.3:53" -j KUBE-SEP-DLP2S2N3HX5UKLVP
-A KUBE-SVC-TCOU7JCQXEZGVUNU ! -s 10.244.0.0/16 -d 10.0.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.1.4:53" -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-222YD7DQOUNKFRLL
-A KUBE-SVC-TCOU7JCQXEZGVUNU -m comment --comment "kube-system/kube-dns:dns -> 10.244.2.3:53" -j KUBE-SEP-ZHICQ2ODADGCY7DS
```

- conntrack

```
kubectl get no -owide
NAME                                STATUS   ROLES   AGE    VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE
    KERNEL-VERSION      CONTAINER-RUNTIME
aks-nodepool1-14036957-vmss000000   Ready    agent   4h1m   v1.28.10   10.224.0.6    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000001   Ready    agent   4h1m   v1.28.10   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-14036957-vmss000002   Ready    agent   4h1m   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

kubectl get po -A -owide | grep -E 'coredns|nginx'
default       nginx                                 1/1     Running   0          30m     10.244.0.11   aks-nodepool1-14036957-vmss000002   <none>           <none>
kube-system   coredns-7797c54ccb-dtf4g              1/1     Running   0          41m     10.244.1.4    aks-nodepool1-14036957-vmss000001   <none>           <none>
kube-system   coredns-7797c54ccb-ttxx9              1/1     Running   0          41m     10.244.2.3    aks-nodepool1-14036957-vmss000000   <none>           <none>
kube-system   coredns-autoscaler-dcbf9c474-n7c9n    1/1     Running   0          4h2m    10.244.0.4    aks-nodepool1-14036957-vmss000002   <none>           <none>

kubectl exec -it nginx -- curl openai.com

aks-nodepool1-14036957-vmss000002:/# conntrack -L | grep 10.244.0.11
udp      17 24 src=10.244.0.11 dst=10.0.0.10 sport=35637 dport=53 src=10.244.2.3 dst=10.244.0.11 sport=53 dport=35637 mark=0 use=1
udp      17 24 src=10.244.0.11 dst=10.0.0.10 sport=43052 dport=53 src=10.244.2.3 dst=10.244.0.11 sport=53 dport=43052 mark=0 use=1
udp      17 24 src=10.244.0.11 dst=10.0.0.10 sport=33258 dport=53 src=10.244.1.4 dst=10.244.0.11 sport=53 dport=33258 mark=0 use=1
conntrack v1.4.6 (conntrack-tools): 296 flow entries have been shown.
udp      17 24 src=10.244.0.11 dst=10.0.0.10 sport=56834 dport=53 src=10.244.2.3 dst=10.244.0.11 sport=53 dport=56834 mark=0 use=1
udp      17 24 src=10.244.0.11 dst=10.0.0.10 sport=38430 dport=53 src=10.244.1.4 dst=10.244.0.11 sport=53 dport=38430 mark=0 use=1
tcp      6 114 TIME_WAIT src=10.244.0.11 dst=172.64.154.211 sport=53830 dport=80 src=172.64.154.211 dst=10.224.0.4 sport=80 dport=53830 [ASSURED] mark=0 use=1

aks-nodepool1-14036957-vmss000001:/# conntrack -L | grep 10.244.0.11
udp      17 19 src=10.244.0.11 dst=10.244.1.4 sport=38430 dport=53 src=10.244.1.4 dst=10.244.0.11 sport=53 dport=38430 mark=0 use=1
udp      17 19 src=10.244.0.11 dst=10.244.1.4 sport=33258 dport=53 src=10.244.1.4 dst=10.244.0.11 sport=53 dport=33258 mark=0 use=1

aks-nodepool1-14036957-vmss000000:/# conntrack -L | grep 10.244.0.11
udp      17 16 src=10.244.0.11 dst=10.244.2.3 sport=35637 dport=53 src=10.244.2.3 dst=10.244.0.11 sport=53 dport=35637 mark=0 use=1
udp      17 16 src=10.244.0.11 dst=10.244.2.3 sport=56834 dport=53 src=10.244.2.3 dst=10.244.0.11 sport=53 dport=56834 mark=0 use=1
```
