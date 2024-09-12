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
