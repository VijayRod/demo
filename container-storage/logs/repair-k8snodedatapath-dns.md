## dns

```
# A DNS name server is a server that stores the DNS records for a domain
```

- https://wizardzines.com/zines/dns/
- https://www.cloudflare.com/learning/dns/what-is-dns/
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances

## dns..debug

```
# See the note below on https://www.digwebinterface.com/

# dig google.com

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31728
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             50      IN      A       172.217.21.174

;; Query time: 2 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Wed Aug 22 22:12:34 UTC 2023
;; MSG SIZE  rcvd: 55

# dig google.com ns +trace +nodnssec

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> google.com ns +trace +nodnssec
;; global options: +cmd
;; Received 28 bytes from 127.0.0.53#53(127.0.0.53) in 0 ms
```

```
# nslookup google.com

Server:         172.30.48.1
Address:        172.30.48.1#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.200.142
Name:   google.com
Address: 2a00:1450:4003:80f::200e

# nslookup google.com 8.8.8.8

Server:         8.8.8.8
Address:        8.8.8.8#53

Non-authoritative answer:
Name:   google.com
Address: 142.250.184.14
Name:   google.com
Address: 2a00:1450:4003:80e::200e

# azureuser@myvm:~$ nslookup google.com 168.63.129.16

Server:         168.63.129.16
Address:        168.63.129.16#53

Non-authoritative answer:
Name:   google.com
Address: 172.217.21.174
Name:   google.com
Address: 2a00:1450:400f:80c::200e
```

- https://www.digwebinterface.com/: type the fqdn, and press Dig. It will display the IP if the full fqdn can be resolved publicly, even if its linked to a private IP, like those used in AKS private clusters. If not, , it will show the part of the fqdn that can be resolved by the dns server.

## dns..server.relay

- https://support.huawei.com/enterprise/en/knowledge/EKB1000075807: FAQ-In What Scenarios Should I Use the DNS Relay Function. The DNS proxy or relay function enables a DNS client on a LAN to connect to an external DNS server. After the external DNS server translates the domain name of the DNS client to an IP address, the DNS client can access the Internet.
  After receiving DNS query packets from the DNS client, the device with DNS proxy enabled searches the local cache. The device with DNS relay enabled directly forwards the DNS query packets to the external DNS server, and does not search the local cache.
  If the DNS client needs to obtain resource records on the DNS server in real time, enable the DNS relay function on the device.
- https://help.dnsfilter.com/hc/en-us/sections/1500001413361-DNS-Relay
    
## dns..server.relay.windows

- https://my.f5.com/manage/s/article/K9694: Archived - K9694: Overview of the Windows DNS Relay Proxy service. the DNS Relay Proxy service directs client DNS requests to the DNS servers that are configured for the Network Access connection when the domain name matches a domain name in the DNS address space field. All other client DNS requests are directed to the DNS servers configured on the client system.

## dns..spec.record

- https://learn.microsoft.com/en-us/azure/dns/dns-zones-records#dns-records

> ## dns.azure.azuredns
- https://learn.microsoft.com/en-us/azure/dns/dns-overview
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#name-resolution-dns
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-3-verify-the-health-of-the-upstream-dns-servers: kubectl gadget trace dns -n kube-system -l k8s-app=kube-dns -o columns=k8s,id,qr,name,rcode,nameserver,latency -F nameserver:168.63.129.16
- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16?tabs=windows: Enables communication with the DNS virtual server. 168.63.129.16 can provide DNS services to the VM.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-3-verify-the-health-of-the-upstream-dns-servers: the default Azure DNS Server (IP address 168.63.129.16)

> ## dns.azure.azuredns..custom-dns
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-3-verify-the-health-of-the-upstream-dns-servers

> ## dns.azure.azuredns..custom-dns.update

- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances?tabs=redhat#specify-dns-servers: If you change the DNS settings for a virtual network or virtual machine that is already deployed, for the new DNS settings to take effect, you must perform a DHCP lease renewal on all affected VMs in the virtual network. For VMs running the Windows OS, you can do this by typing ipconfig /renew directly in the VM. (Restarting the Azure VMs and resources would also work.)
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#name-resolution-dns: If you change your DNS server list, you need to perform a DHCP lease renewal on all affected VMs in the virtual network...
- https://github.com/MicrosoftDocs/azure-docs/issues/19779: "If you change the DNS settings for a virtual network or virtual machine that is already deployed, you need to restart each affected VM for the changes to take effect."
- https://github.com/MicrosoftDocs/azure-docs/issues/68652: Release/Renew in Linux distributions Is little bit tricky as you might lose current SSH connection. So, here are the commands that should be run on the same line to avoid this issue. 
sudo dhclient -r && sudo dhclient 
Also, if you have more than one interface then use the below command to choose the right interface for renewal,
sudo dhclient -r eth0 && sudo dhclient eth0 

> ## dns.azure.azuredns.DnsResolver
- https://learn.microsoft.com/en-us/azure/dns/dns-private-resolver-overview
- https://learn.microsoft.com/en-us/azure/dns/private-resolver-architecture
- https://learn.microsoft.com/en-us/azure/architecture/networking/architecture/azure-dns-private-resolver
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-provided-dns-resolver-vm-limits
- tbd https://techcommunity.microsoft.com/blog/azureinfrastructureblog/centralized-private-resolver-architecture-implementation-using-azure-private-dns/4132622

> ## dns.azure.zone

- https://learn.microsoft.com/en-us/azure/dns/dns-zones-records#dns-zones
- https://www.cloudflare.com/learning/dns/glossary/dns-zone/
    
> ## dns.azure.zone.private-dns (private DNS zone)

> Refer to private dns

> ## dns.k8s.coredns

```
kubectl get po -n kube-system -l k8s-app=kube-dns
kubectl get po -n kube-system -l k8s-app=coredns-autoscaler
kubectl -n kube-system top pod | grep coredns
```

- https://kubernetes.io/docs/tasks/access-application-cluster/configure-dns-cluster/: CoreDNS is recommended and is installed by default with kubeadm
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/
- https://www.tkng.io/dns/
- https://github.com/kubernetes/dns: repository for Kubernetes DNS(kube-dns and nodelocaldns)
- https://github.com/kubernetes/kubernetes/blob/v1.24.9/cluster/addons/dns/coredns/coredns.yaml.base
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time
- https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#coredns: complying with the DNS specifications
- https://github.com/kubernetes/dns/blob/master/docs/specification.md

> ## dns.k8s.coredns.configmap.custom (corefile)

```
kubectl describe cm -n kube-system coredns-autoscaler # in a default cluster
```

- https://github.com/kubernetes-sigs/cluster-proportional-autoscaler#control-patterns-and-configmap-formats
- https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#coredns-configmap-options: The CoreDNS server can be configured by maintaining a Corefile, which is the CoreDNS configuration file.
- https://coredns.io/2017/07/23/corefile-explained/
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#are-dns-queries-being-received-processed: After saving the changes, it may take up to minute or two for Kubernetes to propagate these changes to the CoreDNS pods.

> ## dns.k8s.coredns.configmap.custom.ladder

```
# 8 replicas
k get po -n kube-system -l k8s-app=kube-dns
cat << EOF | kubectl apply -f -
apiVersion: v1
data:
  ladder: '{"coresToReplicas":[[1,8]],"nodesToReplicas":[[1,8]]}'
kind: ConfigMap
metadata:
  name: coredns-autoscaler
  namespace: kube-system
EOF
k get po -n kube-system -l k8s-app=kube-dns -w
```

- https://github.com/kubernetes-sigs/cluster-proportional-autoscaler?tab=readme-ov-file#ladder-mode

> ## dns.k8s.coredns.pod.autoscaler

```
# See coredns config map
```
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#configure-coredns-pod-scaling

> ## dns.k8s.coredns.pod.autoscaler.OOMKilled

```
kubectl get po -n kube-system -l k8s-app=coredns-autoscaler

kubectl describe cm -n kube-system coredns-autoscaler
Name:         coredns-autoscaler
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>
Data
====
ladder:
----
{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}
BinaryData
====
Events:  <none>

kubectl get configmap coredns-autoscaler -n kube-system -o yaml
apiVersion: v1
data:
  ladder: '{"coresToReplicas":[[1,2],[512,3],[1024,4],[2048,5]],"nodesToReplicas":[[1,2],[8,3],[16,4],[32,5]]}'
kind: ConfigMap
metadata:
  creationTimestamp: "2023-09-08T20:59:36Z"
  name: coredns-autoscaler
  namespace: kube-system
  resourceVersion: "1069"
  uid: 96464cfe-6b07-46c6-b140-336f70f95ea4
```

- https://github.com/coredns/coredns/issues/3388: The coredns pods always restart because of OOMKilled. In kubernetes, CoreDNS memory usage primarily correlates to the number of services/endpoints in the cluster...
- https://coredns.io/2018/11/15/scaling-coredns-in-kubernetes-clusters/: CoreDNS’s memory usage is predominantly affected by the number of Pods and Services in the cluster
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#configure-coredns-pod-scaling: Sudden spikes in DNS traffic... Out of memory issues
- TBD https://creators-note.chatwork.com/entry/stabilize-kubernetes-dns: Deploy dns-autoscaler

> ## dns.k8s.coredns.plugin
- https://coredns.io/plugins/
- https://github.com/coredns/coredns/blob/master/plugin/cache/README.md: README for each plugin
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#plugin-support
  
> ## dns.k8s.coredns.plugin..custom-domain
```
# These steps are similar to those for a private cluster with a private DNS zone
clustername=akscustomdomain
az aks create -g $rgname -n $clustername --enable-managed-identity --assign-identity $identityUri --vnet-subnet-id $subnetId
fqdn=$(az aks show -g $rgname -n $clustername --query fqdn -otsv); nslookup $fqdn

# To add an A record
az network private-dns record-set a add-record -g $rgname -z $privatezone -n db -a 20.91.129.141 # IP of the cluster FQDN

# To test in a cluster node with ping, ensure that the private DNS zone record returns the IP of the cluster FQDN
az aks get-credentials -g $rgname -n $clustername
root@aks-nodepool1-38956877-vmss000000:/# ping db.private.contoso.com
PING db.private.contoso.com (20.91.129.141) 56(84) bytes of data.

# To configure the CoreDNS config map
azureVip="168.63.129.16"
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  puglife.server: | # you may select any name here, but it must end with the .server file extension
    db.$privatezone:53 {
        errors
        cache 30
        forward . $azureVip  # this is my test/dev DNS server
    }
EOF
kubectl get cm -n kube-system coredns-custom -oyaml
kubectl -n kube-system rollout restart deployment coredns
kubectl get po -n kube-system -l k8s-app=kube-dns
```

```
# To test ping of the A record from a pod. Returns the IP of the cluster FQDN, i.e., 20.91.129.141.
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec -it dnsutils -- nslookup db.private.contoso.com
```

- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#use-custom-domains

> ## dns.k8s.coredns.plugin.header
- https://coredns.io/plugins/header/
- https://qasim-sarfraz.medium.com/dns-caching-gone-wrong-a329dc00452e

> ## dns.k8s.coredns.plugin.forward
```
# force_tcp, use TCP even when the request comes in over UDP
```
- https://coredns.io/plugins/forward/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#custom-forward-server

> ## dns.k8s.coredns.plugin.hosts
- https://coredns.io/plugins/hosts/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#hosts-plugin

> ## dns.k8s.coredns.plugin.log
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#enable-dns-query-logging
- https://coredns.io/plugins/log/
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#are-dns-queries-being-received-processed: You can verify if queries are being received by CoreDNS by adding the log plugin to the CoreDNS configuration (aka Corefile).

> ## dns.k8s.InspektorGadget (ig)

> ### ig.aks

```
# client
kubectl krew install gadget
kubectl gadget version

# cluster deploy
kubectl gadget deploy
kubectl gadget version

k get all -n gadget --show-labels
NAME               READY   STATUS    RESTARTS   AGE   LABELS
pod/gadget-xwtcn   1/1     Running   0          55s   controller-revision-hash=64cb8b4d7,k8s-app=gadget,pod-template-generation=1
pod/gadget-zw4b4   1/1     Running   0          55s   controller-revision-hash=64cb8b4d7,k8s-app=gadget,pod-template-generation=1
NAME                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE   LABELS
daemonset.apps/gadget   2         2         2       2            2           kubernetes.io/os=linux   56s   k8s-app=gadget
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-system-insights-from-aks

> ### ig..parameter.filter

```
kubectl gadget trace dns -l app=test-pod -o columns=k8s,id,qtype,qr,name,rcode,numAnswers,addresses -F name:~myheadless
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-5-verify-dns-responses-contain-the-expected-ip-addresses: kubectl gadget trace dns -l app=test-pod  -o columns=k8s,id,qtype,qr,name,rcode,numAnswers,addresses -F name:~myheadless

> ### ig..parameter.label (pod etc.)

```
# -l app=test-pod i.e. trace DNS query from any pod

# shell 2
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity'
kubectl exec -it dnsutils -- nslookup google.com
# shell 1
kubectl gadget trace dns -l run=dnsutils --output columns=k8s,id,qtype,qr,name,rcode,latency --filter name:google.com.
K8S.NODE             K8S.NAMESPACE        K8S.PODNAME         K8S.CONTAINERNAME   ID   QTYPE      QR NAME                RCODE        LATENCY   
aks-nodepo…mss000000 default              dnsutils            dnsutils            cb7e A          Q  google.com.                                
aks-nodepo…mss000000 default              dnsutils            dnsutils            cb7e A          R  google.com.         No Error     6.793145ms
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-4-verify-dns-queries-get-responses-in-a-timely-manner: kubectl gadget trace dns -l app=test-pod --output columns=k8s,id,qtype,qr,name,rcode,latency --filter name:microsoft.com.

> ### ig..parameter.label.coredns **

```
# -n kube-system -l k8s-app=kube-dns i.e. trace coredns quering azure-dns

# shell 2
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity'
kubectl exec -it dnsutils -- nslookup google.com
# shell 1
kubectl gadget trace dns -n kube-system -l k8s-app=kube-dns -o columns=k8s,id,qr,name,rcode,nameserver,latency -F nameserver:168.63.129.1616
K8S.NODE            K8S.NAMESPACE       K8S.PODNAME         K8S.CONTAINERNAME  ID   QR NAME               RCODE        NAMESERVER      LATENCY  
aks-nodep…mss000001 kube-system         coredns-5…994-lm9f8 coredns            6e16 Q  google.com.                     168.63.129.16            
aks-nodep…mss000001 kube-system         coredns-5…994-lm9f8 coredns            6e16 R  google.com.        No Error     168.63.129.16   5.67599ms
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/troubleshoot-dns-failures-across-an-aks-cluster-in-real-time#step-3-verify-the-health-of-the-upstream-dns-servers: kubectl gadget trace dns -n kube-system -l k8s-app=kube-dns -o columns=k8s,id,qr,name,rcode,nameserver,latency -F nameserver:168.63.129.16

> ### ig..parameter..output.columns

```
# shell 2
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity'
kubectl exec -it dnsutils -- nslookup google.com
# shell 1
kubectgadget trace dns --output columns=+nameserver
K8S.NODE      K8S.NAMESPACE K8S.PODNAME   PID     TID     PPID    COMM    PCOMM  QR TYPE    QTYPE  NAME         RCODE        NU… NAMESERVER     
aks-no…000000 default       dnsutils      335602  335608  329772  nslook… conta… Q  OUTGOI… A      google.com.…              0   10.0.0.10      
aks-no…000000 default       dnsutils      335602  335608  329772  nslook… conta… R  HOST    A      google.com.… Non-Existen… 0   10.0.0.10 
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-system-insights-from-aks#demo: kubectl gadget trace dns --namespace my-ns --output columns=+nameserver

```
# shell 2
kubectl run dnsutils --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --command -- sh -c 'sleep infinity'
k exec -it dnsutils -- nslookup google.com
# shell 1
k gadget trace dns --output columns=k8s,id,qtype,qr,name,rcode,latency | tee dnstrace
K8S.NODE                       K8S.NAMESPACE                  K8S.PODNAME                    K8S.CONTAINERNAME              ID   QTYPE            QR NAME                           RCODE            LATENCY
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       f2b1 A                Q  google.com.default.svc.cluste…                                  
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       f2b1 A                R  google.com.default.svc.cluste… Non-Existent Do… 2.36739ms       
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       2348 A                Q  google.com.svc.cluster.local.                                   
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       2348 A                R  google.com.svc.cluster.local.  Non-Existent Do… 988.495µs       
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       91a0 A                Q  google.com.cluster.local.                                       
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       91a0 A                R  google.com.cluster.local.      Non-Existent Do… 646.297µs       
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       437f A                Q  google.com.fwrbuenwudfepnfskp…                                  
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       437f A                R  google.com.fwrbuenwudfepnfskp… Non-Existent Do… 10.429756ms     
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       9ea9 A                Q  google.com.                                                     
aks-nodepool1-3…974-vmss000002 default                        dnsutils                       dnsutils                       9ea9 A                R  google.com.                    No Error         19.144319ms  
```

> ## dns.k8s.pod

```
kubectl run nginx --image=nginx
kubectl exec -it nginx -- /bin/bash # -- curl google.com -I # apt-get update -y && apt-get install dnsutils tcpdump -y
```

- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pods

> ## dns.k8s.pod.container./etc/resolv.conf ndots

```
kubectl exec -it nginx -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local ib5kedtkaf2udoxrc5h1huub5a.gvxx.internal.cloudapp.net
nameserver 10.0.0.10
options ndots:5

# tcpdump "Query name" for request for example.com
example.com.<namespace>.svc.cluster.local
example.com.svc.cluster.local
example.com.cluster.local
example.com

kubectl exec -it nginx -- curl https://openai.com
aks-nodepool1-14795161-vmss000004:/# tcpdump port 53
18:54:05.151003 IP 10.244.3.15.60716 > 10.244.4.31.domain: 13930+ A? openai.com.default.svc.cluster.local. (54)
18:54:05.151013 IP 10.244.3.15.60716 > 10.244.4.31.domain: 30567+ AAAA? openai.com.default.svc.cluster.local. (54)
18:54:05.162666 IP aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.48408 > 168.63.129.16.domain: 34640+ PTR? 31.4.244.10.in-addr.arpa. (42)
18:54:05.168102 IP 10.244.4.31.domain > 10.244.3.15.60716: 30567 NXDomain*- 0/1/0 (147)
18:54:05.168102 IP 10.244.4.31.domain > 10.244.3.15.60716: 13930 NXDomain*- 0/1/0 (147)
18:54:05.168759 IP 10.244.3.15.35829 > 10.244.4.31.domain: 11031+ A? openai.com.y3zj2hw02zpergryuyvnedbohd.gvxx.internal.cloudapp.net. (82)
18:54:05.168767 IP 10.244.3.15.35829 > 10.244.4.31.domain: 28949+ AAAA? openai.com.y3zj2hw02zpergryuyvnedbohd.gvxx.internal.cloudapp.net. (82)
18:54:05.175930 IP 10.244.4.31.domain > 10.244.3.15.35829: 28949 NXDomain*- 0/0/0 (82)
18:54:05.175930 IP 10.244.4.31.domain > 10.244.3.15.35829: 11031 NXDomain*- 0/0/0 (82)
18:54:05.175979 IP 10.244.3.15.41922 > 10.244.4.31.domain: 47994+ A? openai.com. (28)
18:54:05.175985 IP 10.244.3.15.41922 > 10.244.4.31.domain: 16764+ AAAA? openai.com. (28)
18:54:05.176916 IP 168.63.129.16.domain > aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.48408: 34640 NXDomain 0/1/0 (131)
18:54:05.177019 IP aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.44962 > 168.63.129.16.domain: 25244+ PTR? 15.3.244.10.in-addr.arpa. (42)
18:54:05.194925 IP 168.63.129.16.domain > aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.44962: 25244 NXDomain 0/1/0 (131)
18:54:05.204677 IP 10.244.4.31.domain > 10.244.3.15.41922: 47994 2/0/0 A 172.64.154.211, A 104.18.33.45 (80)
18:54:05.210187 IP 10.244.4.31.domain > 10.244.3.15.41922: 16764 0/1/0 (127)
18:54:05.262584 IP aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.44609 > 168.63.129.16.domain: 36315+ PTR? 16.129.63.168.in-addr.arpa. (44)
18:54:05.292833 IP 168.63.129.16.domain > aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.44609: 36315 NXDomain 0/1/0 (130)
18:54:05.292985 IP aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.54824 > 168.63.129.16.domain: 20844+ PTR? 7.0.224.10.in-addr.arpa. (41)
18:54:05.313986 IP 168.63.129.16.domain > aks-nodepool1-14795161-vmss000004.internal.cloudapp.net.54824: 20844 1/0/0 PTR aks-nodepool1-14795161-vmss000004.internal.cloudapp.net. (110)

kubectl exec -it nginx -- curl https://bing.com
aks-nodepool1-14795161-vmss000004:/# tcpdump port 53
18:54:20.870458 IP 10.244.3.15.40801 > 10.244.4.31.domain: 4511+ A? bing.com.default.svc.cluster.local. (52)
18:54:20.870468 IP 10.244.3.15.40801 > 10.244.4.31.domain: 55197+ AAAA? bing.com.default.svc.cluster.local. (52)
18:54:20.879466 IP 10.244.4.31.domain > 10.244.3.15.40801: 55197 NXDomain*- 0/1/0 (145)
18:54:20.879466 IP 10.244.4.31.domain > 10.244.3.15.40801: 4511 NXDomain*- 0/1/0 (145)
18:54:20.879835 IP 10.244.3.15.41003 > 10.244.4.31.domain: 55966+ A? bing.com.cluster.local. (40)
18:54:20.879843 IP 10.244.3.15.41003 > 10.244.4.31.domain: 43164+ AAAA? bing.com.cluster.local. (40)
18:54:20.897798 IP 10.244.4.31.domain > 10.244.3.15.41003: 43164 NXDomain*- 0/1/0 (133)
18:54:20.897799 IP 10.244.4.31.domain > 10.244.3.15.41003: 55966 NXDomain*- 0/1/0 (133)
18:54:20.898151 IP 10.244.3.15.53706 > 10.244.4.31.domain: 4276+ A? bing.com. (26)
18:54:20.898160 IP 10.244.3.15.53706 > 10.244.4.31.domain: 7862+ AAAA? bing.com. (26)
18:54:20.902750 IP 10.244.4.31.domain > 10.244.3.15.53706: 4276 2/0/0 A 150.171.28.10, A 150.171.27.10 (74)
18:54:20.905864 IP 10.244.4.31.domain > 10.244.3.15.53706: 7862 2/0/0 AAAA 2620:1ec:33::10, AAAA 2620:1ec:33:1::10 (98)
```
- https://pracucci.com/kubernetes-dns-resolution-ndots-options-and-why-it-may-affect-application-performances.html
- https://manpages.ubuntu.com/manpages/en/man5/resolv.conf.5.html

> ## dns.k8s.service

- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#services
