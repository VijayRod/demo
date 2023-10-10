```
kubectl delete svc nginx
kubectl delete po nginx 
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80 --type=LoadBalancer
kubectl describe svc nginx | grep External # External Traffic Policy:  Cluster
kubectl get svc nginx
kubectl get po -owide
```

```
NAME    TYPE           CLUSTER-IP   EXTERNAL-IP    PORT(S)        AGE
nginx   LoadBalancer   10.0.11.45   20.91.172.24   80:32643/TCP   87s

NAME             READY   STATUS    RESTARTS   AGE   IP           NODE                             NOMINATED NODE   READINESS GATES
nginx            1/1     Running   0          88s   10.244.2.5   aks-npuser-11270689-vmss000000   <none>           <none>

# aks-npuser-11270689-vmss000000
apt install net-tools
netstat -antpl | grep 32643 # No rows i.e. nothing listening on this endpoint
iptables-save | grep nginx # iptable rules are updated by kube-proxy to forward nodeport traffic to the (pod) endpoint (10.244.2.5:80) i.e. the pod replies with an HTTP status code 200. These rules are consistent (same) across all nodes.

-A KUBE-EXT-2CMXP7HKUVJN7L6M -m comment --comment "masquerade traffic for default/nginx external destinations" -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/nginx" -m tcp --dport 32643 -j KUBE-EXT-2CMXP7HKUVJN7L6M
-A KUBE-SEP-XW6I7J74P22Q2AZM -s 10.244.2.5/32 -m comment --comment "default/nginx" -j KUBE-MARK-MASQ
-A KUBE-SEP-XW6I7J74P22Q2AZM -p tcp -m comment --comment "default/nginx" -m tcp -j DNAT --to-destination 10.244.2.5:80
-A KUBE-SERVICES -d 10.0.11.45/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 80 -j KUBE-SVC-2CMXP7HKUVJN7L6M
-A KUBE-SERVICES -d 20.91.172.24/32 -p tcp -m comment --comment "default/nginx loadbalancer IP" -m tcp --dport 80 -j KUBE-EXT-2CMXP7HKUVJN7L6M
-A KUBE-SVC-2CMXP7HKUVJN7L6M ! -s 10.244.0.0/16 -d 10.0.11.45/32 -p tcp -m comment --comment "default/nginx cluster IP" -m tcp --dport 80 -j KUBE-MARK-MASQ
-A KUBE-SVC-2CMXP7HKUVJN7L6M -m comment --comment "default/nginx -> 10.244.2.5:80" -j KUBE-SEP-XW6I7J74P22Q2AZM

curl -I 20.91.172.24
HTTP/1.1 200 OK
```
