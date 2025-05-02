```
layer 3 (tcp/udp):
./layer3 lb
./k8s svc lb
./private link (private cluster)

layer 7 (dns):
./dns zone

layer 7 (http/https):
./agc
./agic
```

> ## .traffic.k8s

```
# destination is within vnet
azure-cni: Pod > IP direto
kubenet: Pod > Node NAT (IP vNet) > IP (*no double outbound NAT since the destination is a private IP within the same vnet)
```

```
# lb

# client to LB to pod for kubenet and azure-cni during the initial TCP handshake
# O TCP handshake (SYN, SYN-ACK, ACK) é feito entre o cliente e o IP do Load Balancer (frontend IP).
[Client (Internet)]
   |
   |  TCP SYN para IP público (e.g. 20.45.123.10:443) [LB Frontend IP]
   |
[Azure Load Balancer (L4)]
   |
   |  Encaminha para IP privado do Node AKS (e.g. 10.240.0.4) [Backend Pool]
   |
[AKS Node (10.240.0.4)]
   |
   | kube-proxy gere regras iptables > iptables (DNAT para o pod IP)
   |
[Pod (10.240.1.18)]


# client to LB to pod for kubenet and azure-cni after the initial TCP handshake
[Client]
   |
   |  Pacotes TCP (ex: HTTP) > IP público (20.45.123.10:443) [LB Frontend IP]
   |
[Azure Load Balancer (L4)] (*the LB is not in use; it is mentioned here since the public (frontend) IP is associated with it)
   |
   |  Encaminha diretamente (*por sessão mantida)
   |
[AKS Node (10.240.0.4)]
   |
   |  Regras iptables redirecionam
   |
[Pod (10.240.1.18:443)]


# client (within vnet) to azure-cni pod (without LB) is using the pod IP
[Cliente (VM)]
  > [Diretamente para Pod (IP da vNet)]


# client (within vnet) to kubenet pod (without LB) is using the node IP
[Origem Interna (ex: VM na vNet)]
     |
[Não consegue comunicar com IP do pod diretamente]
     |
[Tem de comunicar com o IP do Node AKS ]
     |
[kube-proxy faz DNAT para o Pod]
     |
[Pod (IP interno não roteável)]

# layer 7 ingress controller in AKS without Application Gateway
[Client]
   > [LB]
     > [Node]
       > [Ingress Controller / Proxy (ex: NGINX) (L7)]
         > [Escolhe outro destino (ex: outro pod, outro IP)]
         
# lb supports UDP because its on layer 4
[Client]
   |
   |  UDP packet para IP público do Azure LB (porta 53, por ex.)
   |
[Azure Load Balancer (L4)]
   |
   | Encaminha para IP privado de um Node AKS
   |
[AKS Node]
   |
   | Regras iptables DNAT
   |
[Pod (ex: CoreDNS ou app UDP)]

# snat is only used for outbound, i.e., outbound snat
## azure-cni
[Pod (10.240.1.10)] > [Azure SNAT para IP Público do LB (20.45.123.10)] > [Internet]
## kubenet (double {outbound} snat)
[Pod (IP bridge NAT interno)]
   |
[NAT para IP do Node]
   |
[Azure LB SNAT para IP Público]
   |
[Internet]
```

```
# agic
# tcp handshake + tls, which involves the layer 4 and the beginning of layer 7
# the application gateway (AGIC) does not support UDP, meaning it cannot handle tls termination, routing, rewrites or WAF with UDP. It operates on layer 7, which is higher than tcp
[Client (Internet)]
   |
   |  TCP SYN > IP público do Application Gateway (ex: 20.45.123.10:443)
   |
[Application Gateway (AGIC - Layer 7)] (vNet)
   |
   |  Termina a conexão TLS (SSL offload ou passthrough)
   |
[Regras L7 (Host/Path Based Routing)]
   |
   |  Decide para qual Service/*Ingress ir
   |
[AKS Node (IP privado)]
   |
   |  Envia tráfego para o pod correto via ClusterIP ou diretamente
   |
[Pod (ex: 10.240.1.18)]

# http request, i.e., after the tcp handshake
[Client]
   |
   |  Envia HTTPS > IP público do Application Gateway (ex: 20.45.123.10:443)
   |
[Application Gateway] (vNet)
   |
   |  Decodifica pedido HTTP (L7)
   |  Aplica regras (ex: path-based routing, rewrite, redirect)
   |
azure-cni: [ClusterIP Service] > [Pod (IP da vNet)]
kubenet: [NodePort Service] > [Node (IP da vNet)] > [iptables (DNAT)] > [Pod (IP da bridge)]

# inbound snat
# the app gateway terminates tls and initiates a new conection with the pod, using the private IP of the app gateway as the origin IP
# X-Forwarded-For is used to preserve the original IP
## azure-cni
[Client]
   |
[App Gateway (L7)]
   |
[Pod (IP da vNet)]
## kubenet
[Client]
   |
[App Gateway]
   |
[AKS Node (vNet IP)]
   |
[NAT para Pod (bridge IP)]

# outbound snat from agic pod (itself) to internet e.g. to DNS, metrics, ARM API
azure-cni: Pod (IP vNet) > Azure LB SNAT > Internet
kubenet: Pod (bridge IP) > Node IP (NAT) > Azure LB SNAT > Internet
# outbound snat from application pod to internet
azure-cni: Pod (IP vNet) < AGIC > Pod > Azure LB SNAT > Internet
kubenet: Pod (bridge IP) < AGIC > Pod > Node NAT > Azure LB SNAT > Internet
```

```
# private link (private apiserver fqdn) (private cluster)
# services such as storage accounts are accessible via a private IP
Pod (Azure CNI ou Kubenet)
   > DNS resolve FQDN para IP privado (via Private DNS Zone)
   > Tráfego direto para IP privado do Private Link
   > Sem SNAT

# destination is internet
azure-cni: Pod > Azure LB SNAT
kubenet: Pod > Node SNAT (IP vNet)

# destination is within vnet
azure-cni: Pod > IP direto
kubenet: Pod > Node NAT (IP vNet) > IP (*no double outbound NAT since the destination is a private IP within the same vnet)

# destination is private link (private api server fqdn)
azure-cni: Pod > IP privado
kubenet: Pod > Node NAT (IP vNet) > IP
```

```
# problem with a component in aks. with commands
```

```
# tcp

# tcp error "Connection refused" - tcp rst sent immediately because no one is listening on the port, due to the service not running or kube-proxy/iptable issues
# tcp error "Connection reset by peer" - tcp rst sent by the destination, possibly due to service crash, firewall issues, or timeout
# tcp error "i/o timeout" - no tcp response and not a timeout, possibly due to network congestion, snat exhaustion, or firewall dropping packets

# tcp connection pooling
# reduce open tcp connections
.net: services.AddHttpClient
java (apache httpclient): new PoolingHttpClientConnectionManager
java (okhttp): OkHttpClient client = new OkHttpClient.Builder().connectionPool(new ConnectionPool(10, 5, TimeUnit.MINUTES)).build();
nginx (reverse proxy): upstream backend { server backend1.example.com; server backend2.example.com; keepalive 32; # keepalive specifies the number of open tcp connections to maintain
node.js (http client): const agent = new http.Agent..; http.request({ agent: agent # requires agent since no pooling by default
node.js (https client): const agent = new https.Agent
```

```
# hyper-v (host/vm)

# vfp (virtual filtering platform)
# symptom: communication breaks even though everything (pod, service, node) looks healthy
# symptom: pod ip responds to ping; however, no tcp handshake occurs due to failure in nat/snat in vfp
# symptom: open tcp connections without traffic due to acl or rule inconsistencies in vfp
# symptom: pod is Ready; however, there is no communication due to corrupt vfp rules
# mitigate: az aks nodepool restart
# mitigate: cordon + drain + recreate the node
Get-NetAdapter # see vfp adapters
Get-Service vfp # to see if it is functioning
Get-VMSwitch # to see rules
Get-VMSwitchExtension # to see "VFP Extension" is active
Get-VfpPolicy | Format-List # to see rules applied to the hyper-v switch
Get-VfpPort # to see port id for VfpPortRule
Get-VfpPortRule -PortId <PORT-ID> # to see rules for DNAT, SNAT, ACL are correct
Test-NetConnection <Pod-IP> -Port 443 # see open port
ping <Pod-IP> # validate connectivity
route print # analyze routes

# netvsp (NetVSP)
# part of the physical host stack, netvsc communicates with netvsp (sr-iov does not bypasses this stack)
ethtool -i eth0 # driver: hv_netvsc, then the communication is with netvsp
vm: refer to netvsc failures
ls /sys/class/net/: only has the virtual eth0. VF system interfaces like ens5f0 indicate sr-iov
ls /sys/class/net/eth0/device/driver: .../hv_netvsc # confirms the channel VMBus/NetVSP

# hvnetvsc (windows)
# network driver for the virtual interface (vNIC) in hyper-v
# dhcp/azure networking, heartbeat, time synchronization, and graceful shutdown
# mitigate: Disable-NetAdapter -Name "Ethernet" -Confirm:$false; Enable-NetAdapter -Name "Ethernet"
# mitigate: restart/reimage the node
vm: Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, ifIndex # InterfaceDescription=Microsoft Hyper-V Network Adapter, Status=Up
vm: Get-PnpDevice -FriendlyName "*Hyper-V*" | Where-Object { $_.Class -eq "Net" } # FriendlyName=Microsoft Hyper-V Network Adapter, Status=OK
vm: Get-WinEvent -LogName System | Where-Object {  $_.Message -like "*hvnetvsc*" -or $_.Message -like "*Hyper-V*Network*"  } | Select-Object TimeCreated, Id, Message | Sort-Object TimeCreated -Descending | Select-Object -First 10 # "hvnetvsc failed to initialize network interface", ""The network adapter encountered an internal error"
vm: Test-NetConnection google.com

# hv_netvsc (linux)
# linux kernel driver for the hyper-v virtual network via vmbus
# virtual network interface (eth0, etc.) communication with the azure sdn
# vm traffic: hv_netvsc (virtual driver) > vmbus > netvsp (hyper-v host) > azure sdn stack
# can be bypassed or dual-stack with sr-iov
# mitigate: sudo systemctl restart systemd-networkd
# mitigate: sudo ip link set eth0 down; sudo ip link set eth0 up # prefer systemctl restart
az vm show -g <rg> -n <vm-name> --query "networkProfile.networkInterfaces[].enableAcceleratedNetworking" # "false" uses hv_netvsc
vm: dmesg | grep -i hv_netvsc # "hv_netvsc vmbus_0_XX: device reset", "netvsc: device removed"
vm: ethtool -i eth0 # driver: hv_netvsc
vm: ip a / ping / nslookup # to see if the interface is functional
vm: ip a show eth0 # interface down, without inet ip, incorrect mtu (expected is 1500 or 1400, depending on overlay)
vm: iperf between VMs on different nodes: ~1–2 Gbps even if the vm size supports more
vm: journalctl -k -n 100 | grep -i netvsc # "hv_netvsc: device reported link down"
vm: lsmod | grep hv_netvsc # hv_netvsc             32768  0; netvsc                49152  1 hv_netvsc

# sr-iov (Single Root I/O Virtualization) (srvio)
# hardware virtualization technology that divides a single physical nic into virtual instances
# hardware + hypervisor, not in vm
# accelerated networking uses sr-iov
# vm traffic: physical vf (driver mlx5_core, ixgbevf, etc.) > bypass vmbus and netvsp > physical nic
az network nic show --ids <nic-id> --query "enableAcceleratedNetworking" # if AN is active, then sr-iov is active
vm: ethtool -i <interface> # driver: mlx5_core (AN is active) driver: hv_netvsc (without sr-iov)
vm: lsmod | grep hv_netvsc # if running and driver is mlx5_core, then dual-stack fallback (normal in azure)
vm: journalctl -u systemd-udevd | grep -i vf # virtual function (vf) messages indicate sr-iov is active. udevd managed devices in linux, including creation of VFs which are essential for sr-iov
vm: lspci | grep -i ethernet # "Ethernet controller: Mellanox", "Intel ... SR-IOV capable"

# vf (virtual function)
# a virtual mini-instance of a physical nic (pf - physical function), created with sr-iov that can be attributed to a vm, container or pod.
# ideal for hpc/ai/rt workloads due to low latency direct access to hardware
cat /sys/class/net/<vf-interface>/device/virtfn*/net/*/address # or ls -l /sys/class/net/<pf>/device/virtfn*/net/ # vf is not associated and is "dead" if net/ is empty
dmesg | grep -i vf # "mlx5_core: Failed to allocate VF", "vfio-pci: probe failed"
ethtool -S <vf-interface> | grep -i error # see tx_dropped, rx_errors
ethtool -i <vf-interface> # driver:mlx5_core, vf is not connected if bus-info is empty
grep 00:11:22:33:44:55 /var/lib/cni/sriov/* # to see the associated pod for this vf
host: echo 8 > /sys/class/net/<interface>/device/sriov_numvfs # to create 8 VFs
ip -d link show | grep -B1 vf # "vf 2 MAC 52:54:00:11:22:33, spoof checking on, link-state auto" # vf has associated mac, and link-state is not "disable"
journalctl -k | grep -i mlx
pod: cat /sys/class/net/net1/address # compare with mac in vm to see the associated vf for this pod

# accelerated networking (Azure)
# uses sr-iov with azure optimizations for lower latency (bypassing the network stack on host), higher bandwidth (~30 Gbps), less jitter, less cpu overhead
azure monitor: latency between nodes, high tcp retransmissions, network interface metrics
az vm list -g $noderg --query "[].{name:name, AN:networkProfile.networkInterfaceConfigurations[].enableAcceleratedNetworking}" -o table
az vm list-skus -l westus --all true --resource-type virtualMachines --query '[].{size:size, name:name, acceleratedNetworkingEnabled: capabilities[?name==`AcceleratedNetworkingEnabled`].value | [0]}' --output table # SKUs that support AN. https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview?tabs=redhat#supported-vm-instances
iperf or netperf, between VMs on different nodes: < 4-5 Gbps indicates AN is not active or is failing
kubectl get nodes -o wide # sku
## iperf
kubectl run iperf-server --image=networkstatic/iperf3 --port=5201 --command -- iperf3 -s
kubectl run iperf-client --image=networkstatic/iperf3 --command -- sleep 3600
kubectl exec -it iperf-client -- iperf3 -c iperf-server

# mellanox (mlx5_core)
# mellanox is a company that makes high performance NICs, such as ConnectX, and has been acquired by nvidia
# the mellanox kernel driver for NICs (ConnectX-4, 5, 6...) is mlx5_core 
# mlx5_core utilizes sr-iov, making it an accelerated networking driver
# vm traffic: vf (mlx5_core) > sr-iov i.e. bypasses netvsp
cat /sys/class/net/eth0/device/sriov_numvfs # if 0, then no VFs are active
cat /sys/class/net/eth0/device/sriov_totalvfs
dmesg | grep -i mlx5 # "mlx5_core: failed to activate port", "mlx5_core: firmware error"
ethtool -i eth0 # driver: mlx5_core i.e. VF Mellanox
ip link show dev eth0 # state DOWN or NO-CARRIER indicates a VF is assigned but inactive
journalctl -k | grep -i mlx5
kubectl get sriovnetworknodestates -n kube-system -o yaml # kind: SriovNetworkNodeState, spec.interfaces[0].name=eth0/driver=mlx5_core, status.syncStatus=Succeeded/lastSyncError=""
lspci | grep Mellanox # 05:00.0 Ethernet controller: Mellanox Technologies MT27800 Family [ConnectX-5]

# mana (microsoft azure network adapter)
# it is a microsoft network driver that interfaces with sr-iov to support AN in new generation azure VMs (ex: series Dasv5, Easv5, Dpsv5, etc.)
# replacement for mlx5_core (Mellanox) and hv_netvsc
# pod without connectivity indicates vf/mana is not initialized correctly
dmesg | grep -i mana # "mana: failed to initialize device" "RX queue allocation failed"
ethtool -S <interface> | grep -i 'drop\|err' # rx_errors, tx_errors, rx_dropped. high values indicate issue in vf/nic. 
ethtool -i <interface> # driver: mana. "link down" indicates sr-iov failure or binding
journalctl -k | grep -i mana
ls -l /sys/class/net/<interface>/device/physfn/virtfn*/ # verify vf is active
lspci -nnk | grep -A3 -i ethernet # "Ethernet controller [0200]: Microsoft Corporation Device 00XX (rev 01)". "Subsystem: Microsoft Corporation Device 0001". "Kernel driver in use: mana"
modinfo mana # "filename: /lib/modules/.../kernel/drivers/net/ethernet/microsoft/mana/mana.ko". "license: GPL". If this does not exist, then the kernel does not support mana, and can fallback to hv_netvsc

# fpga in azure
# part of SmartNICs and sdn stack
# accelerated load balancing, packet encryption, virtual network functions (vnf), offload of vxlan qos etc.
# invisible to VMs, unless for VMs with fpga: Standard_PB6s, https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/overview#fpga-accelerated

# SoC (system-on-chip) in azure
# in SmartNICs (with azure boost or earlier with fpga). There is also an SoC arm + fpga combination
# network acceleration, storage encryption, dns resolver local, cpu offload
# arm-based VMs (arm64): Standard_NP10s, Dplsv5
# invisible to VMs, ?except for arm64 ones?
# https://learn.microsoft.com/en-us/azure/azure-boost/overview#current-availability

# azure sdn (software defined network)
# vfp is the internal engine of azure sdn in the host
# symptom: pod has ip but no traffic (vfp/sdn); failed ping between IPs in the same subnet (vfp/sdn)
AzureDiagnostics | where Category == "NetworkSecurityGroupFlowEvent" | where FlowStatus_s == "D" | summarize count() by SourceIP_s, DestinationIP_s, L4Protocol_s, DestinationPort_s # real-time monitor drop in vpf
az network nic show --ids <nic-id> # nic associated with subnet/vnet with gateway/subnet ipConfigurations without duplicate privateIPAddress
az network watcher configure --resource-group <rg-name> --locations westeurope --enabled true
az network watcher connection-monitor create -g -n -l --source-resource <pod-nic-id> --dest-address <ip-ou-host> --protocol TCP # hop-by-hop diagnostic like tracepath. Check if traffic left the pod, was dropped in sdn, or issue is with external dns/gateway/etc.
az network watcher flow-log configure --nsg <nsg-name> --enabled true --retention 7 --storage-account <storage-name> --log-version 2 # nsg flow logs to see if traffic is being blocked by vfp based on nsg or internal rules
az network watcher test-connectivity --source-resource <vm-nic> --dest-address <dest-ip> --dest-port 443 # simulate traffic, works with pod NICs too
host: vfpctrl /list flows # state of vfp flows
kubectl get pod -o wide # to see az network nic for the ip
kubectl logs -n kube-system -l app=cns # "Added flow for pod IP: 10.244.1.5", "Programmed SNAT rule for endpoint ID xyz123"
nstat -az | grep Tcp # TcpRetransSegs, TcpExtTCPAbortOnTimeout
pod: curl http://169.254.169.254/metadata/instance?api-version=2021-02-01 -H Metadata:true
pod: ip route # see if the default route has a subnet ip "default via 10.x.x.1 dev eth0"
pod: ping <gateway> # ip route
```

```
# kernel (node)

# conntrack
cat /proc/net/nf_conntrack | wc -l # current number of entries
cat /proc/sys/net/netfilter/nf_conntrack_count # conntrack is full if this is equal to nf_conntrack_max
cat /proc/sys/net/netfilter/nf_conntrack_max # limit of number of entries
dmesg | grep -i connection # refer to the other dmesg
dmesg | grep conntrack # packet drops (conntrack failures). e.g. "nf_conntrack: table full, dropping packet", "ip_conntrack: table full"
kubectl get configmap kube-proxy -n kube-system -o yaml # "conntrack" config: maxPerCore, min (absolute), tcpEstablishedTimeout (time to keep TCP ESTABLISHED connection), tcpCloseWaitTimeout (timeout of CLOSE_WAIT connections)
metrics, Insights: ContainerLog | where LogEntry contains "connection reset" or LogEntry contains "connection refused"
metrics, Log analytics: Syslog | where Facility == "kern" and (Message contains "conntrack" or Message contains "connection")
metrics, Prometheus: 
sudo conntrack -L -p udp # udp conntrack burst indicates burst in dns traffic
sudo conntrack -L | grep FAIL # failed connections
sudo conntrack -S # stats. Elevated insert_failed or drop indicate conntrack table is full if entries=nf_conntrack_max
sudo netstat -nat | grep -i tcp # see if many in SYN_SENT, CLOSE_WAIT or TIME_WAIT indicating connections could have been closed sooner by client app
sudo sysctl -w net.netfilter.nf_conntrack_max=262144 # to see if temporary limit increase resolves issue (does not persist after reboot) (daemonset or add to /etc/sysctl.conf to persist after reboot)

# ip-masq-agent (snat)
# daemonset that controls when to masquerade (nat) traffic leaving the nodes to the internet. Only for snat, as it is used to modify the source ip in network packets
# not applicable for private IPs since these are not SNATed
curl # telnet # the destination must see the private ip of the pod and not the ip of the node
kubectl edit configmap ip-masq-agent -n kube-system # to include private endpoint, private link, and private dns zone IPs in nonMasqueradeCIDRs, as these are private IPs and do not require NAT. kubectl delete pod -n kube-system -l k8s-app=ip-masq-agent
kubectl get configmap ip-masq-agent -n kube-system -o yaml # traffic to nonMasqueradeCIDRs is not NATed (snat), has the virtual network range by default. 
kubectl get daemonset -n kube-system ip-masq-agent # NOT READY, CrashLoopBackOff
kubectl logs -n kube-system -l k8s-app=ip-masq-agent # "Failed to update iptables rules", "Unable to set masquerade rules", "invalid config", "error loading nonMasqueradeCIDRs"
kubectl run debug-pod --rm -i --tty --image=busybox -- sh # wget -O- https://ifconfig.me # Or curl ifconfig.me # must see node ip, not the private IP 10.x.x.x ou 192.168.x.x of the pod to confirm snat is fine
sudo iptables-save | grep MASQUERADE # -A POSTROUTING -s 10.244.0.0/16 ! -d 10.0.0.0/8 -j MASQUERADE i.e., masquerade (nat) if from this source cidr and not to this destination cidr
tcpdump -i eth0 src <pod_ip> and dst <private_endpoint_ip> # working without snat if traffic is seen. Similar in destination e.g., sql to see private ip of pod

# snat port exhaustion
# node ip has a pool of snat ports
# refer to conntrack for its exhaustion
# mitigate, azure: use nat gateway as each public ip supports ~64k snat ports
# mitigate, aks: az aks create --max-pods 30 # to reduce max pods
# mitigate, azure: use private endpoints or service endpoints since they are private IPs and do not require snat
# mitigate app: reduce TCP connections with connection pooling
# mitigate app: use aggressive connection timeouts to avoid leaving dead connections
kubectl get pods -A -o wide | grep 10.244.1.23 # to find the pod with the pod ip that's consuming max snat
metrics, Azure Monitor LB: Allocated SNAT Ports avg, Used SNAT Ports avg. # Property = Backend IP Address to identify the (node) ip
sudo conntrack -L -p tcp | grep -E "src=.* snat=" # src is IP of the pod, *snat has the ip of the node*, [ASSURED] is an established connection, repeat "sport" indicates port exhaustion
sudo conntrack -L -p tcp | grep -E "src=10\." # watch in real-time every 5 seconds # watch -n 5 'sudo conntrack -L -p tcp | grep -E "src=10\." | grep "snat=" | awk '\''{for(i=1;i<=NF;i++) if ($i ~ /^src=/) print $i}'\'' | cut -d= -f2 | sort | uniq -c | sort -nr'
sudo conntrack -L -p tcp | grep -E "src=10\." | grep "snat=" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^src=/) print $i}' | cut -d= -f2 | sort | uniq -c | sort -nr # to find the pod with the pod ip that's consuming most snat. Modify 10. to the pod ip range
sudo conntrack -L | grep "snat=10.0.1.100" | wc -l # replace with node/egress IP
sudo conntrack -L | grep ESTABLISHED # src is (SNATed) ip of the node for azure-cni/kubenet
sudo iptables -t nat -L -n -v # check "pkts" for target=MASQUERADE (snat) rules
sudo netstat -an | grep ESTABLISHED | wc -l # number of used ports
sysctl net.netfilter.nf_conntrack_max # refer to conntrack for nf_conntrack_max. Increase to mitigate snat exhaustion

# iptables / ipvs
# traffic routing of services (ClusterIP, NodePort, etc.), kernel snat (configured by ip-masq-agent) / kernel dnat (configured by kube-proxy), load balancing backend pods
# sudo iptables -t nat -L -n -v # target=DNAT, target=MASQUERADE (snat) # to identify snat or dnat
# refer to kube-proxy
curl http://nome-do-service.namespace.svc.cluster.local # curl service-name # *timeout/reset indicate iptable/kube-proxy issue. dns/nslookup works however http/tcp fail.
kubectl get endpoints # for services e.g. 10.244.2.14:8080 however curl fails
kubectl get no | wc -l # use ipvs if > 1000
kubectl get pods -n kube-system -l k8s-app=kube-proxy # CrashLoopBackOff, Error
kubectl logs -n kube-system -l k8s-app=kube-proxy # refer to kube-proxy
lsmod | grep ip_tables # to see if ip_tables module is loaded in the kernel
sudo iptables-save | grep KUBE # KUBE-NODEPORTS
sudo iptables-save | grep KUBE # KUBE-SERVICES. if no entry, then kube-proxy issue
sudo ipvsadm -L -n # only for IPVS # working e.g. TCP  10.0.0.1:443 rr -> 10.244.0.2:6443 Masq
## for example, iptables-save.KUBE-SERVICES, where KUBE-SEP-* are the backend pods
-A PREROUTING -j KUBE-SERVICES
  > -A KUBE-SERVICES -d 10.0.32.15/32 -p tcp -m tcp --dport 80 -j KUBE-SVC-XXXXX
    > -A KUBE-SVC-XXXXXXXX -m statistic --mode random --probability 0.5 -j KUBE-SEP-YYYYYYYY
      > -A KUBE-SVC-XXXXXXXX -j KUBE-SEP-ZZZZZZZZ
        > -A KUBE-SEP-YYYYYYYY -s 10.244.1.25/32 -j DNAT --to-destination 10.244.1.25:8080
## for example, ipvsadm -Ln, where rr stands for round-robin and Masq (kernel DNAT) is the forwarding mode
TCP  10.0.0.100:80 rr
  -> 10.244.1.25:8080 Masq 1 0 0
  -> 10.244.1.26:8080 Masq 1 0 0

# kube-proxy (dnat)
# refer to iptables/IPVS
# routing between pods and services (especially ClusterIP), dnat of service ip to pod ip
# also intermittent issue on random nodes
curl http://<IP-do-pod> # works
curl http://nome-do-service.namespace.svc.cluster.local # curl service-name # *timeout/reset indicates iptable/kube-proxy issue. dns/nslookup works but http/tcp fail.
kubectl delete pod -n kube-system -l k8s-app=kube-proxy # to recreate the rules
kubectl get configmap kube-proxy -n kube-system -o yaml # mode: "ipvs" # or "iptables"
kubectl get pods -n kube-system -l k8s-app=kube-proxy -o wide # Running, not CrashLoopBackOff
kubectl logs -n kube-system -l k8s-app=kube-proxy # "failed to sync proxy rules", "error setting up IPVS", "iptables-restore: invalid command", "conntrack failure"

# cni
cat /var/log/syslog | grep "failed to set up sandbox container network"
kubectl describe node <nome-do-node> | grep Allocatable -A5 # tbd - ip assignment of nodes
kubectl get events --sort-by='.lastTimestamp' # check pod events for ip exhaustion. pod state Pending with "Failed to assign IP".
kubectl get pods -o wide # view IPs and their corresponding subnet

# pod-to-pod azure-cni/kubenet dns
# kubenet: pod-to-pod traffic within the same node is not NATed as it uses the same cbr0 bridge. sudo tcpdump -i cbr0 host <IP_POD_1> and host <IP_POD_2>
# refer to iptables/kube-proxy for service
curl http://<IP-do-pod> # udr issue if kubenet
curl http://nome-do-pod.namespace.svc.cluster.local # Or nome-do-service
kubectl exec <pod-name> -- nslookup <service-name> # dns test
kubectl exec <pod-name> -- ping <service-name> # unless it's kubenet or ping is blocked by an nsg

# pod-to-pod azure-cni/kubenet network policy
# network policy is only for ingress/egress and applicable namespaces
# network policies are implemented in iptables for kubenet, azure-cni, or calico, typically as KUBE-NWPLCY-*, KUBE-FORWARD, KUBE-POD-FW-*
# network policies are implemented in ebpf for cilium
az network nsg rule list -g -n # udr or nsg
kubectl create networkpolicy # create one with all ingress and egress allowed and all podSelector for that *namespace* for test
kubectl describe pod <pod-name> # annotation for network policy
kubectl exec -it <pod-name> -- /bin/sh # curl http://<ip-ou-nome-do-service> # refer wget
kubectl exec -it <pod-name> -- /bin/sh # wget --spider nome-do-service.namespace.svc.cluster.local # http test. If "timeout" or "connection refused" and dns lookup is working, then it's a network policy issue.
kubectl get networkpolicy --A # issue with network policy if it works after removing or changing one
kubectl get networkpolicy -o yaml | grep -B 10 <nome-do-pod-ou-label>
kubectl get pods -o wide # pods and IPs
kubectl get svc -o wide # services (especially ClusterIP services) and IPs
kubectl logs -n kube-system -l k8s-app=calico-node
```

```
# container

# pod dns with dnsConfig / dnsPolicy
kubectl exec -n <namespace> <nome-do-pod> -- cat /etc/resolv.conf # nameserver 10.0.0.10 (kube-dns/coredns service ip), search domain default.svc.cluster.local svc.cluster.local cluster.local, option ndots:5
kubectl exec -n <namespace> <nome-do-pod> -- dig kubernetes.default.svc.cluster.local # refer nslookup
kubectl exec -n <namespace> <nome-do-pod> -- nslookup kubernetes.default # failure indicates dns config issues
kubectl get pod <nome-do-pod> -n <namespace> -o jsonpath='{.spec.dnsConfig.searches}' # to resolve private links, for example: privatelink.database.windows.net, privatelink.vaultcore.azure.net, privatelink.blob.core.windows.net
kubectl get pod <nome-do-pod> -n <namespace> -o jsonpath='{.spec.dnsConfig}'
kubectl get pod <nome-do-pod> -n <namespace> -o jsonpath='{.spec.dnsPolicy}' # ClusterFirst (default) - use /etc/resolv.conf of node to use kube-dns/coredns, None - use dnsConfig, ClusterFirstWithHostNet for pods with hostNetwork: true

# pod network with hostNetwork
# pod using node network and is not isolated in its own netns
kubectl exec -n <namespace> <nome-do-pod> -- cat /etc/resolv.conf # nameserver is vnet dns server for pod with hostNetwork. This also means the pod cannot use kube-dns/coredns and cannot resolves services
kubectl exec -n <namespace> <nome-do-pod> -- ip addr # refer to ip route
kubectl exec -n <namespace> <nome-do-pod> -- ip route # hostnetwork pod can see all physical interfaces of the node, not just veth
kubectl get pod <nome-do-pod> -n <namespace> -o jsonpath='{.spec.hostNetwork}' # true means it is using the host network, not veth
kubectl get pod <nome-do-pod> -n <namespace> -o wide # pod with hostNetwork has the same ip as the node. kubectl get node -o wide
sudo netstat -tulnp | grep :<porta> # hostnetwork pod uses port of node. For example, if it uses port 80, then other services like ingress controller or nginx cannot use these ports
sudo ss -tulnp | grep :<porta> # refer to sudo netstat -tulnp

# pod dns with azure dns (168.63.129.16) (where the pod does not use dnsConfig, dnsPolicy or hostNetwork)
# issue in pod, node or coredns
# mitigate: add private ip to /etc/hosts (Linux) or C:\Windows\System32\drivers\etc\hosts (Windows) to check if the issue only with dns
kubectl exec -n <namespace> <nome-do-pod> -- cat /etc/resolv.conf
kubectl exec -n <namespace> <nome-do-pod> -- curl http://<service>
kubectl exec -n <namespace> <nome-do-pod> -- dig kubernetes.default.svc.cluster.local # refer to nslookup
kubectl exec -n <namespace> <nome-do-pod> -- ip route
kubectl exec -n <namespace> <nome-do-pod> -- nc -vz 10.0.0.10 53 # if not connected, i.e., if timeout, then blocked due to network policy, kube-proxy/iptable
kubectl exec -n <namespace> <nome-do-pod> -- nslookup google.com # if it works, then the problem in the app
kubectl exec -n <namespace> <nome-do-pod> -- nslookup kubernetes.default # if it works, then the problem is in the app
kubectl exec -n <namespace> <nome-do-pod> -- telnet 10.0.0.10 53 # refer to nc
kubectl get networkpolicy -A # refer to network policy and see if policies block UDP 53 or TCP 53 between pods and kube-dns (coredns)
kubectl get pods -n kube-system -l k8s-app=kube-dns # Running
kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50 # SERVFAIL, NXDOMAIN, "upstream failure", "timeout"
kubectl run net-debugger --image=nicolaka/netshoot --restart=Never --command -- sleep infinity # See netshoot. To keep the pod running. kubectl exec -it net-debugger -- bash
kubectl run net-debugger --rm -i --tty --image=nicolaka/netshoot --restart=Never -- bash # debugger pod netshoot - dns (nslookup, dig, host), network (curl, wget, telnet, nc), packet capture (tcpdump), iptables routes interfaces (ip, ss, netstat). Exit will automatically delete the pod
sudo iptables -t filter -L -n -v | grep 53 # rule for dnat/forward to coredns
sudo iptables -t nat -L -n -v | grep 53 # rule for dnat/forward to coredns
tcpdump -i any port 53

# pod dns with external (custom) dns configured in a virtual network or coredns forwarder
# mitigate, pod: overwrite in /etc/resolv.conf
# mitigate, pod: use dnsPolicy:None, dnsConfig.nameservers (e.g., 1.1.1.1 and 8.8.8.8), dnsConfig.searches with mydomain.local as the search domain. Start with a test pod.
kubectl exec <pod-name> -- cat /etc/resolv.conf # nameserver is not 168.63.129.16 if using custom dns
kubectl exec <pod-name> -- dig @<custom-dns-ip> openai.com # refer nslookup
kubectl exec <pod-name> -- nc -vuz <custom-dns-ip> 53 # test udp. If it fails, it's a network/firewall/nsg/udr issue; check if dns traffic is allowed in a peered vnet 
kubectl exec <pod-name> -- nc -vz <custom-dns-ip> 53 # test tcp. see nc -vuz
kubectl exec <pod-name> -- nslookup openai.com <custom-dns-ip> # timeout or SERVFAIL indicates a problem with the external dns server
kubectl logs -n kube-system -l k8s-app=kube-dns # if coredns forwarder is being used; errors - SERVFAIL, upstream unreachable, timeout

# service externalTrafficPolicy
# for traffic from outside the cluster when it reaches the LoadBalancer or NodePort
# externalTrafficPolicy Cluster (default): reponds to external traffic on any node (snat)
# externalTrafficPolicy Local: responds only on the node where the pods exists (*without snat, client ip is preserved*)
# Applicable only for LoadBalancer or NodePort, not ClusterIP since it is not accessible outside the cluster
# If externalTrafficPolicy is set to Cluster, the receiving node NATs the traffic to the pod's node
# Applicable for all traffic including during the tcp handshake
# symptoms: the traffic reaches the node but no pod, client ip is not available and is required by the app, app health probe failures with externalTrafficPolicy Cluster
# mitigate: kubectl expose pod <nome-do-pod> --type=LoadBalancer --name=<nome-do-service> --internal-traffic-policy=Local
curl http://<node-ip>:<nodeport>/ # only the specific node will accept if externalTrafficPolicy is Local
kubectl exec -it <pod-name> -- tcpdump -i any port 80 # to verify external ip, and not the node ip i.e. without snat, is seen in the required port
kubectl get no | wc -l # use Local for large clusters with > 100 nodes
kubectl get nodes -o wide # vnet ip of the node
kubectl get pods -o wide -l app=<app-label> # check the nodes hosting the pods
kubectl get svc <service-name> -o jsonpath='{.spec.externalTrafficPolicy}' # Cluster, Local

# service internalTrafficPolicy
# for internal traffic within the cluster when the traffic reached the LoadBalancer or NodePort
# internalTrafficPolicy Cluster (default): pod can receive traffic from any cluster node. Used to balance internal cluster traffic between all pods in all nodes
# internalTrafficPolicy Local: only pods in the same node can receive internal traffic
# Applicable only for LoadBalancer or NodePort, not ClusterIP since this does not receive traffic from outside the cluster
# Applicable for all traffic, including during the tcp handshake
# symptoms: experiencing "timeout" due to no pod in that node and internalTrafficPolicy set to Local and even though dns resolves, InternalTrafficPolicy set to Cluster causes slow traffic per snat and traffic jumps between nodes
# mitigate: kubectl expose pod <nome-do-pod> --type=LoadBalancer --name=<nome-do-service> --external-traffic-policy=Local
kubectl debug node/<nome-node> -it --image=mcr.microsoft.com/dotnet/runtime-deps:6.0 # curl http://<service-cluster-ip>:<port> # can fail if internalTrafficPolicy: Local
kubectl get endpoints <nome-do-service> -o wide # lists pod IPs by node
kubectl get no | wc -l # use Local for large cluster with > 100 nodes
kubectl get pods -o wide -l app=<app-label> # pod distribution
kubectl get svc <nome-do-service> -o jsonpath='{.spec.internalTrafficPolicy}' # Cluster is the default value if it does not exist
kubectl logs -n kube-system -l k8s-app=kube-proxy # error "No available endpoints for service xyz" and internalTrafficPolicy: Local

```

```
# private

# private link (private cluster)
# Refer to the private dns zone if the dns server does not resolve to the private ip
# Refer to the private endpoint if you cannot connect to the private endpoint ip
az network nic show-effective-route-table -g -n # effective route is not through the virtual network but instead through the internet
az network nsg flow
az network nsg rule list -g -n # NSGs of client (subnet/VM) or private link must allow traffic
az network private-dns link vnet list -g --zone-name # virtual network is IsAutoRegistrationEnabled: true or Manual
az network private-endpoint-connection list --id <resource-id> # Approved, not Awaiting Approval
az network vnet subnet show -g --vnet-name -n # ip conflict, i.e., the private link ip is being used by another resource too
curl -v https://<your-service>.blob.core.windows.net --resolve <your-service>.blob.core.windows.net:<port>:<private_link_ip> # if this works, then the private link is working.
dig +short <serviço>.privatelink.<domain>.windows.net # same as nslookup
ipconfig /flushdns # flush dns in windows if dns or its records were updated
kubectl exec -it <pod-name> -- nslookup yourapp.privatelink.database.windows.net # pod/name must be able to resolve to the private IP
nc -vz yourapp.privatelink.database.windows.net 443 # tcp (https) error "Connection timed out" or "No route to host". Connection error or traffic does not reach the private link. Missing permissions or ACLs # or telnet
nslookup yourapp.privatelink.database.windows.net # normally the destination IP is a private IP 10.x.x.x or 172.x.x.x in a virtual network, not a public IP for example 20.x.x.x. If so, it is a private DNS issue # Or dig since it also shows the DNS server
openssl s_client -connect yourapp.privatelink.database.windows.net:443 # see CN and SAN # hostname resolves to private ip, but the SSL certificate is not as expected ("certificate verify failed" or "hostname mismatch")
sudo systemd-resolve --flush-caches # flush dns in linux if DNS or its records were updated
tcpdump -i any host <private_link_ip> # source ip is the node/pod ip, not the SNATed ip. SYN-ACK to confirm the issue is after SNAT
telnet <serviço>.privatelink.<domain>.windows.net 443 # same as nc

# private dns zone
# Refer to private link if there is an issue after resolving to a private ip
# Refer to private endpoint if you cannot connect to the private endpoint ip
az network private-dns record-set a list -g --zone-name # an A record is required, or else a lookup failure will occur
az network private-dns zone list-virtual-network-links -g --zone-name # resolution failure if the zone is not associated with the virtual network and to see if registrationEnabled: false
az network private-endpoint show -g -n --query customDnsConfigs # resolution failure if no private fqdn+ipAddresses
dig +short <serviço>.privatelink.<domain>.windows.net # same as nslookup
nslookup yourapp.privatelink.database.windows.net # typically, the destination IP is a private IP (10.x.x.x or 172.x.x.x) in a virtual network, not a public ip (e.g., 20.x.x.x), else it is a private DNS issue # Alternatively, use dig since it also shows the DNS server

# private endoint
# Refer to private dns to see if it can connect to the private endpoint IP
az network private-endpoint show -g -n --query "customDnsConfigs[].ipAddresses[]" -o tsv
az network private-endpoint show -g -n --query "{name:name, ipAddresses:customDnsConfigs[].ipAddresses[]}" -o table # verify if the PE exists as this shows the name and the private ip
nc -zv <private-endpoint-ip> 443 # if this tcp/https test is fine, the issue is with the private dns zone
telnet <private-endpoint-ip> 443 # same as nc
```
