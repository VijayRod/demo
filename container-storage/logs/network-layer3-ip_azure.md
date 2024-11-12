## ip.Azure.IpRanges

- https://www.azurespeed.com/Azure/IPLookup
- https://www.microsoft.com/en-us/download/details.aspx?id=56519: Azure IP Ranges and Service Tags – Public Cloud

## ip.Azure.IpRanges.Latency

- https://www.azurespeed.com/Azure/Latency

## ip.virtualPublicIp

```
azureVip="168.63.129.16"

aks-nodepool1-14217322-vmss000001   Ready    <none>   31h   v1.29.7   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1
wireshark ip.addr==168.63.129.16
324	10.224.0.5	168.63.129.16	TCP	80	48018 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=612374547 TSecr=0 WS=128
325	168.63.129.16	10.224.0.5	TCP	80	80 ? 48018 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=256 SACK_PERM TSval=1292316171 TSecr=612374547
326	10.224.0.5	168.63.129.16	TCP	72	48018 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=612374547 TSecr=1292316171
327	10.224.0.5	168.63.129.16	HTTP	273	GET /machine/?comp=goalstate HTTP/1.1 
328	168.63.129.16	10.224.0.5	HTTP/XML	2508	HTTP/1.1 200 OK 
329	10.224.0.5	168.63.129.16	TCP	72	48018 ? 80 [ACK] Seq=202 Ack=2438 Win=64128 Len=0 TSval=612374549 TSecr=1292316173
330	10.224.0.5	168.63.129.16	TCP	72	48018 ? 80 [FIN, ACK] Seq=202 Ack=2438 Win=64128 Len=0 TSval=612374549 TSecr=1292316173

327	10.224.0.5	168.63.129.16	HTTP	273	GET /machine/?comp=goalstate HTTP/1.1 
328	168.63.129.16	10.224.0.5	HTTP/XML	2508	HTTP/1.1 200 OK 

335	10.224.0.5	168.63.129.16	HTTP	532	GET /vmSettings HTTP/1.1 
336	168.63.129.16	10.224.0.5	HTTP	217	HTTP/1.1 304 Not Modified 

343	10.224.0.5	168.63.129.16	HTTP/JSON	662	PUT /status HTTP/1.1 , JSON (application/json)
345	168.63.129.16	10.224.0.5	HTTP	226	HTTP/1.1 200 OK 

350	10.224.0.5	168.63.129.16	HTTP/JSON	261	POST /HealthService HTTP/1.1 , JSON (application/json)
352	168.63.129.16	10.224.0.5	HTTP	222	HTTP/1.1 200 OK  (text/plain)

387	168.63.129.16	10.224.0.5	HTTP	253	GET /healthz HTTP/1.1 
388	10.224.0.5	168.63.129.16	HTTP/JSON	366	HTTP/1.1 200 OK , JSON (application/json)

1012	10.224.0.5	168.63.129.16	HTTP	273	GET /machine/?comp=goalstate HTTP/1.1 
1013	168.63.129.16	10.224.0.5	HTTP/XML	2508	HTTP/1.1 200 OK 
```

- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16
- https://microsoft.github.io/AzureTipsAndTricks/blog/tip242.html#what-is-ip-address-168-63-129-16

## ip.virtualPublicIp.wireserver

- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16: The VM Agent requires outbound communication over ports 80/tcp and 32526/tcp with WireServer (168.63.129.16).

## ip.virtualPublicIp.wireserver.aks

```
wireshark port==32526
aks-nodepool1-12914153-vmss000000:/# iptables -vnL
Chain FORWARD (policy ACCEPT 276 packets, 32187 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            168.63.129.16        tcp dpt:32526
```

- https://github.com/Azure/AKS/releases/tag/2024-08-27: For non-host network pods running on AKS nodes, they cannot access wireserver(168.63.129.16) port 32526. Before this change user cannot access wireserver port 80, but port 32526 is accessible.
- https://cloud.google.com/blog/topics/threat-intelligence/escalating-privileges-azure-kubernetes-services

## ip.virtualPublicIp.wireserver.VMAgent

- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux/linux-azure-guest-agent: Make sure the VM can connect to the Fabric Controller. Use a tool such as curl to test whether the VM can connect to 168.63.129.16 on ports 80, 443, and 32526.

## ip.IMDS

```
http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01&format=json
```
- https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=linux

## ip.IMDS.scheduledEvents

```
aks-nodepool1-14217322-vmss000001   Ready    <none>   31h   v1.29.7   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1
wireshark ip.addr==169.254.169.254
1997	10.224.0.5	169.254.169.254	TCP	80	44384 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=3347151662 TSecr=0 WS=128
1998	169.254.169.254	10.224.0.5	TCP	80	80 ? 44384 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=256 SACK_PERM TSval=1292333927 TSecr=3347151662
1999	10.224.0.5	169.254.169.254	TCP	72	44384 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=3347151663 TSecr=1292333927
2000	10.224.0.5	169.254.169.254	HTTP	213	GET /metadata/scheduledevents?api-version=2020-07-01 HTTP/1.1 
2001	169.254.169.254	10.224.0.5	HTTP/JSON	325	HTTP/1.1 200 OK , JSON (application/json)
2002	10.224.0.5	169.254.169.254	TCP	72	44384 ? 80 [ACK] Seq=142 Ack=254 Win=64128 Len=0 TSval=3347151671 TSecr=1292333933
2003	10.224.0.5	169.254.169.254	TCP	72	44384 ? 80 [FIN, ACK] Seq=142 Ack=254 Win=64128 Len=0 TSval=3347151671 TSecr=1292333933
2004	169.254.169.254	10.224.0.5	TCP	72	80 ? 44384 [FIN, ACK] Seq=254 Ack=143 Win=12583168 Len=0 TSval=1292333933 TSecr=3347151671
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/scheduled-events

## ip.lb.healthprobe

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-custom-probe-overview: Don't configure your virtual network with the Microsoft owned IP address range that contains 168.63.129.16. The configuration collides with the IP address of the health probe and can cause your scenario to fail.
  - For Azure Load Balancer's health probe to mark up your instance, you must allow 168.63.129.16 IP address in any Azure network security groups and local firewall policies. The AzureLoadBalancer service tag identifies this source IP address in your network security groups and permits health probe traffic by default.
  - All IPv4 Load Balancer health probes originate from the IP address 168.63.129.16 as their source. IPv6 probes use a link-local address (fe80::1234:5678:9abc) as their source.  
