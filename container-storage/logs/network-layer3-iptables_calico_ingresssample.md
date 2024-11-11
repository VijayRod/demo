tbd Interpret the iptable policies for Calico - The output doesn't show how it distinguishes packets coming from a source pod that lacks the necessary labels.

```
kubectl delete ns demo
kubectl create ns demo
kubectl run server --image=nginx --port=80 -n demo -l app=server
kubectl run client --image=nginx --port=80 -n demo # doesn't include the desired label.
sleep 10
kubectl get po -n demo -owide --show-labels

kubectl exec -it client -n demo -- curl -I 10.224.0.46 # Server's IP address
HTTP/1.1 200 OK
```

```
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: demo-policy
  namespace: demo
spec:
  podSelector:
    matchLabels:
      app: server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - port: 80
      protocol: TCP
EOF

kubectl exec -it client -n demo -- curl -Iv 10.224.0.46 # Server's IP address
*   Trying 10.224.0.46:80...

kubectl logs -n calico-system -l k8s-app=calico-node # -f -c calico-node
2024-07-31 09:21:25.840 [INFO][66] felix/label_inheritance_index.go 182: Updating selector selID=Policy(name=demo/knp.default.demo-policy)
2024-07-31 09:21:25.842 [INFO][53] felix/table.go 508: Queueing update of chain. chainName="cali-fw-azve0cf0fbcf9f" ipVersion=0x4 table="filter"
2024-07-31 09:21:25.842 [INFO][53] felix/endpoint_mgr.go 646: Updating endpoint routes. id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 09:21:25.842 [INFO][53] felix/endpoint_mgr.go 1212: Applying /proc/sys configuration to interface. ifaceName="azve0cf0fbcf9f"
2024-07-31 09:21:25.842 [INFO][53] felix/endpoint_mgr.go 488: Re-evaluated workload endpoint status adminUp=true failed=false known=true operUp=true status="up" workloadEndpointID=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 09:21:25.842 [INFO][53] felix/status_combiner.go 58: Storing endpoint status update ipVersion=0x4 status="up" workload=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 09:21:25.843 [INFO][53] felix/ipsets.go 779: Doing full IP set rewrite family="inet" numMembersInPendingReplace=0 setID="s:N7qB4dD1ts0--qbzE-HjtMk4UjghTan7J_o4cQ"
2024-07-31 09:21:25.874 [INFO][53] felix/status_combiner.go 81: Endpoint up for at least one IP version id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"} ipVersion=0x4 status="up"
2024-07-31 09:21:25.874 [INFO][53] felix/status_combiner.go 98: Reporting combined status. id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"} status="up"

aks-nodepool1-49463138-vmss000002:/# iptables-save | grep azve0cf0fbcf9f # azve0cf0fbcf9f entries are only in the node that has the server pod
:cali-fw-azve0cf0fbcf9f - [0:0]
:cali-tw-azve0cf0fbcf9f - [0:0]
-A cali-from-wl-dispatch -i azve0cf0fbcf9f -m comment --comment "cali:rfJtbIg_cJSoRNPu" -g cali-fw-azve0cf0fbcf9f
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:jHAIP-UN0GynRTqx" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:JK7eyK6-mEJQ1qYM" -m conntrack --ctstate INVALID -j DROP
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:Ct_pKM2u5vgeJxFQ" -j MARK --set-xmark 0x0/0x10000
-A cali-fw-azve0cf0fbcf9f -p udp -m comment --comment "cali:X5UXgW1SU0LxFZdH" -m comment --comment "Drop VXLAN encapped packets originating in workloads" -m multiport --dports 4789 -j DROP
-A cali-fw-azve0cf0fbcf9f -p ipencap -m comment --comment "cali:WAmwxlgxI7M2x5dk" -m comment --comment "Drop IPinIP encapped packets originating in workloads" -j DROP
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:qaXL-O9IC8z_wRPl" -j cali-pro-kns.demo
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:RTrPCrJBv5otMMGe" -m comment --comment "Return if profile accepted" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:Q8dzQNX-YbaDXTMF" -j cali-pro-ksa.demo.default
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:wOc9kfjHMOuuioln" -m comment --comment "Return if profile accepted" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-fw-azve0cf0fbcf9f -m comment --comment "cali:elY1hL2oTRHe19ET" -m comment --comment "Drop if no profiles matched" -j DROP
-A cali-to-wl-dispatch -o azve0cf0fbcf9f -m comment --comment "cali:VytDhbVuzqtdG3ZT" -g cali-tw-azve0cf0fbcf9f
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:1UpHwwB1N0gJ1ylp" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:rlL-vIKuCuR6YmDf" -m conntrack --ctstate INVALID -j DROP
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:bllg_ocjikHMqnAr" -j MARK --set-xmark 0x0/0x10000
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:CdHsjen-CJmn3B3g" -m comment --comment "Start of policies" -j MARK --set-xmark 0x0/0x20000
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:TQaPYUSOdNvQvwg5" -m mark --mark 0x0/0x20000 -j cali-pi-_f33B8osgBB9KBtqM0k-
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:0QmZHflAbf4poj6J" -m comment --comment "Return if policy accepted" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:EGMMZ2I-ck_lMPHD" -m comment --comment "Drop if no policies passed packet" -m mark --mark 0x0/0x20000 -j DROP
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:DXIG6lwiDDSQZLTh" -j cali-pri-kns.demo
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:RmdwbQao5e0nG9Pt" -m comment --comment "Return if profile accepted" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:4Heytd6uysz9Ln8I" -j cali-pri-ksa.demo.default
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:uCMSm9AuL5n1kgOg" -m comment --comment "Return if profile accepted" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:gH0VUEPiLOudLOOB" -m comment --comment "Drop if no profiles matched" -j DROP

kubectl logs -n calico-system -l k8s-app=calico-node # grep demo-policy
2024-07-31 11:50:03.504 [INFO][66] felix/label_inheritance_index.go 182: Updating selector selID=Policy(name=demo/knp.default.demo-policy)
2024-07-31 11:50:38.555 [INFO][66] felix/summary.go 100: Summarising 12 dataplane reconciliation loops over 1m3.8s: avg=5ms longest=13ms ()
2024-07-31 11:50:03.506 [INFO][61] felix/table.go 508: Queueing update of chain. chainName="cali-tw-azve0cf0fbcf9f" ipVersion=0x4 table="filter"
2024-07-31 11:50:03.506 [INFO][61] felix/table.go 582: Chain became referenced, marking it for programming chainName="cali-pi-_f33B8osgBB9KBtqM0k-"
2024-07-31 11:50:03.506 [INFO][61] felix/table.go 508: Queueing update of chain. chainName="cali-fw-azve0cf0fbcf9f" ipVersion=0x4 table="filter"
2024-07-31 11:50:03.506 [INFO][61] felix/endpoint_mgr.go 646: Updating endpoint routes. id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 11:50:03.506 [INFO][61] felix/endpoint_mgr.go 1212: Applying /proc/sys configuration to interface. ifaceName="azve0cf0fbcf9f"
2024-07-31 11:50:03.506 [INFO][61] felix/endpoint_mgr.go 488: Re-evaluated workload endpoint status adminUp=true failed=false known=true operUp=true status="up" workloadEndpointID=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 11:50:03.506 [INFO][61] felix/status_combiner.go 58: Storing endpoint status update ipVersion=0x4 status="up" workload=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 11:50:03.507 [INFO][61] felix/ipsets.go 779: Doing full IP set rewrite family="inet" numMembersInPendingReplace=1 setID="s:N7qB4dD1ts0--qbzE-HjtMk4UjghTan7J_o4cQ"
2024-07-31 11:50:03.527 [INFO][61] felix/status_combiner.go 81: Endpoint up for at least one IP version id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"} ipVersion=0x4 status="up"
2024-07-31 11:50:03.527 [INFO][61] felix/status_combiner.go 98: Reporting combined status. id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"} status="up"

kubectl logs -n calico-system -l k8s-app=calico-node | grep demo/server # Shows similar log entries for each pod created, regardless of whether or not it has labels defined in the network policy
2024-07-31 11:30:55.356 [INFO][61] felix/endpoint_mgr.go 488: Re-evaluated workload endpoint status adminUp=true failed=false known=true operUp=true status="up" workloadEndpointID=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 11:30:55.356 [INFO][61] felix/status_combiner.go 58: Storing endpoint status update ipVersion=0x4 status="up" workload=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"}
2024-07-31 11:30:55.390 [INFO][61] felix/status_combiner.go 81: Endpoint up for at least one IP version id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"} ipVersion=0x4 status="up"
2024-07-31 11:30:55.391 [INFO][61] felix/status_combiner.go 98: Reporting combined status. id=proto.WorkloadEndpointID{OrchestratorId:"k8s", WorkloadId:"demo/server", EndpointId:"eth0"} status="up"

kubectl delete ns demo
kubectl create ns demo
kubectl run server --image=nginx --port=80 -n demo -l app=server
kubectl run client --image=nginx --port=80 -n demo -l app=client # includes the desired label
sleep 10
kubectl get po -n demo -owide --show-labels

kubectl exec -it client -n demo -- curl -I 10.224.0.71 # Server's IP address
HTTP/1.1 200 OK
```

```
az aks nodepool scale -g rgcal --cluster-name aks -n nodepool1 -c 1 # single node
kubectl delete netpol demo-policy -n demo
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: demo-policy
  namespace: demo
spec:
  podSelector:
    matchLabels:
      app: server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - port: 80
      protocol: TCP
EOF
kubectl delete ns demo
kubectl create ns demo
kubectl run server --image=nginx --port=80 -n demo -l app=server
kubectl run client --image=nginx --port=80 -n demo -l app=client # includes the desired label
sleep 10
clear
kubectl get po -A -owide | grep -E 'cal|tigera|client|server'
kubectl exec -it client -n demo -- curl -I 10.224.0.26 # Server's IP address. HTTP/1.1 200 OK

aks-nodepool1-49463138-vmss000000:/# tcpdump # No traffice for the IP 10.224.0.26. 10.224.0.4 is the node's IP and also associated with calico-node-tvvdh
09:51:46.855338 IP aks-nodepool1-49463138-vmss000000.internal.cloudapp.net.38283 > 168.63.129.16.domain: 56640+ PTR? 4.0.224.10.in-addr.arpa. (41)
09:51:46.871869 IP 168.63.129.16.domain > aks-nodepool1-49463138-vmss000000.internal.cloudapp.net.38283: 56640 1/0/0 PTR aks-nodepool1-49463138-vmss000000.internal.cloudapp.net. (110)
09:51:46.875459 IP aks-nodepool1-49463138-vmss000000.internal.cloudapp.net.47079 > 168.63.129.16.domain: 18952+ PTR? 16.129.63.168.in-addr.arpa. (44)
09:51:46.881494 IP 168.63.129.16.domain > aks-nodepool1-49463138-vmss000000.internal.cloudapp.net.47079: 18952 NXDomain 0/1/0 (130)

aks-nodepool1-49463138-vmss000000:/# iptables-save | grep demo-policy # entries are only in the node that has the server pod (as we'll see later)
-A cali-pi-_f33B8osgBB9KBtqM0k- -p tcp -m comment --comment "cali:d1YRlouMUUtO1U0c" -m comment --comment "Policy demo/knp.default.demo-policy ingress" -m set --match-set cali40s:N7qB4dD1ts0--qbzE-HjtMk src -m multiport --dports 80 -j MARK --set-xmark 0x10000/0x10000
```

```
az aks nodepool scale -g rgcal --cluster-name aks -n nodepool1 -c 3 # 2+ nodes.
kubectl delete netpol demo-policy -n demo
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: demo-policy
  namespace: demo
spec:
  podSelector:
    matchLabels:
      app: server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - port: 80
      protocol: TCP
EOF
kubectl delete ns demo
kubectl create ns demo
kubectl run server --image=nginx --port=80 -n demo -l app=server
clear
kubectl get po -A -owide | grep -E '^cal|^tigera|^demo'
kubectl get no -owide

kubectl run client --image=nginx --port=80 -n demo -l app=client --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-49463138-vmss000000" } } } } }' # includes the desired label. Server and client on different nodes.
sleep 10
kubectl exec -it client -n demo -- curl -I 10.224.0.81 # Server's IP address. HTTP/1.1 200 OK

calico-system     calico-kube-controllers-8484fb4dc7-bc9bl   1/1     Running   0          15h     10.224.0.11   aks-nodepool1-49463138-vmss000000   <none>           <none>
calico-system     calico-node-jsqqn                          1/1     Running   0          12m     10.224.0.33   aks-nodepool1-49463138-vmss000004   <none>           <none>
calico-system     calico-node-p8hn7                          1/1     Running   0          12m     10.224.0.62   aks-nodepool1-49463138-vmss000003   <none>           <none>
calico-system     calico-node-tvvdh                          1/1     Running   0          15h     10.224.0.4    aks-nodepool1-49463138-vmss000000   <none>           <none>
calico-system     calico-typha-7f985859c5-frmxh              1/1     Running   0          15h     10.224.0.4    aks-nodepool1-49463138-vmss000000   <none>           <none>
calico-system     calico-typha-7f985859c5-vzm77              1/1     Running   0          12m     10.224.0.33   aks-nodepool1-49463138-vmss000004   <none>           <none>
demo              client                                     1/1     Running   0          5m41s   10.224.0.34   aks-nodepool1-49463138-vmss000004   <none>           <none>
demo              server                                     1/1     Running   0          7m9s    10.224.0.81   aks-nodepool1-49463138-vmss000003   <none>           <none>
tigera-operator   tigera-operator-84cbbc54bd-fl4rr           1/1     Running   0          15h     10.224.0.4    aks-nodepool1-49463138-vmss000000   <none>           <none>
aks-nodepool1-49463138-vmss000000   Ready    agent   15h   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-49463138-vmss000003   Ready    agent   12m   v1.28.10   10.224.0.62   <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-49463138-vmss000004   Ready    agent   12m   v1.28.10   10.224.0.33   <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

aks-nodepool1-49463138-vmss000004:/# tcpdump # 10.224.0.81
10:10:51.395562 ARP, Request who-has 10.224.0.81 tell aks-nodepool1-49463138-vmss000004.internal.cloudapp.net, length 28
10:10:51.395899 ARP, Reply 10.224.0.81 is-at 12:34:56:78:9a:bc (oui Unknown), length 46
10:10:51.395906 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [S], seq 3198919571, win 64240, options [mss 1460,sackOK,TS val 3400462524 ecr 0,nop,wscale 7], length 0
10:10:51.400471 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [S.], seq 4213854059, ack 3198919572, win 65160, options [mss 1410,sackOK,TS val 3403388195 ecr 3400462524,nop,wscale 7], length 0
10:10:51.400521 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 3400462529 ecr 3403388195], length 0
10:10:51.400564 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [P.], seq 1:77, ack 1, win 502, options [nop,nop,TS val 3400462529 ecr 3403388195], length 76: HTTP: HEAD / HTTP/1.1
10:10:51.401387 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [.], ack 77, win 509, options [nop,nop,TS val 3403388198 ecr 3400462529], length 0
10:10:51.401635 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [P.], seq 1:239, ack 77, win 509, options [nop,nop,TS val 3403388198 ecr 3400462529], length 238: HTTP: HTTP/1.1 200 OK
10:10:51.401652 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [.], ack 239, win 501, options [nop,nop,TS val 3400462530 ecr 3403388198], length 0
10:10:51.402005 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [F.], seq 77, ack 239, win 501, options [nop,nop,TS val 3400462531 ecr 3403388198], length 0
10:10:51.402954 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [F.], seq 239, ack 78, win 509, options [nop,nop,TS val 3403388200 ecr 3400462531], length 0
10:10:51.402995 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [.], ack 240, win 501, options [nop,nop,TS val 3400462532 ecr 3403388200], length 0

aks-nodepool1-49463138-vmss000003:/# tcpdump # 10.224.0.81
10:10:51.397409 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [S], seq 3198919571, win 64240, options [mss 1410,sackOK,TS val 3400462524 ecr 0,nop,wscale 7], length 0
10:10:51.397511 ARP, Request who-has 10.224.0.34 tell aks-nodepool1-49463138-vmss000003.internal.cloudapp.net, length 28
10:10:51.399489 ARP, Reply 10.224.0.34 is-at 12:34:56:78:9a:bc (oui Unknown), length 46
10:10:51.399493 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [S.], seq 4213854059, ack 3198919572, win 65160, options [mss 1460,sackOK,TS val 3403388195 ecr 3400462524,nop,wscale 7], length 0
10:10:51.400694 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 3400462529 ecr 3403388195], length 0
10:10:51.400694 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [P.], seq 1:77, ack 1, win 502, options [nop,nop,TS val 3400462529 ecr 3403388195], length 76: HTTP: HEAD / HTTP/1.1
10:10:51.400739 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [.], ack 77, win 509, options [nop,nop,TS val 3403388198 ecr 3400462529], length 0
10:10:51.400981 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [P.], seq 1:239, ack 77, win 509, options [nop,nop,TS val 3403388198 ecr 3400462529], length 238: HTTP: HTTP/1.1 200 OK
10:10:51.401711 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [.], ack 239, win 501, options [nop,nop,TS val 3400462530 ecr 3403388198], length 0
10:10:51.402255 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [F.], seq 77, ack 239, win 501, options [nop,nop,TS val 3400462531 ecr 3403388198], length 0
10:10:51.402308 IP 10.224.0.81.http > 10.224.0.34.41296: Flags [F.], seq 239, ack 78, win 509, options [nop,nop,TS val 3403388200 ecr 3400462531], length 0
10:10:51.403708 IP 10.224.0.34.41296 > 10.224.0.81.http: Flags [.], ack 240, win 501, options [nop,nop,TS val 3400462532 ecr 3403388200], length 0
```

```
az aks nodepool scale -g rgcal --cluster-name aks -n nodepool1 -c 3 # 2+ nodes.
kubectl delete netpol demo-policy -n demo
cat << EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: demo-policy
  namespace: demo
spec:
  podSelector:
    matchLabels:
      app: server
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: client
    ports:
    - port: 80
      protocol: TCP
EOF
kubectl delete ns demo
kubectl create ns demo
kubectl run server --image=nginx --port=80 -n demo -l app=server
clear
kubectl get po -A -owide | grep -E '^cal|^tigera|^demo'
kubectl get no -owide

kubectl run client --image=nginx --port=80 -n demo --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/hostname": "aks-nodepool1-49463138-vmss000005" } } } } }' # doesn't include the desired label. Server and client on different nodes.
sleep 10
kubectl exec -it client -n demo -- curl -I 10.224.0.81 # Server's IP address. *   Trying 10.224.0.81:80...

calico-system     calico-kube-controllers-8484fb4dc7-bc9bl   1/1     Running   0          16h   10.224.0.11   aks-nodepool1-49463138-vmss000000   <none>           <none>
calico-system     calico-node-p8hn7                          1/1     Running   0          38m   10.224.0.62   aks-nodepool1-49463138-vmss000003   <none>           <none>
calico-system     calico-node-tvvdh                          1/1     Running   0          16h   10.224.0.4    aks-nodepool1-49463138-vmss000000   <none>           <none>
calico-system     calico-node-zs95t                          1/1     Running   0          14m   10.224.0.33   aks-nodepool1-49463138-vmss000005   <none>           <none>
calico-system     calico-typha-7f985859c5-frmxh              1/1     Running   0          16h   10.224.0.4    aks-nodepool1-49463138-vmss000000   <none>           <none>
calico-system     calico-typha-7f985859c5-v84s4              1/1     Running   0          13m   10.224.0.62   aks-nodepool1-49463138-vmss000003   <none>           <none>
demo              client                                     1/1     Running   0          12m   10.224.0.40   aks-nodepool1-49463138-vmss000005   <none>           <none>
demo              server                                     1/1     Running   0          13m   10.224.0.81   aks-nodepool1-49463138-vmss000003   <none>           <none>
tigera-operator   tigera-operator-84cbbc54bd-fl4rr           1/1     Running   0          16h   10.224.0.4    aks-nodepool1-49463138-vmss000000   <none>           <none>
aks-nodepool1-49463138-vmss000000   Ready    agent   16h    v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-49463138-vmss000003   Ready    agent   32m    v1.28.10   10.224.0.62   <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1
aks-nodepool1-49463138-vmss000005   Ready    agent   8m2s   v1.28.10   10.224.0.33   <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

aks-nodepool1-49463138-vmss000005:/# ip route
default via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.33 metric 100
10.224.0.0/16 dev eth0 proto kernel scope link src 10.224.0.33 metric 100
10.224.0.1 dev eth0 proto dhcp scope link src 10.224.0.33 metric 100
10.224.0.36 dev azv2bea9420050 scope link
10.224.0.40 dev azv0e8ee4fc632 scope link
168.63.129.16 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.33 metric 100
169.254.169.254 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.33 metric 100

aks-nodepool1-49463138-vmss000005:/# tcpdump
10:29:31.792679 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1460,sackOK,TS val 2912197717 ecr 0,nop,wscale 7], length 0
10:29:32.793279 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1460,sackOK,TS val 2912198718 ecr 0,nop,wscale 7], length 0
10:29:34.809282 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1460,sackOK,TS val 2912200734 ecr 0,nop,wscale 7], length 0
10:29:36.857225 ARP, Request who-has 10.224.0.81 tell aks-nodepool1-49463138-vmss000005.internal.cloudapp.net, length 28
10:29:36.857648 ARP, Reply 10.224.0.81 is-at 12:34:56:78:9a:bc (oui Unknown), length 46
10:29:38.905295 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1460,sackOK,TS val 2912204830 ecr 0,nop,wscale 7], length 0
10:29:47.097296 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1460,sackOK,TS val 2912213022 ecr 0,nop,wscale 7], length 0

aks-nodepool1-49463138-vmss000003:/# ip route
default via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.62 metric 100
10.224.0.0/16 dev eth0 proto kernel scope link src 10.224.0.62 metric 100
10.224.0.1 dev eth0 proto dhcp scope link src 10.224.0.62 metric 100
10.224.0.81 dev azve0cf0fbcf9f scope link
168.63.129.16 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.62 metric 100
169.254.169.254 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.62 metric 100

aks-nodepool1-49463138-vmss000003:/# tcpdump
10:29:31.792199 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1410,sackOK,TS val 2912197717 ecr 0,nop,wscale 7], length 0
10:29:32.801652 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1410,sackOK,TS val 2912198718 ecr 0,nop,wscale 7], length 0
10:29:34.808065 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1410,sackOK,TS val 2912200734 ecr 0,nop,wscale 7], length 0
10:29:38.906595 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1410,sackOK,TS val 2912204830 ecr 0,nop,wscale 7], length 0
10:29:47.097167 IP 10.224.0.40.38062 > 10.224.0.81.http: Flags [S], seq 1992866566, win 64240, options [mss 1410,sackOK,TS val 2912213022 ecr 0,nop,wscale 7], length 0

aks-nodepool1-49463138-vmss000003:/# iptables-save | grep demo-policy # entries are only in the node that has the server pod (likely due to it being an ingress network policy)
-A cali-pi-_f33B8osgBB9KBtqM0k- -p tcp -m comment --comment "cali:d1YRlouMUUtO1U0c" -m comment --comment "Policy demo/knp.default.demo-policy ingress" -m set --match-set cali40s:N7qB4dD1ts0--qbzE-HjtMk src -m multiport --dports 80 -j MARK --set-xmark 0x10000/0x10000

aks-nodepool1-49463138-vmss000003:/# iptables-save | grep azve0cf0fbcf9f # **calico policies that will drop packets if no policies passed packet
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:CdHsjen-CJmn3B3g" -m comment --comment "Start of policies" -j MARK --set-xmark 0x0/0x20000
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:TQaPYUSOdNvQvwg5" -m mark --mark 0x0/0x20000 -j cali-pi-_f33B8osgBB9KBtqM0k-
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:0QmZHflAbf4poj6J" -m comment --comment "Return if policy accepted" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:EGMMZ2I-ck_lMPHD" -m comment --comment "Drop if no policies passed packet" -m mark --mark 0x0/0x20000 -j DROP

aks-nodepool1-49463138-vmss000003:/# iptables-save | grep f33B8osgBB9KBtqM0k
:cali-pi-_f33B8osgBB9KBtqM0k- - [0:0]
-A cali-pi-_f33B8osgBB9KBtqM0k- -p tcp -m comment --comment "cali:d1YRlouMUUtO1U0c" -m comment --comment "Policy demo/knp.default.demo-policy ingress" -m set --match-set cali40s:N7qB4dD1ts0--qbzE-HjtMk src -m multiport --dports 80 -j MARK --set-xmark 0x10000/0x10000
-A cali-pi-_f33B8osgBB9KBtqM0k- -m comment --comment "cali:mU9s8yeSvrvV8Bcr" -m mark --mark 0x10000/0x10000 -j RETURN
-A cali-tw-azve0cf0fbcf9f -m comment --comment "cali:TQaPYUSOdNvQvwg5" -m mark --mark 0x0/0x20000 -j cali-pi-_f33B8osgBB9KBtqM0k-

aks-nodepool1-49463138-vmss000003:/# iptables -t filter -nvL # Viewing the alternate iptable chain output
Chain cali-tw-azve0cf0fbcf9f (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:1UpHwwB1N0gJ1ylp */ ctstate RELATED,ESTABLISHED
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:rlL-vIKuCuR6YmDf */ ctstate INVALID
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:bllg_ocjikHMqnAr */ MARK and 0xfffeffff
    0     0 MARK       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:CdHsjen-CJmn3B3g */ /* Start of policies */ MARK and 0xfffdffff
    0     0 cali-pi-_f33B8osgBB9KBtqM0k-  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:TQaPYUSOdNvQvwg5 */ mark match 0x0/0x20000
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:0QmZHflAbf4poj6J */ /* Return if policy accepted */ mark match 0x10000/0x10000
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:EGMMZ2I-ck_lMPHD */ /* Drop if no policies passed packet */ mark match 0x0/0x20000
    0     0 cali-pri-kns.demo  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:DXIG6lwiDDSQZLTh */
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:RmdwbQao5e0nG9Pt */ /* Return if profile accepted */ mark match 0x10000/0x10000
    0     0 cali-pri-ksa.demo.default  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:4Heytd6uysz9Ln8I */
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:uCMSm9AuL5n1kgOg */ /* Return if profile accepted */ mark match 0x10000/0x10000
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* cali:gH0VUEPiLOudLOOB */ /* Drop if no profiles matched */
```

- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#verify-network-policy-setup
