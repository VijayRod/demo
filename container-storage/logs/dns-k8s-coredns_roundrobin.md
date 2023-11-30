- https://github.com/kubernetes/kubernetes/issues/76517: UDP packets from same source port do not round-robin in a kubernetes service. Packets are not load balanced across the pods, they all end up in the same pod until I stop the Go client and restart it. (Iptables load balance UDP packets based on source IP and port by design). 

```
kubectl create deploy iamyouare-udp --replicas 2 --image thockin/iamyouare -- /iamyouare -udp
kubectl expose deploy iamyouare-udp --port 9376 --protocol UDP
kubectl run cli-$RANDOM --rm -ti --image=busybox:latest --restart=Never
# for i in `seq 1 100`; do date | timeout 0.1 nc -w 1 -u iamyouare-udp 9376 2>&1 | grep server; done

kubectl delete svc iamyouare-udp
kubectl delete deploy iamyouare-udp
```

- https://github.com/kubernetes/kubernetes/issues/76517#issuecomment-1572368117

```
# Consider using node-local-dns, which adds a DNS cache on each node to handle DNS resolution requests for chatty applications.
# node-local-dns utilizes the TCP protocol (force_tcp) to communicate with the CoreDNS service, ensuring effective load balancing.
```

- TBD https://creators-note.chatwork.com/entry/stabilize-kubernetes-dns: Deploy node-local-dns
