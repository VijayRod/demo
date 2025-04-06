## iptables

```
# apt update -y && apt install iptables -y
iptables-save > /tmp/iptables
cat /tmp/iptables
```

- https://unix.stackexchange.com/questions/694562/which-layer-does-netfilter-and-iptables-works-on-in-the-osi-model: nftables (or the combination of iptables + arptables + ebtables) can affect just about any OSI layer except the physical one.
- https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html
  - https://www.frozentux.net/iptables-tutorial/chunkyhtml/
- https://wiki.centos.org/HowTos/Network/IPTables
- https://www.man7.org/linux/man-pages/man8/iptables.8.html
- https://blog.stevegriffith.nyc/posts/aks-networking-iptables
- tbd https://www.baeldung.com/linux/iptables-intro

## iptables.app.k8s.node

```
aks-nodepool1-12914153-vmss000000:/# iptables -vnL
Chain INPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
   47  2820 KUBE-PROXY-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
15044  397M KUBE-NODEPORTS  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes health check service ports */
   47  2820 KUBE-EXTERNAL-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
15545  398M KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain FORWARD (policy ACCEPT 276 packets, 32187 bytes)
 pkts bytes target     prot opt in     out     source               destination
  295 34694 KUBE-PROXY-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
 7860 2308K KUBE-FORWARD  all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */
  295 34694 KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
  276 32187 KUBE-EXTERNAL-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes externally-visible service portals */
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            168.63.129.16        tcp dpt:32526
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            168.63.129.16        tcp dpt:80

Chain OUTPUT (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
  792 48468 KUBE-PROXY-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes load balancer firewall */
  792 48468 KUBE-SERVICES  all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate NEW /* kubernetes service portals */
13490 4036K KUBE-FIREWALL  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain KUBE-EXTERNAL-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination

Chain KUBE-FIREWALL (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *      !127.0.0.0/8          127.0.0.0/8          /* block incoming localnet connections */ ! ctstate RELATED,ESTABLISHED,DNAT

Chain KUBE-FORWARD (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       all  --  *      *       0.0.0.0/0            0.0.0.0/0            ctstate INVALID
    0     0 ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding rules */
 4025  934K ACCEPT     all  --  *      *       0.0.0.0/0            0.0.0.0/0            /* kubernetes forwarding conntrack rule */ ctstate RELATED,ESTABLISHED

Chain KUBE-KUBELET-CANARY (0 references)
 pkts bytes target     prot opt in     out     source               destination

Chain KUBE-NODEPORTS (1 references)
 pkts bytes target     prot opt in     out     source               destination

Chain KUBE-PROXY-CANARY (0 references)
 pkts bytes target     prot opt in     out     source               destination

Chain KUBE-PROXY-FIREWALL (3 references)
 pkts bytes target     prot opt in     out     source               destination

Chain KUBE-SERVICES (2 references)
 pkts bytes target     prot opt in     out     source               destination

aks-nodepool1-12914153-vmss000000:/# ipset -L # No rows
```

```
kubectl run nginx --image=nginx
kubectl get po nginx -owide
NAME    READY   STATUS    RESTARTS   AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          17s   10.244.0.13   aks-nodepool1-12914153-vmss000000   <none>           <none>

aks-nodepool1-12914153-vmss000000:/# iptables-save # No new entries
aks-nodepool1-12914153-vmss000000:/# iptables -vnL # No new entries
aks-nodepool1-12914153-vmss000000:/# ipset -L # No rows

kubectl expose po nginx --port=80
kubectl get svc nginx
NAME    TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx   ClusterIP   10.0.91.63   <none>        80/TCP    0s

aks-nodepool1-12914153-vmss000000:/# iptables-save | grep nginx
-A KUBE-SEP-RPYTXMYI33B6SF5E -s 10.244.0.13/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-RPYTXMYI33B6SF5E -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.244.0.13:80
-A KUBE-SERVICES -d 10.0.91.63/32 -p tcp -m comment --comment "default/nginx cluster IP" -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.0.91.63/32 -p tcp -m comment --comment "default/nginx cluster IP" -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.0.13:80" -j KUBE-SEP-RPYTXMYI33B6SF5E

aks-nodepool1-12914153-vmss000000:/# iptables -vnL # No new entries
aks-nodepool1-12914153-vmss000000:/# ipset -L # No rows
```

- https://blog.stevegriffith.nyc/posts/aks-networking-iptables
- https://www.altoros.com/blog/kubernetes-networking-writing-your-own-simple-cni-plug-in-with-bash/: Fixing container-to-container communication...
  
## iptables.app.k8s.node.kube-proxy

```
kubectl run nginx --image=nginx
kubectl logs -n kube-system -l component=kube-proxy
Defaulted container "kube-proxy" out of: kube-proxy, kube-proxy-bootstrap (init)
I0913 18:17:34.400497       1 endpointslicecache.go:348] "Setting endpoints for service port name" portName="default/nginx" endpoints=["10.244.0.14:80"]
I0913 18:17:34.400576       1 proxier.go:798] "Syncing iptables rules"
I0913 18:17:34.403738       1 proxier.go:1508] "Reloading service iptables data" numServices=5 numEndpoints=8 numFilterChains=6 numFilterRules=4 numNATChains=7 numNATRules=18
I0913 18:17:34.422143       1 proxier.go:792] "SyncProxyRules complete" elapsed="21.67114ms"
I0913 18:17:34.422160       1 bounded_frequency_runner.go:296] sync-runner: ran, next possible in 1s, periodic in 1h0m0s

kubectl get ds -n kube-system -l component=kube-proxy
NAME         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
kube-proxy   1         1         1       1            1           <none>          5d7h

kubectl describe po -n kube-system -l component=kube-proxy
Containers:
  kube-proxy:
    Container ID:  containerd://f569efd14bd10a34f092fada341ddff34c673915c8a525102471f03d62d87d00
    Image:         mcr.microsoft.com/oss/kubernetes/kube-proxy:v1.29.7
    Image ID:      sha256:822d5c9ec9537805bc26748498d6ac50d02da464690503af84409fa3ec04c909
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-proxy
      --conntrack-max-per-core=0
      --metrics-bind-address=0.0.0.0:10249
      --cluster-cidr=10.251.0.0/16
      --detect-local-mode=InterfaceNamePrefix
      --pod-interface-name-prefix=azv
      --v=3

# nsenter
ps -aux | grep pause
65535       4196  0.0  0.0    972     4 ?        Ss   13:12   0:00 /pause
65535       4204  0.0  0.0    972     4 ?        Ss   13:12   0:00 /pause
nsenter -t 4196 -n iptables-save
# Generated by iptables-save v1.8.7 on Tue Oct 29 18:11:59 2024
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:IP-MASQ-AGENT - [0:0]
:KUBE-KUBELET-CANARY - [0:0]
:KUBE-MARK-MASQ - [0:0]
:KUBE-NODEPORTS - [0:0]
:KUBE-POSTROUTING - [0:0]
:KUBE-PROXY-CANARY - [0:0]
:KUBE-SEP-ATPX5OCMXFBBS6CF - [0:0]
:KUBE-SEP-C5BHK5WAW35LL4WX - [0:0]
:KUBE-SEP-F7UUGJV753TV2LHR - [0:0]
:KUBE-SEP-FVL7C3WAQGHN5DAN - [0:0]
:KUBE-SEP-H54KZ5GUNOAKYPID - [0:0]
:KUBE-SEP-IT2ZTR26TO4XFPTO - [0:0]
:KUBE-SEP-LASJGFFJP3UOS6RQ - [0:0]
:KUBE-SEP-LPGSDLJ3FDW46N4W - [0:0]
:KUBE-SEP-LXXYVRSWACZZN2HZ - [0:0]
:KUBE-SEP-NRRV3CFSTOI47WX5 - [0:0]
:KUBE-SEP-OLKPAMFGEKUYUH24 - [0:0]
:KUBE-SEP-RYPLX3PIOV7KXRLS - [0:0]
:KUBE-SEP-UDR3XRFX2TD4H2DU - [0:0]
:KUBE-SEP-VLQ4Z6JDWV4JRKNA - [0:0]
:KUBE-SEP-YIL6JZP7A3QYXJU2 - [0:0]
:KUBE-SERVICES - [0:0]
:KUBE-SVC-6KERD2IN6AEBO2WW - [0:0]
:KUBE-SVC-ERIFXISQEP7F7OF4 - [0:0]
:KUBE-SVC-GK3BZPKCWUFYCJHE - [0:0]
:KUBE-SVC-NPX46M4PTMTKRN6Y - [0:0]
:KUBE-SVC-QMWWTXBG7KFJQKLO - [0:0]
:KUBE-SVC-R6ANSUKRPKVTBBNX - [0:0]
:KUBE-SVC-TCOU7JCQXEZGVUNU - [0:0]
:KUBE-SVC-X5AB4RUXCTLOCO67 - [0:0]
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
nsenter -t 4196 -n iptables -L -t nat -v # List the rules in a chain or all chains
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/
- https://kubernetes.io/docs/concepts/overview/components/#node-components: kube-proxy (optional). Maintains network rules on nodes to implement Services.

## iptables.spec.other.chain

```
iptables -L | grep Chain
iptables -L INPUT # --line-numbers
iptables -nvL INPUT
iptables -nvL INPUT -t filter
iptables -t filter -nvL # To view all iptable chains
```

- https://thelinuxcode.com/iptables-tutorial/
- tbd https://stackoverflow.com/questions/14955973/iptables-what-is-a-chain
- https://unix.stackexchange.com/questions/506729/what-is-a-chain-in-iptables
- https://www.baeldung.com/linux/iptables-chains-tables-traversal
- https://unix.stackexchange.com/questions/189905/how-iptables-tables-and-chains-are-traversed
- https://stuffphilwrites.com/2014/09/iptables-processing-flowchart/
- https://upload.wikimedia.org/wikipedia/commons/3/37/Netfilter-packet-flow.svg
- https://rlworkman.net/howtos/iptables/chunkyhtml/c962.html
- http://linux-ip.net/pages/diagrams.html#netfilter-kernel-packet-traversal
- https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture
- tbd https://cloudzy.com/blog/iptables-show-rules/
- https://thelinuxcode.com/iptables-tutorial/: https://thelinuxcode.com/iptables-tutorial/

## iptables.spec.other.tables

```
iptables -vL -t filter
iptables -vL -t nat
iptables -vL -t mangle
iptables -vL -t raw
iptables -vL -t security
```

- https://unix.stackexchange.com/questions/205867/viewing-all-iptables-rules: iptables controls five different tables: filter, nat, mangle, raw and security. ...
- https://thelinuxcode.com/iptables-tutorial/: These built-in chains belong to various  iptables tables...
