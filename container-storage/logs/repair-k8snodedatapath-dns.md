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

> ## dns.k8s.coredns.plugin
- https://coredns.io/plugins/
- https://github.com/coredns/coredns/blob/master/plugin/cache/README.md: README for each plugin
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#plugin-support

> ## dns.k8s.coredns.configmap.custom

```
kubectl describe cm -n kube-system coredns-autoscaler # in a default cluster
```

- https://github.com/kubernetes-sigs/cluster-proportional-autoscaler#control-patterns-and-configmap-formats

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

> ## dns.coredns.plugin.header
- https://coredns.io/plugins/header/
- https://qasim-sarfraz.medium.com/dns-caching-gone-wrong-a329dc00452e

> ## dns.coredns.plugin.forward
- https://coredns.io/plugins/forward/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#custom-forward-server

> ## dns.coredns.plugin.hosts
- https://coredns.io/plugins/hosts/
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#hosts-plugin

> ## dns.coredns.plugin.log
- https://learn.microsoft.com/en-us/azure/aks/coredns-custom#enable-dns-query-logging
- https://coredns.io/plugins/log/
