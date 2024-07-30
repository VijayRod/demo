```
kubectl delete po nginx
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: dns-example
spec:
  containers:
    - name: test
      image: nginx
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
      - 168.63.129.16 # this is an example
EOF
sleep 10
kubectl get po dns-example -owide
kubectl exec -it dns-example -- cat /etc/resolv.conf # nameserver 168.63.129.16

NAME          READY   STATUS    RESTARTS   AGE   IP           NODE                                NOMINATED NODE   READINESS GATES
dns-example   1/1     Running   0          19m   10.244.1.6   aks-nodepool1-14036957-vmss000001   <none>           <none>

kubectl exec -it dns-example -- curl nvidia.com

aks-nodepool1-14036957-vmss000001:/# tcpdump # grep -E 'amazon|54.239.28.85|85.28.239.54'
18:49:34.813567 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.33640 > 168.63.129.16.domain: 42168+ A? amazon.com. (28)
18:49:34.813583 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.33640 > 168.63.129.16.domain: 46782+ AAAA? amazon.com. (28)
18:49:34.840545 IP 168.63.129.16.domain > aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.33640: 46782 0/1/0 (95)
18:49:34.847114 IP 168.63.129.16.domain > aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.33640: 42168 3/0/0 A 54.239.28.85, A 52.94.236.248, A 205.251.242.103 (76)
18:49:34.847583 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [S], seq 3535315777, win 64240, options [mss 1460,sackOK,TS val 2301654930 ecr 0,nop,wscale 7], length 0
18:49:34.857937 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.55737 > 168.63.129.16.domain: 29622+ PTR? 85.28.239.54.in-addr.arpa. (43)
18:49:34.953702 IP 54.239.28.85.http > aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224: Flags [S.], seq 3557169697, ack 3535315778, win 8190, options [mss 1440,nop,wscale 6,nop,nop,sackOK], length 0
18:49:34.953785 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [.], ack 1, win 502, length 0
18:49:34.953869 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [P.], seq 1:75, ack 1, win 502, length 74: HTTP: GET / HTTP/1.1
18:49:35.057743 IP 54.239.28.85.http > aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224: Flags [P.], seq 1:189, ack 75, win 127, length 188: HTTP: HTTP/1.1 301 Moved Permanently
18:49:35.057743 IP 54.239.28.85.http > aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224: Flags [P.], seq 189:352, ack 75, win 127, length 163: HTTP
18:49:35.057837 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [.], ack 189, win 501, length 0
18:49:35.057846 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [.], ack 352, win 501, length 0
18:49:35.058058 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [F.], seq 75, ack 352, win 501, length 0
18:49:35.161496 IP 54.239.28.85.http > aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224: Flags [F.], seq 352, ack 76, win 127, length 0
18:49:35.161599 IP aks-nodepool1-14036957-vmss000001.internal.cloudapp.net.46224 > 54.239.28.85.http: Flags [.], ack 353, win 501, length 0
```

- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config
