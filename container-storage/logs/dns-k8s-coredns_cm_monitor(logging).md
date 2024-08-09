```
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
#  kubectl get svc kubernetes # Retrieve the CoreDNS service IP
kubectl logs -n kube-system -l k8s-app=kube-dns -f --timestamps # grep openai.com

# determine the node where the application pod is running and then deploy a test dnsutil pod on that same node
kubectl delete po dnsutils
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dnsutils
  namespace: default
spec:
  nodeSelector:
    kubernetes.io/hostname: aks-nodepool1-22105430-vmss000001
  containers:
  - name: dnsutils
    image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
    command:
      - sleep
      - "infinity"
    imagePullPolicy: IfNotPresent
  restartPolicy: Always
EOF
sleep 10

kubectl get po -A -owide | grep -E 'coredns|dnsutils'
default            dnsutils                                             1/1     Running   0          4m59s   10.224.0.44   aks-nodepool1-22105430-vmss000001   <none>           <none>
kube-system        coredns-6464bcd74d-2dvxl                             1/1     Running   0          5m58s   10.224.0.17   aks-nodepool1-22105430-vmss000002   <none>           <none>
kube-system        coredns-6464bcd74d-lzcdk                             1/1     Running   0          5m58s   10.224.0.85   aks-nodepool1-22105430-vmss000000   <none>

kubectl exec dnsutils -- dig google.com +ignore +noedns +search +noshowsearch +time=10 +tries=6 10.224.0.17
kubectl exec dnsutils -- dig google.com +ignore +noedns +search +noshowsearch +time=10 +tries=6 10.224.0.85


kubectl logs -n kube-system -l k8s-app=kube-dns --timestamps | grep google.com
2024-08-09T18:02:21.907189239Z [INFO] 10.224.0.44:49852 - 57338 "A IN google.com. udp 28 false 512" NOERROR qr,rd,ra 54 0.002689133s
2024-08-09T18:02:02.138087885Z [INFO] 10.224.0.44:40079 - 25426 "A IN google.com. udp 28 false 512" NOERROR qr,rd,ra 54 0.02384305s

aks-nodepool1-22105430-vmss000000:/# tcpdump

aks-nodepool1-22105430-vmss000001:/# tcpdump
18:02:02.107410 ARP, Request who-has 10.224.0.17 tell aks-nodepool1-22105430-vmss000001.internal.cloudapp.net, length 28
18:02:02.107971 ARP, Reply 10.224.0.17 is-at 12:34:56:78:9a:bc (oui Unknown), length 28
18:02:02.107985 IP 10.224.0.44.40079 > 10.224.0.17.domain: 25426+ A? google.com. (28)
18:02:02.123522 IP aks-nodepool1-22105430-vmss000001.internal.cloudapp.net.58429 > 168.63.129.16.domain: 49973+ PTR? 17.0.224.10.in-addr.arpa. (42)
18:02:02.127385 IP 168.63.129.16.domain > aks-nodepool1-22105430-vmss000001.internal.cloudapp.net.58429: 49973 NXDomain 0/1/0 (131)
18:02:02.127698 IP aks-nodepool1-22105430-vmss000001.internal.cloudapp.net.53118 > 168.63.129.16.domain: 3208+ PTR? 44.0.224.10.in-addr.arpa. (42)
18:02:02.130358 IP 168.63.129.16.domain > aks-nodepool1-22105430-vmss000001.internal.cloudapp.net.53118: 3208 NXDomain 0/1/0 (131)
18:02:02.134836 IP 10.224.0.17.domain > 10.224.0.44.40079: 25426 1/0/0 A 142.251.46.206 (54)

aks-nodepool1-22105430-vmss000002:/# tcpdump
18:02:02.113684 IP 10.224.0.44.40079 > 10.224.0.17.domain: 25426+ A? google.com. (28)
18:02:02.114069 IP aks-nodepool1-22105430-vmss000002.internal.cloudapp.net.43810 > 168.63.129.16.domain: 18546+ [1au] A? google.com. (39)
18:02:02.133035 IP 13.87.229.75.https > aks-nodepool1-22105430-vmss000002.internal.cloudapp.net.53078: Flags [.], ack 492606, win 766, options [nop,nop,TS val 2374638181 ecr 3055640635], length 0
18:02:02.136280 IP 168.63.129.16.domain > aks-nodepool1-22105430-vmss000002.internal.cloudapp.net.43810: 18546 1/0/1 A 142.251.46.206 (55)
18:02:02.137680 ARP, Request who-has 10.224.0.44 tell aks-nodepool1-22105430-vmss000002.internal.cloudapp.net, length 28
18:02:02.138988 ARP, Reply 10.224.0.44 is-at 12:34:56:78:9a:bc (oui Unknown), length 28
18:02:02.139000 IP 10.224.0.17.domain > 10.224.0.44.40079: 25426 1/0/0 A 142.251.46.206 (54)

aks-nodepool1-22105430-vmss000002:/# nslookup google.com
Address: 142.250.191.78

i.e. 168.63.129.16.domain has responded with an A record and, and the coredns logs are showing a NOERROR status.
```

```
kubectl get po -A -owide | grep -E 'coredns|dnsutils'
default            dnsutils                                             1/1     Running   0          4m59s   10.224.0.44   aks-nodepool1-22105430-vmss000001   <none>           <none>
kube-system        coredns-6464bcd74d-2dvxl                             1/1     Running   0          5m58s   10.224.0.17   aks-nodepool1-22105430-vmss000002   <none>           <none>
kube-system        coredns-6464bcd74d-lzcdk                             1/1     Running   0          5m58s   10.224.0.85   aks-nodepool1-22105430-vmss000000   <none>

kubectl exec dnsutils -- dig google.com +ignore +noedns +search +noshowsearch +time=10 +tries=6 10.224.0.17
;; ANSWER SECTION:
google.com.             30      IN      A       142.251.46.206
;; Query time: 7 msec
;; SERVER: 10.0.0.10#53(10.0.0.10)
;; WHEN: Fri Aug 09 18:52:05 UTC 2024

kubectl logs -n kube-system -l k8s-app=kube-dns --timestamps | grep google.com
2024-08-09T18:52:26.470428763Z [INFO] 10.224.0.44:40063 - 48723 "A IN google.com. udp 28 false 512" NOERROR qr,rd,ra 54 0.002992433s

aks-nodepool1-22105430-vmss000001:/# tcpdump -e -n udp port 53
18:52:05.432542 00:22:48:03:b9:58 > 12:34:56:78:9a:bc, ethertype IPv4 (0x0800), length 70: 10.224.0.44.55697 > 10.224.0.17.53: 52528+ A? google.com. (28)
18:52:05.439456 c0:d6:82:28:97:6c > 00:22:48:03:b9:58, ethertype IPv4 (0x0800), length 96: 10.224.0.17.53 > 10.224.0.44.55697: 52528 1/0/0 A 142.251.46.206 (54)
18:52:05.439784 00:22:48:03:b9:58 > 12:34:56:78:9a:bc, ethertype IPv4 (0x0800), length 82: 10.224.0.44.46903 > 10.224.0.17.53: 35048+ [1au] A? 10.224.0.17. (40)
18:52:05.451375 c0:d6:82:28:97:6c > 00:22:48:03:b9:58, ethertype IPv4 (0x0800), length 157: 10.224.0.17.53 > 10.224.0.44.46903: 35048 NXDomain 0/1/1 (115)

aks-nodepool1-22105430-vmss000002:/# tcpdump -e -n udp port 53
18:52:05.441008 c0:d6:82:3b:69:f9 > 00:0d:3a:38:10:4e, ethertype IPv4 (0x0800), length 70: 10.224.0.44.55697 > 10.224.0.17.53: 52528+ A? google.com. (28)
18:52:05.446606 00:0d:3a:38:10:4e > 12:34:56:78:9a:bc, ethertype IPv4 (0x0800), length 96: 10.224.0.17.53 > 10.224.0.44.55697: 52528 1/0/0 A 142.251.46.206 (54)
18:52:05.447909 c0:d6:82:3b:69:f9 > 00:0d:3a:38:10:4e, ethertype IPv4 (0x0800), length 82: 10.224.0.44.46903 > 10.224.0.17.53: 35048+ [1au] A? 10.224.0.17. (40)
18:52:05.458306 00:0d:3a:38:10:4e > 12:34:56:78:9a:bc, ethertype IPv4 (0x0800), length 157: 10.224.0.17.53 > 10.224.0.44.46903: 35048 NXDomain 0/1/1 (115)
```
