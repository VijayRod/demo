## dns

```
# A DNS name server is a server that stores the DNS records for a domain
```

- https://wizardzines.com/zines/dns/
- https://www.cloudflare.com/learning/dns/what-is-dns/
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-name-resolution-for-vms-and-role-instances

## dns..debug

```
# misc

nslookup example.com

grep ' R ' dnstrace-file  | awk '{print $NF}' | grep -v -e ms -e µs | sort -nr | head # dnstrace a example.com 8.8.8.8

dig example.com

Steady ping to the custom DNS server, e.g., ping -D -O -n -W 20 8.8.8.8 >l 2>&1 # grep -A 2 -B 2 'no answer' l 
# grep 'no answer yet for icmp_seq=' # grep 'timed'

wireshark: dns.qry.name=="example.com" and ip.addr==168.63.129.16
```

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

```
# ttl (seconds) in the DNS protocol
# different from ttl (hops) in the IP protocol

dig +nocmd example +noall +answer # example.com.            295     IN      A       23.192.228.80 (i.e., 295 seconds)

wireshark: dns and dns.qry.name=="example.com" and ip.addr==168.63.129.16 # check if A record requests for the same fqdn are repeated in less than the ttl time, for example, by coredns. 
# this indicates caching issues and results in load on the dns query path

coredns.configmap: cache 30

coredns.configmap: forward . /etc/resolv.conf # the upstream dns server might have a lower ttl, which can be checked using dig

pod.dnspolicy set to default, rather than ClusterFirst, will not use coredns but will instead use the host's dns.
```

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

```
# Refer azurevm
```

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

> ## dns.azure.azurevm (virtual machine)

```
# Refer azuredns
```

- https://xkln.net/blog/dns-name-resolution-in-azure/

```
# limit.azuredns.vm
# Alternatives: caching (dnsmasq/CoreDNS), DNS forwarding, Azure DNS Private Resolver, distributing DNS query load across VMs (application dependent)
# https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-provided-dns-resolver-vm-limits: DNS queries exceeding these limits are dropped
```
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-dns-limits
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-provided-dns-resolver-vm-limits: These limits are applied to every individual virtual machine.. DNS queries exceeding these limits are dropped.. apply to the default Azure resolver (168.63.129.16)
- https://learn.microsoft.com/en-gb/answers/questions/1332572/can-we-have-more-than-1000-queries-on-virtual-mach
- https://learn.microsoft.com/en-us/answers/questions/1375896/where-can-i-find-azure-%28private%29-dns-network-limit: NSG flow logs
- https://learn.microsoft.com/en-us/azure/dns/dns-faq#what-are-the-usage-limits-for-azure-dns-

```
# limit.network-throughput.azurevm
# scale up (increase SKU) or scale out (distribute application load)
```
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput: Larger virtual machines are allocated relatively more bandwidth than smaller virtual machines.
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/d-family: Network (Mbps)
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput#expected-network-throughput

```
# limit.network-flow.azurevm
# a typical TCP/UDP connection, it creates two flows: one for inbound traffic and another for outbound traffic
# https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput#network-flow-limits: Once this limit is hit, other connections are dropped.
```

- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput#network-flow-limits: VMs that belong to a virtual network can handle 500k active connections for all VM sizes with 500k active flows in each direction.
  - VMs with NVAs such as gateway, proxy, firewall can handle 250k active connections with 500k active flows in each direction..
  - Once this limit is hit, other connections are dropped.
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-machine-network-throughput: a typical TCP/UDP connection, it creates two flows: one for inbound traffic and another for outbound traffic

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

```
# app and coredns pods on different nodes
k get po -A -owide | grep -E 'coredns|nginx'; k get no
kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-16317344-vmss000001"}}}' # --dry-run client -oyaml
kubectl exec -it nginx -- curl https://openai.com
k cordon aks-nodepool1-16317344-vmss000001 aks-nodepool1-16317344-vmss000002
kubectl -n kube-system rollout restart deployment coredns
clear; tcpdump port 53

# app pod node
# nginx pod 10.244.1.48 in node vmss000001; 10.244.0.229 and 10.244.0.241 are coredns pods in node vmss000000
# app pod queries the coredns pod for the A record
root@aks-nodepool1-16317344-vmss000001:/# tcpdump port 53
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C18:07:11.872179 IP 10.244.1.48.58473 > 10.244.0.229.domain: 14937+ A? openai.com.default.svc.cluster.local. (54)
18:07:11.872190 IP 10.244.1.48.58473 > 10.244.0.229.domain: 17316+ AAAA? openai.com.default.svc.cluster.local. (54)
18:07:11.887111 IP 10.244.0.229.domain > 10.244.1.48.58473: 17316 NXDomain*- 0/1/0 (147)
18:07:11.887111 IP 10.244.0.229.domain > 10.244.1.48.58473: 14937 NXDomain*- 0/1/0 (147)
18:07:11.887198 IP 10.244.1.48.40978 > 10.244.0.229.domain: 51534+ A? openai.com.svc.cluster.local. (46)
18:07:11.887204 IP 10.244.1.48.40978 > 10.244.0.229.domain: 41804+ AAAA? openai.com.svc.cluster.local. (46)
18:07:11.888046 IP 10.244.0.229.domain > 10.244.1.48.40978: 41804 NXDomain*- 0/1/0 (139)
18:07:11.888046 IP 10.244.0.229.domain > 10.244.1.48.40978: 51534 NXDomain*- 0/1/0 (139)
18:07:11.888094 IP 10.244.1.48.49922 > 10.244.0.241.domain: 25886+ A? openai.com.cluster.local. (42)
18:07:11.888100 IP 10.244.1.48.49922 > 10.244.0.241.domain: 2816+ AAAA? openai.com.cluster.local. (42)
18:07:11.889558 IP 10.244.0.241.domain > 10.244.1.48.49922: 2816 NXDomain*- 0/1/0 (135)
18:07:11.889559 IP 10.244.0.241.domain > 10.244.1.48.49922: 25886 NXDomain*- 0/1/0 (135)
18:07:11.889595 IP 10.244.1.48.59423 > 10.244.0.241.domain: 35643+ A? openai.com.l13s53dgmqzeng4qvhnihfn1bc.gvxx.internal.cloudapp.net. (82)
18:07:11.889601 IP 10.244.1.48.59423 > 10.244.0.241.domain: 62781+ AAAA? openai.com.l13s53dgmqzeng4qvhnihfn1bc.gvxx.internal.cloudapp.net. (82)
18:07:11.898616 IP 10.244.0.241.domain > 10.244.1.48.59423: 35643 NXDomain*- 0/0/0 (82)
18:07:11.898616 IP 10.244.0.241.domain > 10.244.1.48.59423: 62781 NXDomain*- 0/0/0 (82)
18:07:11.898672 IP 10.244.1.48.58210 > 10.244.0.241.domain: 33240+ A? openai.com. (28)
18:07:11.898678 IP 10.244.1.48.58210 > 10.244.0.241.domain: 63454+ AAAA? openai.com. (28)
18:07:11.906718 IP 10.244.0.241.domain > 10.244.1.48.58210: 63454 0/1/0 (127)
18:07:11.907595 IP 10.244.0.241.domain > 10.244.1.48.58210: 33240 2/0/0 A 172.64.154.211, A 104.18.33.45 (80)
18:07:11.987967 IP aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.38296 > 168.63.129.16.domain: 27347+ PTR? 229.0.244.10.in-addr.arpa. (43)
18:07:12.011232 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.38296: 27347 NXDomain 0/1/0 (132)
18:07:12.011362 IP aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.33550 > 168.63.129.16.domain: 20675+ PTR? 48.1.244.10.in-addr.arpa. (42)
18:07:12.014900 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.33550: 20675 NXDomain 0/1/0 (131)
18:07:12.051257 IP aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.42760 > 168.63.129.16.domain: 34735+ PTR? 241.0.244.10.in-addr.arpa. (43)
18:07:12.061228 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.42760: 34735 NXDomain 0/1/0 (132)
18:07:12.061398 IP aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.40797 > 168.63.129.16.domain: 16911+ PTR? 16.129.63.168.in-addr.arpa. (44)
18:07:12.062860 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.40797: 16911 NXDomain 0/1/0 (130)
18:07:12.062921 IP aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.38976 > 168.63.129.16.domain: 52539+ PTR? 5.0.224.10.in-addr.arpa. (41)
18:07:12.073303 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000001.internal.cloudapp.net.38976: 52539 1/0/0 PTR aks-nodepool1-16317344-vmss000001.internal.cloudapp.net. (110)

# coredns pods on this node
# coredns pod queries the default azure dns server for the A record
root@aks-nodepool1-16317344-vmss000000:/# tcpdump port 53
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C18:07:11.884017 IP 10.244.1.48.58473 > 10.244.0.229.domain: 14937+ A? openai.com.default.svc.cluster.local. (54)
18:07:11.884017 IP 10.244.1.48.58473 > 10.244.0.229.domain: 17316+ AAAA? openai.com.default.svc.cluster.local. (54)
18:07:11.884306 IP 10.244.0.229.domain > 10.244.1.48.58473: 17316 NXDomain*- 0/1/0 (147)
18:07:11.884336 IP 10.244.0.229.domain > 10.244.1.48.58473: 14937 NXDomain*- 0/1/0 (147)
18:07:11.887538 IP 10.244.1.48.40978 > 10.244.0.229.domain: 51534+ A? openai.com.svc.cluster.local. (46)
18:07:11.887538 IP 10.244.1.48.40978 > 10.244.0.229.domain: 41804+ AAAA? openai.com.svc.cluster.local. (46)
18:07:11.887697 IP 10.244.0.229.domain > 10.244.1.48.40978: 41804 NXDomain*- 0/1/0 (139)
18:07:11.887765 IP 10.244.0.229.domain > 10.244.1.48.40978: 51534 NXDomain*- 0/1/0 (139)
18:07:11.888883 IP 10.244.1.48.49922 > 10.244.0.241.domain: 25886+ A? openai.com.cluster.local. (42)
18:07:11.888883 IP 10.244.1.48.49922 > 10.244.0.241.domain: 2816+ AAAA? openai.com.cluster.local. (42)
18:07:11.889037 IP 10.244.0.241.domain > 10.244.1.48.49922: 2816 NXDomain*- 0/1/0 (135)
18:07:11.889058 IP 10.244.0.241.domain > 10.244.1.48.49922: 25886 NXDomain*- 0/1/0 (135)
18:07:11.895243 IP 10.244.1.48.59423 > 10.244.0.241.domain: 35643+ A? openai.com.l13s53dgmqzeng4qvhnihfn1bc.gvxx.internal.cloudapp.net. (82)
18:07:11.895243 IP 10.244.1.48.59423 > 10.244.0.241.domain: 62781+ AAAA? openai.com.l13s53dgmqzeng4qvhnihfn1bc.gvxx.internal.cloudapp.net. (82)
18:07:11.895362 IP 10.244.0.241.domain > 10.244.1.48.59423: 35643 NXDomain*- 0/0/0 (82)
18:07:11.895389 IP 10.244.0.241.domain > 10.244.1.48.59423: 62781 NXDomain*- 0/0/0 (82)
18:07:11.903133 IP 10.244.1.48.58210 > 10.244.0.241.domain: 33240+ A? openai.com. (28)
18:07:11.903133 IP 10.244.1.48.58210 > 10.244.0.241.domain: 63454+ AAAA? openai.com. (28)
18:07:11.903311 IP aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.52267 > 168.63.129.16.domain: 7764+ [1au] AAAA? openai.com. (39)
18:07:11.903369 IP aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.54632 > 168.63.129.16.domain: 20080+ [1au] A? openai.com. (39)
18:07:11.905989 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.52267: 7764 0/1/1 (122)
18:07:11.906071 IP 10.244.0.241.domain > 10.244.1.48.58210: 63454 0/1/0 (127)
18:07:11.907270 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.54632: 20080 2/0/1 A 172.64.154.211, A 104.18.33.45 (71)
18:07:11.907347 IP 10.244.0.241.domain > 10.244.1.48.58210: 33240 2/0/0 A 172.64.154.211, A 104.18.33.45 (80)
18:07:11.940285 IP aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.54797 > 168.63.129.16.domain: 11467+ PTR? 229.0.244.10.in-addr.arpa. (43)
18:07:11.943980 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.54797: 11467 NXDomain 0/1/0 (132)
18:07:11.944063 IP aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.52304 > 168.63.129.16.domain: 9955+ PTR? 48.1.244.10.in-addr.arpa. (42)
18:07:11.955673 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.52304: 9955 NXDomain 0/1/0 (131)
18:07:11.955811 IP aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.54891 > 168.63.129.16.domain: 61926+ PTR? 241.0.244.10.in-addr.arpa. (43)
18:07:11.959192 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.54891: 61926 NXDomain 0/1/0 (132)
```

> ## dns.k8s.coredns.configmap.custom (corefile)

```
# a default-created aks cluster includes the coredns and the empty coredns-custom config maps

k describe cm -n kube-system coredns-custom
Name:         coredns-custom
Namespace:    kube-system
Labels:       addonmanager.kubernetes.io/mode=EnsureExists
              k8s-app=kube-dns
              kubernetes.io/cluster-service=true
Annotations:  <none>
Data
====
BinaryData
====
Events:  <none>

k describe cm -n kube-system coredns
Name:         coredns
Namespace:    kube-system
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              k8s-app=kube-dns
              kubernetes.io/cluster-service=true
Annotations:  <none>
Data
====
Corefile:
----
.:53 {
    errors
    ready
    health {
      lameduck 5s
    }
    kubernetes cluster.local in-addr.arpa ip6.arpa {
      pods insecure
      fallthrough in-addr.arpa ip6.arpa
      ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
    import custom/*.override
    template ANY ANY internal.cloudapp.net {
      match "^(?:[^.]+\.){4,}internal\.cloudapp\.net\.$"
      rcode NXDOMAIN
      fallthrough
    }
    template ANY ANY reddog.microsoft.com {
      rcode NXDOMAIN
    }
}
import custom/*.server
BinaryData
====
Events:  <none>
```

- https://github.com/kubernetes-sigs/cluster-proportional-autoscaler#control-patterns-and-configmap-formats
- https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#coredns-configmap-options: The CoreDNS server can be configured by maintaining a Corefile, which is the CoreDNS configuration file.
- https://coredns.io/2017/07/23/corefile-explained/
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#are-dns-queries-being-received-processed: After saving the changes, it may take up to minute or two for Kubernetes to propagate these changes to the CoreDNS pods.

> ## dns.k8s.coredns.pod.autoscaler

```
kubectl describe cm -n kube-system coredns-autoscaler # in a default cluster
```
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#configure-coredns-pod-scaling

```
# coredns-autoscaler.configmap.data.ladder

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


> ## dns.k8s.coredns.plugin.cache
- https://github.com/coredns/coredns/blob/master/plugin/cache/README.md

> ## dns.k8s.coredns.plugin.header
- https://coredns.io/plugins/header/
- https://qasim-sarfraz.medium.com/dns-caching-gone-wrong-a329dc00452e

> ## dns.k8s.coredns.plugin.forward

- https://coredns.io/plugins/forward/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#custom-forward-server

```
# force_tcp, use TCP even when the request comes in over UDP. TCP is preferred for reliability

# coredns is in CrashLoopBackOff with "Unknown directive 'force_tcp'" if the forward plugin is not specified for a particular zone, as it otherwise conflicts with the main coredns configmap
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  custom.server: |
    openai.com:53 {
      forward . /etc/resolv.conf {
        force_tcp
      }
    }
EOF
kubectl get cm -n kube-system coredns-custom -oyaml
kubectl -n kube-system rollout restart deployment coredns
kubectl get po -n kube-system -l k8s-app=kube-dns

kubectl exec -it nginx -- curl https://openai.com

# node hosting coredns shows tcp used for the A record per the flag [P.], seq etc.
root@aks-nodepool1-16317344-vmss000000:/# tcpdump port 53
18:01:22.312965 IP aks-nodepool1-16317344-vmss000000.internal.cloudapp.net.55916 > 168.63.129.16.domain: Flags [P.], seq 1:31, ack 1, win 502, options [nop,nop,TS val 1638839261 ecr 725819951], length 30 2541+ A? openai.com. (28)

# dig server response indicates tcp; otherwise, it says udp
dig +tcp openai.com
;; ANSWER SECTION:
openai.com.             36      IN      A       172.64.154.211
openai.com.             36      IN      A       104.18.33.45
;; Query time: 291 msec
;; SERVER: 168.63.129.16#53(168.63.129.16) (TCP)
```

> ## dns.k8s.coredns.plugin.hosts
- https://coredns.io/plugins/hosts/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#hosts-plugin

> ## dns.k8s.coredns.plugin.log
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#enable-dns-query-logging
- https://coredns.io/plugins/log/
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#are-dns-queries-being-received-processed: You can verify if queries are being received by CoreDNS by adding the log plugin to the CoreDNS configuration (aka Corefile).

> ## dns.k8s.InspektorGadget (ig)

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/logs/capture-system-insights-from-aks
- https://www.inspektor-gadget.io/docs/latest/core-concepts/architecture/
- https://www.inspektor-gadget.io/docs/latest/ig/: It uses eBPF as its underlying core technology
- https://github.com/inspektor-gadget/inspektor-gadget

> ### ig..gadgets

- https://inspektor-gadget.io/docs/latest/gadgets/
  
> ### ig.aks

```
# without install

root@aks-nodepool1-26220731-vmss000000:/# ig version

kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
root@aks-nodepool1-26220731-vmss000000:/# ig trace tcp -F dst.addr:93.184.216.34
RUNTIME.CONTAINERNAME    T PID        COMM          IP SRC                            DST
busybox                  C 326118     wget          4  10.244.0.21:44580              93.184.216.34:443

kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
root@aks-nodepool1-26220731-vmss000000:/# ig trace dns -F runtime.containerName:busybox
RUNTIME.CONTAINERNA… PID         TID         COMM       QR TYPE      QTYPE      NAME                RCODE      NUMA…
busybox              333551      333551      wget       Q  OUTGOING  A          www.example.com.de…            0
busybox              333551      333551      wget       R  HOST      A          www.example.com.de… NXDomain   0
busybox              333551      333551      wget       R  HOST      A          www.example.com.de… NXDomain   0
busybox              333551      333551      wget       Q  OUTGOING  AAAA       www.example.com.de…            0
busybox              333551      333551      wget       R  HOST      AAAA       www.example.com.de… NXDomain   0
busybox              333551      333551      wget       R  HOST      AAAA       www.example.com.de… NXDomain   0

kubectl run busybox --image=busybox --command -it --rm -- wget https://www.example.com
root@aks-nodepool1-26220731-vmss000000:/# ig trace tcpconnect --latency
RUNTIME.CONTAINERNAME PID         COMM        IP SRC                          DST                            LATENCY
busybox               346738      wget        4  10.244.0.29:52455            93.184.216.34:443           100.62682…
```

```
# install

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
kubectl exec -it nginx -- curl https://openai.com
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

> ## dns.k8s.pod.dnsconfig

```
kubectl delete po dns-example
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
  dnsPolicy: None
  dnsConfig:
    nameservers:
      - 168.63.129.16 # this is an example
  nodeSelector:
    kubernetes.io/hostname: aks-nodepool1-16317344-vmss000002
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

# separate nodes hosting coredns and app pod. below is for the node hosting the app pod, i.e., it does not query coredns
kubectl exec -it dns-example -- curl nvidia.com
root@aks-nodepool1-16317344-vmss000002:/# tcpdump port 53
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C18:22:35.531770 IP aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.52720 > 168.63.129.16.domain: 60990+ A? nvidia.com. (28)
18:22:35.531780 IP aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.52720 > 168.63.129.16.domain: 38960+ AAAA? nvidia.com. (28)
18:22:35.545528 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.52720: 60990 1/0/0 A 34.194.97.138 (44)
18:22:35.555285 IP aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.38248 > 168.63.129.16.domain: 23508+ PTR? 16.129.63.168.in-addr.arpa. (44)
18:22:35.563760 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.38248: 23508 NXDomain 0/1/0 (130)
18:22:35.563889 IP aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.41279 > 168.63.129.16.domain: 3671+ PTR? 6.0.224.10.in-addr.arpa. (41)
18:22:35.567184 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.41279: 3671 1/0/0 PTR aks-nodepool1-16317344-vmss000002.internal.cloudapp.net. (110)
18:22:35.567322 IP 168.63.129.16.domain > aks-nodepool1-16317344-vmss000002.internal.cloudapp.net.52720: 38960 0/1/0 (80)
```

- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-dns-config

> ## dns.k8s.pod.dnspolicy

> ## dns.k8s.service

- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#services
