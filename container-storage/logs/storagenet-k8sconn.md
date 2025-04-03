## conn


```
# See the section on iperf3, kube-proxy
# Refer to CNI - pod-to-pod traffic between nodes

# coredns
# https://learn.microsoft.com/en-us/azure/aks/coredns-custom#enable-dns-query-logging
kubectl exec -it nginx -- nslookup kubernetes.default.svc.cluster.local # if the issue is connectivity to the API server. Otherwise, try combinations of FQDNs and (CoreDNS IPs, Azure virtual IP, custom DNS server IP, or public DNS IP 8.8.8.8), and test from the node instead of the pod whenever possible
kubectl logs -n kube-system -l k8s-app=kube-dns # if "nslookup kubernetes.default.svc.cluster.local" fails

# netpol
kubectl get networkpolicy -A

# istio
kubectl get namespace default -o yaml # istio-injection: enabled, meaning each pod in the namespace has an Envoy proxy, which might be affecting access
kubectl logs nginx -c istio-proxy # istio proxy logs
kubectl get serviceentry # add host in a service entry for exclusion since outbound traffic is blocked by default
kubectl run nginx --image=nginx # test without Istio in a temporary pod in a non-Istio namespace or with sidecar.istio.io/inject:false as a pod label to override the namespace configuration. Also, test connectivity from a container like usual

# appgateway
## Here's the flow: Client -> Application Gateway -> Istio Ingress Service (Azure LB) -> Istio Ingress Pod -> Gateway and Virtual Service -> Backend Service -> Backend Pod
## To test the flow: Client (Azure VM in the same VNet as Azure LB) -> Istio Ingress Service (Azure LB) -> Istio Ingress Pod -> Gateway and Virtual Service -> Backend Service -> Backend Pod

```


```
# conn.node
# The configuration options may differ by VM size
```

```
syslog files
kubectl get nnc <node-name> -n kube-system -o yaml
/var/log/azure-vnet* (includes all logs starting with this prefix)
/var/run/azure-vnet.json
/var/run/azure-vnet-ipam.json
# the nnc YAML is applicable for node subnet scenario
# the azure-vnet files are applicable if using azure-cni
```

- https://github.com/sturrent/aks-node-outbound-check/blob/main/outbound-check.sh

```
# conn.node.interface

root@aks-nodepool1-24567707-vmss00000A:/# cat /etc/sysctl.d/999-sysctl-aks.conf
# This is a partial workaround to this upstream Kubernetes issue:
# https://github.com/kubernetes/kubernetes/issues/41916#issuecomment-312428731
net.ipv4.tcp_retries2=8
net.core.message_burst=80
net.core.message_cost=40
net.core.somaxconn=16384
net.ipv4.tcp_max_syn_backlog=16384
net.ipv4.neigh.default.gc_thresh1=4096
net.ipv4.neigh.default.gc_thresh2=8192
net.ipv4.neigh.default.gc_thresh3=16384
```
- https://learn.microsoft.com/en-us/azure/aks/custom-node-configuration?tabs=linux-node-pools#socket-and-network-tuning

```
# no data returned for the new B2ms node (it doesn't have accelerated networking)
# https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/bv1-series: Accelerated Networking is only supported for Standard_B12ms, Standard_B16ms and Standard_B20ms.
root@aks-nodepool1-24567707-vmss00000C:/# lspci

az aks nodepool add -g $rg --cluster-name aks -n npan -s Standard_B12ms -c 1
kubectl get no | grep npan
root@aks-npan-11337155-vmss000000:/# lspci
85f5:00:02.0 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5 Virtual Function] (rev 80)
```

```
# conn.node.interface.rx/tx (network interface)

# includes "dropped" packets
aks-nodepool1-24567707-vmss00000C:/# ip -s link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX:  bytes packets errors dropped  missed   mcast
         62426     597      0       0       0       0
    TX:  bytes packets errors dropped carrier collsns
         62426     597      0       0       0       0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DEFAULT group default qlen 1000
    link/ether 60:45:bd:e9:71:86 brd ff:ff:ff:ff:ff:ff
    RX:  bytes packets errors dropped  missed   mcast
     619636264  444808      0       1       0       0
    TX:  bytes packets errors dropped carrier collsns
       8829984   37648      0       0       0       0

root@aks-nodepool1-24567707-vmss00000B:/#  ethtool -g eth0
Ring parameters for eth0:
Pre-set maximums:
RX:             18139
RX Mini:        n/a
RX Jumbo:       n/a
TX:             2560
Current hardware settings:
RX:             9362
RX Mini:        n/a
RX Jumbo:       n/a
TX:             170
```

- https://www.24x7serversupport.com/blog/how-to-tuneup-tx-and-rx-buffers-on-network-interface/
- https://www.flamingbytes.com/blog/network-ring-buffer/#Increasing-the-RX-ring-buffer-to-reduce-a-high-packet-drop-rate

```
# conn.node.net.ipv4.tcp_keepalive_time
# See the section on tcp keep alive
```

- https://github.com/kubernetes/kubernetes/issues/41916#issuecomment-312428731: net.ipv4.tcp_keepalive_time

```
# conn.pod
# cat /etc/hosts
kind: Pod
spec:
  dnsConfig:
    nameservers:
    - 8.8.8.8
  dnsPolicy: None
```

```
# conn.vnet
az network vnet show
  "dhcpOptions": {
    "dnsServers": [
      "8.8.8.8",
      "8.8.4.4"
    ]
  },
```

## conn.apiserver

```
# kube-proxy must continuously communicate with the apiserver.
# For intermittent connectivity issues with the apiserver, in addition to a tcpdump of the client application, check kubectl logs for kube-proxy on that node and the apiserver konnectivity tunnel health during the issue time. If the issue is only seen in the tcpdump, it is likely a client library problem.
```

## conn.external

```
```
