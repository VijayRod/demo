## k8s-cni.azure

```
# See the section on container logs
# Refer to CNI - pod-to-pod traffic between nodes

akscal
cat /var/run/azure-vnet.json
cat /var/run/azure-vnet-ipam.json
cat /etc/cni/net.d/10-azure.conflist

akscal
ls /var/log/azure*
/var/log/azure-cnimonitor.log  /var/log/azure-vnet-telemetry.log
/var/log/azure-vnet-ipam.log   /var/log/azure-vnet.log
...
```

```
kubectl run nginx --image=nginx
kubectl get po nginx -owide
nginx   1/1     Running   0          4s    10.224.0.24   aks-nodepool1-59385832-vmss000000   <none>           <none>

aks-nodepool1-59385832-vmss000000:/# cat /var/run/azure-vnet.json
                                                        "ee86fb8b-eth0": {
                                                                "Id": "ee86fb8b-eth0",
                                                                "SandboxKey": "",
                                                                "IfName": "azvc440f4556932",
                                                                "HostIfName": "azvc440f455693",
                                                                "MacAddress": "umCZaqGD",
                                                                "InfraVnetIP": {
                                                                        "IP": "",
                                                                        "Mask": null
                                                                },
                                                                "LocalIP": "",
                                                                "IPAddresses": [
                                                                        {
                                                                                "IP": "10.224.0.24",
                                                                                "Mask": "//8AAA=="
                                                                        }
                                                                ],
                                                                "Gateways": [
                                                                        "0.0.0.0"
                                                                ],
                                                                "DNS": {
                                                                        "Suffix": "",
                                                                        "Servers": [
                                                                                "168.63.129.16"
                                                                        ],
                                                                        "Options": null
                                                                },
                                                                "Routes": [
                                                                        {
                                                                                "Dst": {
                                                                                        "IP": "0.0.0.0",
                                                                                        "Mask": "AAAAAA=="
                                                                                },
                                                                                "Src": "",
                                                                                "Gw": "10.224.0.1",
                                                                                "Protocol": 0,
                                                                                "DevName": "",
                                                                                "Scope": 0,
                                                                                "Priority": 0,
                                                                                "Table": 0
                                                                        }
                                                                ],
                                                                "VlanID": 0,
                                                                "EnableSnatOnHost": false,
                                                                "EnableInfraVnet": false,
                                                                "EnableMultitenancy": false,
                                                                "AllowInboundFromHostToNC": false,
                                                                "AllowInboundFromNCToHost": false,
                                                                "NetworkContainerID": "",
                                                                "NetworkNameSpace": "/var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78",
                                                                "ContainerID": "ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48",
                                                                "PODName": "nginx",
                                                                "PODNameSpace": "default"
                                                        }
                                                },
                                                
aks-nodepool1-59385832-vmss000000:/# cat /var/run/azure-vnet-ipam.json
                                                "Addresses": {...
                                                        "10.224.0.24": {
                                                                "ID": "ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48",
                                                                "Addr": "10.224.0.24",
                                                                "InUse": true
                                                        },

aks-nodepool1-59385832-vmss000000:/# ip addr
24: azvc440f455693@if23: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-1770aa7f-262a-c2ad-1c19-0a376d016a78
    inet6 fe80::a8aa:aaff:feaa:aaaa/64 scope link
       valid_lft forever preferred_lft forever

aks-nodepool1-59385832-vmss000000:/# ip netns | grep 0a376d016a78
cni-1770aa7f-262a-c2ad-1c19-0a376d016a78 (id: 2)
aks-nodepool1-59385832-vmss000000:/# ip netns pids cni-1770aa7f-262a-c2ad-1c19-0a376d016a78
11255
11303
11338
11339
aks-nodepool1-59385832-vmss000000:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
65535      11255  0.0  0.0    972     4 ?        Ss   09:46   0:00 /pause
root       11303  0.0  0.0  11404  7580 ?        Ss   09:46   0:00 nginx: master process nginx -g daemon off;
systemd+   11338  0.0  0.0  11868  2880 ?        S    09:46   0:00 nginx: worker process
systemd+   11339  0.0  0.0  11868  2880 ?        S    09:46   0:00 nginx: worker process
aks-nodepool1-59385832-vmss000000:/# nsenter -t 11303 -n ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
23: eth0@if24: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ba:60:99:6a:a1:83 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.224.0.24/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::b860:99ff:fe6a:a183/64 scope link
       valid_lft forever preferred_lft forever
aks-nodepool1-59385832-vmss000000:/# nsenter -t 11338 -n ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
23: eth0@if24: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ba:60:99:6a:a1:83 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.224.0.24/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::b860:99ff:fe6a:a183/64 scope link
       valid_lft forever preferred_lft forever
aks-nodepool1-59385832-vmss000000:/# apt update && apt install bridge-utils -y
aks-nodepool1-59385832-vmss000000:/# brctl show # No entries
aks-nodepool1-59385832-vmss000000:/# apt update && apt install net-tools -y
aks-nodepool1-59385832-vmss000000:/# route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.224.0.1      0.0.0.0         UG    100    0        0 eth0
10.224.0.0      0.0.0.0         255.255.0.0     U     100    0        0 eth0
10.224.0.1      0.0.0.0         255.255.255.255 UH    100    0        0 eth0
10.224.0.11     0.0.0.0         255.255.255.255 UH    0      0        0 azve4a902bcc56
...
10.224.0.24     0.0.0.0         255.255.255.255 UH    0      0        0 azvc440f455693
168.63.129.16   10.224.0.1      255.255.255.255 UGH   100    0        0 eth0
169.254.169.254 10.224.0.1      255.255.255.255 UGH   100    0        0 eth0

aks-nodepool1-59385832-vmss000000:/# crictl pods nginx
POD ID              CREATED             STATE               NAME                                  NAMESPACE  ATTEMPT             RUNTIME
ee86fb8be6198       13 hours ago        Ready               nginx                                 default  0                   (default)

# https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets: .1: Reserved by Azure for the default gateway.
# https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#can-i-ping-a-default-gateway-in-a-virtual-network: No.
az network vnet subnet show -g MC_rg_akscni_swedencentral --vnet-name aks-vnet-92427521 -n aks-subnet --query addressPrefix -otsv # 10.224.0.0/16
az network vnet show -g MC_rg_akscni_swedencentral -n aks-vnet-92427521 --query addressSpace.addressPrefixes[0] -otsv # 10.224.0.0/12

# tail /var/log/azure-vnet.log -f
aks-nodepool1-59385832-vmss000000:/# cat /var/log/azure-vnet.log | grep nginx
2024/08/28 09:46:32 [11185] CNI_COMMAND environment variable set to ADD
2024/08/28 09:46:32 [11185] Acquiring process lock
2024/08/28 09:46:32 [11185] Acquired process lock with timeout value of 10s
2024/08/28 09:46:32 [11185] Connected to telemetry service
2024/08/28 09:46:32 [11185] [cni-net] Plugin azure-vnet version v1.4.54.
2024/08/28 09:46:32 [11185] [cni-net] Running on Linux version 5.15.0-1070-azure (buildd@lcy02-amd64-090) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #79-Ubuntu SMP Mon Jul 29 20:31:47 UTC 2024
2024/08/28 09:46:32 [11185] [Azure-Utils] iptables --version
2024/08/28 09:46:32 [11185] [cni-net] iptable version:iptables v1.8.7 (nf_tables), err:<nil>
2024/08/28 09:46:32 [11185] [Azure-Utils] ebtables --version
2024/08/28 09:46:32 [11185] [cni-net] ebtable version ebtables 1.8.7 (nf_tables), err:<nil>
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:1 MTU:65536 Name:lo HardwareAddr: Flags:up|loopback|running} with IP: [127.0.0.1/8 ::1/128]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:2 MTU:1500 Name:eth0 HardwareAddr:60:45:bd:aa:55:f4 Flags:up|broadcast|multicast|running} with IP: [10.224.0.4/16 fe80::6245:bdff:feaa:55f4/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:4 MTU:1500 Name:azva9b7fca82c2 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:6 MTU:1500 Name:azve4a902bcc56 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:10 MTU:1500 Name:azv536c2b4e36c HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:12 MTU:1500 Name:azv3a72ef9b453 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:16 MTU:1500 Name:azvf3f10d1ed26 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:18 MTU:1500 Name:azv29b12d14278 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Network interface: {Index:20 MTU:1500 Name:azvfa363d217e9 HardwareAddr:aa:aa:aa:aa:aa:aa Flags:up|broadcast|multicast|running} with IP: [fe80::a8aa:aaff:feaa:aaaa/64]
2024/08/28 09:46:32 [11185] [net] Restored state
2024/08/28 09:46:32 [11185] Number of endpoints: 7
2024/08/28 09:46:32 [11185] [cni-net] Plugin started.
2024/08/28 09:46:32 [11185] [cni-net] Processing ADD command with args {ContainerID:ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48 Netns:/var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78 IfName:eth0 Args:K8S_POD_INFRA_CONTAINER_ID=ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48;K8S_POD_UID=51a5ca8e-4e46-451b-bbac-525543a80861;IgnoreUnknown=1;K8S_POD_NAMESPACE=default;K8S_POD_NAME=nginx Path:/opt/cni/bin StdinData:{"cniVersion":"0.3.0","ipam":{"type":"azure-vnet-ipam"},"ipsToRouteViaHost":["169.254.20.10"],"mode":"transparent","name":"azure","type":"azure-vnet"}}.
2024/08/28 09:46:32 [11185] [cni-net] Found network azure with subnet 10.224.0.0/16.
2024/08/28 09:46:32 [11185] [cni] Calling plugin azure-vnet-ipam ADD
2024/08/28 09:46:32 [11185] [cni] Plugin azure-vnet-ipam returned result:&{CNIVersion:1.0.0 Interfaces:[] IPs:[{Interface:<nil> Address:{IP:10.224.0.24 Mask:ffff0000} Gateway:10.224.0.1}] Routes:[{Dst:{IP:0.0.0.0 Mask:00000000} GW:10.224.0.1}] DNS:{Nameservers:[168.63.129.16] Domain: Search:[] Options:[]}}, err:<nil>.
2024/08/28 09:46:32 [11185] [cni-net] Creating endpoint Id:ee86fb8b-eth0 ContainerID:ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48 NetNsPath:/var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78 IfName:eth0 IfIndex:0 MacAddr: IPAddrs:[{10.224.0.24 ffff0000}] Gateways:[] Data:map[vethname:default.nginx].
2024/08/28 09:46:32 [11185] Generate veth name based on the key provided default.nginx
2024/08/28 09:46:32 [11185] Transparent client
2024/08/28 09:46:32 [11185] [net] Creating veth pair azvc440f455693 azvc440f4556932.
2024/08/28 09:46:32 [11185] [net] Setting link azvc440f455693 state up.
2024/08/28 09:46:32 [11185] [Azure-Utils] sysctl -w net.ipv6.conf.azvc440f455693.accept_ra=0
2024/08/28 09:46:32 [11185] Setting mtu 1500 on veth interface azvc440f455693
2024/08/28 09:46:32 [11185] [net] Adding route for the ip 10.224.0.24/32
2024/08/28 09:46:32 [11185] [net] Adding IP route {Dst:{IP:10.224.0.24 Mask:ffffffff} Src:<nil> Gw:<nil> Protocol:0 DevName: Scope:0 Priority:0 Table:0} to link azvc440f455693.
2024/08/28 09:46:32 [11185] calling setArpProxy for azvc440f455693
2024/08/28 09:46:32 [11185] [Azure-Utils] echo 1 > /proc/sys/net/ipv4/conf/azvc440f455693/proxy_arp
2024/08/28 09:46:32 [11185] [net] Opening netns /var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78.
2024/08/28 09:46:32 [11185] [net] Setting link azvc440f4556932 netns /var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78.
2024/08/28 09:46:32 [11185] [net] Entering netns /var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78.
2024/08/28 09:46:32 [11185] [net] Setting link azvc440f4556932 state down.
2024/08/28 09:46:32 [11185] [net] Setting link azvc440f4556932 name eth0.
2024/08/28 09:46:32 [11185] [Azure-Utils] sysctl -w net.ipv6.conf.eth0.accept_ra=0
2024/08/28 09:46:32 [11185] [net] Setting link eth0 state up.
2024/08/28 09:46:32 [11185] [net] Adding IP address 10.224.0.24/16 to link eth0.
2024/08/28 09:46:32 [11185] [net] Deleting IP route {Dst:{IP:10.224.0.0 Mask:ffff0000} Src:<nil> Gw:<nil> Protocol:2 DevName: Scope:253 Priority:0 Table:0} from link eth0.
2024/08/28 09:46:32 [11185] [net] Adding IP route {Dst:{IP:169.254.1.1 Mask:ffffffff} Src:<nil> Gw:<nil> Protocol:0 DevName: Scope:253 Priority:0 Table:0} to link eth0.
2024/08/28 09:46:32 [11185] [net] Adding IP route {Dst:{IP:0.0.0.0 Mask:00000000} Src:<nil> Gw:169.254.1.1 Protocol:0 DevName: Scope:0 Priority:0 Table:0} to link eth0.
2024/08/28 09:46:32 [11185] [net] Adding static arp for IP address 169.254.1.1/32 and MAC aa:aa:aa:aa:aa:aa in Container namespace
2024/08/28 09:46:32 [11185] [net] Exiting netns /var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78.
2024/08/28 09:46:32 [11185] [net] Created endpoint &{Id:ee86fb8b-eth0 HnsId: SandboxKey: IfName:azvc440f4556932 HostIfName:azvc440f455693 MacAddress:ba:60:99:6a:a1:83 InfraVnetIP:{IP:<nil> Mask:<nil>} LocalIP: IPAddresses:[{IP:10.224.0.24 Mask:ffff0000}] Gateways:[0.0.0.0] DNS:{Suffix: Servers:[168.63.129.16] Options:[]} Routes:[{Dst:{IP:0.0.0.0 Mask:00000000} Src:<nil> Gw:10.224.0.1 Protocol:0 DevName: Scope:0 Priority:0 Table:0}] VlanID:0 EnableSnatOnHost:false EnableInfraVnet:false EnableMultitenancy:false AllowInboundFromHostToNC:false AllowInboundFromNCToHost:false NetworkContainerID: NetworkNameSpace:/var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78 ContainerID:ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48 PODName:nginx PODNameSpace:default InfraVnetAddressSpace: NetNs:}.
2024/08/28 09:46:32 [11185] [net] Save succeeded.
2024/08/28 09:46:32 [11185] [cni-net] ADD command completed for pod nginx with IPs:[{Interface:<nil> Address:{IP:10.224.0.24 Mask:ffff0000} Gateway:10.224.0.1}] err:<nil>.
2024/08/28 09:46:32 [11185] [cni-net] Plugin stopped.
2024/08/28 09:46:32 [11185] Released process lock

aks-nodepool1-59385832-vmss000000:/# cat /var/log/azure-vnet-ipam.log | grep :32
2024/08/28 09:46:32 [11202] Acquiring process lock
2024/08/28 09:46:32 [11202] Acquired process lock with timeout value of 10s
2024/08/28 09:46:32 [11202] [cni-ipam] Plugin azure-vnet-ipam version v1.4.54.
2024/08/28 09:46:32 [11202] [cni-ipam] Running on Linux version 5.15.0-1070-azure (buildd@lcy02-amd64-090) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #79-Ubuntu SMP Mon Jul 29 20:31:47 UTC 2024
2024/08/28 09:46:32 [11202] [ipam] Restored state, &{Version:v1.4.54 TimeStamp:2024-08-28 09:46:27.150423134 +0000 UTC AddrSpaces:map[local:0xc000390540] store:0xc0003cca80 source:<nil> netApi:<nil> Mutex:{state:0 sema:0}}
2024/08/28 09:46:32 [11202] [cni-ipam] Plugin started.
2024/08/28 09:46:32 [11202] [cni-ipam] Processing ADD command with args {ContainerID:ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48 Netns:/var/run/netns/cni-1770aa7f-262a-c2ad-1c19-0a376d016a78 IfName:eth0 Args:K8S_POD_INFRA_CONTAINER_ID=ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48;K8S_POD_UID=51a5ca8e-4e46-451b-bbac-525543a80861;IgnoreUnknown=1;K8S_POD_NAMESPACE=default;K8S_POD_NAME=nginx Path:/opt/cni/bin StdinData:{"cniVersion":"0.3.0","name":"azure","type":"azure-vnet","mode":"transparent","ipsToRouteViaHost":["169.254.20.10"],"ipam":{"type":"azure-vnet-ipam","subnet":"10.224.0.0/16"},"dns":{},"runtimeConfig":{"dns":{}},"windowsSettings":{}}}.
2024/08/28 09:46:32 [11202] [cni-ipam] Read network configuration &{CNIVersion:0.3.0 Name:azure Type:azure-vnet Mode:transparent Master: AdapterName: Bridge: LogLevel: LogTarget: InfraVnetAddressSpace: IPV6Mode: ServiceCidrs: VnetCidrs: PodNamespaceForDualNetwork:[] IPsToRouteViaHost:[169.254.20.10] MultiTenancy:false EnableSnatOnHost:false EnableExactMatchForPodName:false DisableHairpinOnHostInterface:false DisableIPTableLock:false CNSUrl: ExecutionMode: IPAM:{Mode: Type:azure-vnet-ipam Environment: AddrSpace: Subnet:10.224.0.0/16 Address: QueryInterval:} DNS:{Nameservers:[] Domain: Search:[] Options:[]} RuntimeConfig:{PortMappings:[] DNS:{Servers:[] Searches:[] Options:[]}} WindowsSettings:{EnableLoopbackDSR:false HnsTimeoutDurationInSeconds:0} AdditionalArgs:[]}.
2024/08/28 09:46:32 [11202] [ipam] Starting source azure.
2024/08/28 09:46:32 [11202] [ipam] Refreshing address source.
2024/08/28 09:46:32 [11202] [Utils] Initializing HTTP client with connection timeout: 10, response header timeout: 10
2024/08/28 09:46:32 [11202] [ipam] Wireserver call http://168.63.129.16/machine/plugins?comp=nmagent&type=getinterfaceinfov1 to retrieve IP List
2024/08/28 09:46:32 [11202] [ipam] got 28 addresses from interface eth0, subnet 10.224.0.0/16
2024/08/28 09:46:32 [11202] [ipam] merging address space
2024/08/28 09:46:32 [11202] [ipam] saving ipam state.
2024/08/28 09:46:32 [11202] [ipam] Save succeeded.
2024/08/28 09:46:32 [11202] [ipam] Requesting address with address: options:map[azure.address.id:ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48].
2024/08/28 09:46:32 [11202] [ipam] Address request completed with address:10.224.0.24/16
2024/08/28 09:46:32 [11202] [ipam] saving ipam state.
2024/08/28 09:46:32 [11202] [ipam] Save succeeded.
2024/08/28 09:46:32 [11202] [cni-ipam] Allocated address 10.224.0.24/16.
2024/08/28 09:46:32 [11202] [cni-ipam] ADD command completed with result:&{CNIVersion:1.0.0 Interfaces:[] IPs:[{Interface:<nil> Address:{IP:10.224.0.24 Mask:ffff0000} Gateway:10.224.0.1}] Routes:[{Dst:{IP:0.0.0.0 Mask:00000000} GW:10.224.0.1}] DNS:{Nameservers:[168.63.129.16] Domain: Search:[] Options:[]}} err:<nil>.
2024/08/28 09:46:32 [11202] [cni-ipam] Plugin stopped.
2024/08/28 09:46:32 [11202] Released process lock

aks-nodepool1-59385832-vmss000000:/# cat /var/log/syslog | grep ee86fb8b
Aug 28 09:46:32 aks-nodepool1-59385832-vmss000000 systemd[1]: Started libcontainer container ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48.
Aug 28 09:46:32 aks-nodepool1-59385832-vmss000000 containerd[2707]: time="2024-08-28T09:46:32.480291720Z" level=info msg="RunPodSandbox for &PodSandboxMetadata{Name:nginx,Uid:51a5ca8e-4e46-451b-bbac-525543a80861,Namespace:default,Attempt:0,} returns sandbox id \"ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48\""
Aug 28 09:46:33 aks-nodepool1-59385832-vmss000000 kubelet[2955]: I0828 09:46:33.422286    2955 kubelet.go:2455] "SyncLoop (PLEG): event for pod" pod="default/nginx" event={"ID":"51a5ca8e-4e46-451b-bbac-525543a80861","Type":"ContainerStarted","Data":"ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48"}
Aug 28 09:46:33 aks-nodepool1-59385832-vmss000000 containerd[2707]: time="2024-08-28T09:46:33.498392207Z" level=info msg="CreateContainer within sandbox \"ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48\" for container &ContainerMetadata{Name:nginx,Attempt:0,}"
Aug 28 09:46:33 aks-nodepool1-59385832-vmss000000 containerd[2707]: time="2024-08-28T09:46:33.527441738Z" level=info msg="CreateContainer within sandbox \"ee86fb8be61987b83e1da1338b09fc0a83dcd12f9754455e668b16dc98f20f48\" for &ContainerMetadata{Name:nginx,Attempt:0,} returns container id \"82d037df98acb953a319e50419b1da7079d9ba9159c6d25e58b79db8d86e4e2c\""

aks-nodepool1-59385832-vmss000000:/# cat /var/log/pods/default_nginx_51a5ca8e-4e46-451b-bbac-525543a80861/nginx/0.log
2024-08-28T09:46:33.571288084Z stdout F /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
aks-nodepool1-59385832-vmss000000:/# cat /var/log/containers/nginx_default_nginx-82d037df98acb953a319e50419b1da7079d9ba9159c6d25e58b79db8d86e4e2c.log
2024-08-28T09:46:33.571288084Z stdout F /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
# kubectl logs nginx --timestamps=true
2024-08-28T09:46:33.571288084Z /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
```

```
kubectl delete svc nginx
kubectl expose po nginx --port=8080
kubectl get svc nginx
nginx   ClusterIP   10.0.48.181   <none>        8080/TCP   4s
# No related entries in the azure-vnet.json, azure-vnet-ipam.json, 10-azure.conflist files. None in azure-vnet.log and azure-vnet-ipam.log too.

kubectl delete svc nginx
kubectl expose po nginx --port=8080 --type=NodePort
kubectl get svc nginx
nginx   NodePort   10.0.205.154   <none>        8080:30117/TCP   0s
# No related entries in the azure-vnet.json, azure-vnet-ipam.json, 10-azure.conflist files.

kubectl delete svc nginx
kubectl expose po nginx --port=8080 --type=LoadBalancer
kubectl get svc nginx
nginx   LoadBalancer   10.0.30.15   74.241.215.95   8080:31350/TCP   14s
# No related entries in the azure-vnet.json, azure-vnet-ipam.json, 10-azure.conflist files.

kubectl get no -owide
aks-nodepool1-59385832-vmss000000   Ready    <none>   11h   v1.29.7   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1070-azure   containerd://1.7.20-1
# No related entries in the azure-vnet.json, azure-vnet-ipam.json, 10-azure.conflist files.

# kubectl get no -owide
aks-nodepool1-59385832-vmss000000   Ready    <none>   12h   v1.29.7   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1070-azure   containerd://1.7.20-1
# kubectl get po -n kube-system -owide | grep 0.4
azure-ip-masq-agent-m7wjf             1/1     Running   0          12h   10.224.0.4    aks-nodepool1-59385832-vmss000000   <none>           <none>
cloud-node-manager-lnjkj              1/1     Running   0          12h   10.224.0.4    aks-nodepool1-59385832-vmss000000   <none>           <none>
csi-azuredisk-node-r59p5              3/3     Running   0          12h   10.224.0.4    aks-nodepool1-59385832-vmss000000   <none>           <none>
csi-azurefile-node-hwb24              3/3     Running   0          12h   10.224.0.4    aks-nodepool1-59385832-vmss000000   <none>           <none>
kube-proxy-qdfmq                      1/1     Running   0          12h   10.224.0.4    aks-nodepool1-59385832-vmss000000   <none>           <none>
# No related entries in the azure-vnet.json, azure-vnet-ipam.json, 10-azure.conflist files.
```

- https://github.com/Azure/azure-container-networking
- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overview
- https://learn.microsoft.com/en-us/azure/aks/concepts-network#azure-cni-advanced-networking
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-kubernetes-service-limits: Maximum pods per node: with Azure Container Networking Interface
- https://learn.microsoft.com/en-us/azure/virtual-network/container-networking-overview
- https://stevegriffith.nyc/posts/aks-networking-part2/
- https://azuregulfblog.wordpress.com/wp-content/uploads/2019/04/aks_basicnetwork_technicalpaper.pdf
- https://blog.teknews.cloud/aks/network/2023/11/02/AKS_Networking-considerationspart2.html
- https://blog.cloudtrooper.net/2019/01/23/a-day-in-the-life-of-a-packet-in-aks-part-2-kubenet-and-ingress-controller/

## k8s-cni.azure..networkProfile

```
az aks create -g $rg -n akscni --network-plugin azure -s $vmsize -c 2
az aks show -g $rg -n akscni --query networkProfile
az aks get-credentials -g $rg -n akscni
kubectl get no

  "networkProfile": {
    "advancedNetworking": null,
    "dnsServiceIp": "10.0.0.10",
    "networkDataplane": "azure",
    "networkMode": null,
    "networkPlugin": "azure",
    "networkPluginMode": null,
    "podCidr": null,
    "podCidrs": null,
    "podLinkLocalAccess": "IMDS",
    "serviceCidr": "10.0.0.0/16",
    "serviceCidrs": [
      "10.0.0.0/16"
    
aks-nodepool1-33042731-vmss000000:/# cat /etc/cni/net.d/10-azure.conflist
{
   "cniVersion":"0.3.0",
   "name":"azure",
   "plugins":[
      {
         "type":"azure-vnet",
         "mode":"transparent",
         "ipsToRouteViaHost":["169.254.20.10"],
         "ipam":{
            "type":"azure-vnet-ipam"
         }
      },
      {
         "type":"portmap",
         "capabilities":{
            "portMappings":true
         },
         "snat":true
      }
   ]
}

aks-nodepool1-33042731-vmss000000:/# cat /var/run/azure-vnet.json
{
        "Network": {
                "Version": "v1.4.54",
                "TimeStamp": "2024-09-11T02:34:43.990795913Z",
                "ExternalInterfaces": {
                        "eth0": {
                                "Name": "eth0",
                                "Networks": {
                                        "azure": {
                                                "Id": "azure",
                                                "Mode": "transparent",
                                                "VlanId": 0,
                                                "Subnets": [
                                                        {
                                                                "Family": 2,
                                                                "Prefix": {
                                                                        "IP": "10.224.0.0",
                                                                        "Mask": "//8AAA=="
                                                                },
                                                                "Gateway": "10.224.0.1",
                                                                "PrimaryIP": ""
                                                        }
                                                ],
                                                "Endpoints": {
                                                ...
                                                },
                                                "DNS": {
                                                        "Suffix": "",
                                                        "Servers": [
                                                                "168.63.129.16"
                                                        ],
                                                        "Options": null
                                                },
                                                "EnableSnatOnHost": false,
                                                "NetNs": "",
                                                "SnatBridgeIP": ""
                                        }
                                },
                                "Subnets": [
                                        "10.224.0.0/16"
                                ],
                                "BridgeName": "",
                                "DNSInfo": {
                                        "Suffix": "",
                                        "Servers": null,
                                        "Options": null
                                },
                                "MacAddress": "fB5SHQuv",
                                "IPAddresses": null,
                                "Routes": null,
                                "IPv4Gateway": "0.0.0.0",
                                "IPv6Gateway": "::"
                        }
                }
        }
```

```
az aks create -g $rg -n akscnioverlay --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16 -s $vmsize -c 2
az aks show -g $rg -n akscnioverlay --query networkProfile
az aks get-credentials -g $rg -n akscnioverlay
kubectl get no

  "advancedNetworking": null,
  "dnsServiceIp": "10.0.0.10",
  "networkDataplane": "azure",
  "networkMode": null,
  "networkPlugin": "azure",
  "networkPluginMode": "overlay",
  "podCidr": "192.168.0.0/16",
  "podCidrs": [
    "192.168.0.0/16"
  ],
  "podLinkLocalAccess": "IMDS",
  "serviceCidr": "10.0.0.0/16",
  "serviceCidrs": [
    "10.0.0.0/16"
    
aks-nodepool1-30840492-vmss000000:/# cat /etc/cni/net.d/15-azure-swift-overlay.conflist
{
        "cniVersion": "0.3.0",
        "name": "azure",
        "plugins": [
                {
                        "type": "azure-vnet",
                        "mode": "transparent",
                        "ipsToRouteViaHost": [
                                "169.254.20.10"
                        ],
                        "executionMode": "v4swift",
                        "ipam": {
                                "mode": "v4overlay",
                                "type": "azure-cns"
                        },
                        "dns": {},
                        "runtimeConfig": {
                                "dns": {}
                        },
                        "windowsSettings": {}
                },
                {
                        "type": "portmap",
                        "capabilities": {
                                "portMappings": true
                        },
                        "snat": true
                }
        ]
}

aks-nodepool1-30840492-vmss000000:/# cat /var/run/azure-vnet.json
{
        "Network": {
                "CnsClient": null,
                "Version": "linux-amd64-v1.5.32",
                "TimeStamp": "2024-09-16T18:24:22.253826851Z",
                "ExternalInterfaces": {
                        "eth0": {
                                "Name": "eth0",
                                "Networks": {
                                        "azure": {
                                                "Id": "azure",
                                                "Mode": "transparent",
                                                "VlanId": 0,
                                                "Subnets": [
                                                        {
                                                                "Family": 2,
                                                                "Prefix": {
                                                                        "IP": "192.168.0.0",
                                                                        "Mask": "//8AAA=="
                                                                },
                                                                "Gateway": "169.254.1.1",
                                                                "PrimaryIP": ""
                                                        }
                                                ],
                                                "Endpoints": {
                                                ...
                                                },
                                                "DNS": {
                                                        "Suffix": "",
                                                        "Servers": null,
                                                        "Options": null
                                                },
                                                "EnableSnatOnHost": false,
                                                "NetNs": "",
                                                "SnatBridgeIP": ""
                                        }
                                },
                                "Subnets": [
                                        "10.224.0.0/16"
                                ],
                                "BridgeName": "",
                                "DNSInfo": {
                                        "Suffix": "",
                                        "Servers": null,
                                        "Options": null
                                },
                                "MacAddress": "YEW9/a1H",
                                "IPAddresses": null,
                                "Routes": null,
                                "IPv4Gateway": "0.0.0.0",
                                "IPv6Gateway": "::"
                        }
                }
        }
        
kubectl get po -n kube-system -l k8s-app=azure-cns
NAME              READY   STATUS    RESTARTS   AGE
azure-cns-dfs7g   1/1     Running   0          19m
azure-cns-jcvsb   1/1     Running   0          19m
azure-cns-vfg4p   1/1     Running   0          19m

kubectl logs -n kube-system -l k8s-app=azure-cns
Defaulted container "cns-container" out of: cns-container, cni-installer (init)
Defaulted container "cns-container" out of: cns-container, cni-installer (init)
Defaulted container "cns-container" out of: cns-container, cni-installer (init)
2024/09/16 18:23:00 [1] [updateIPConfigState] Changing IpId [192.168.2.153] state to [Assigned], podInfo [InfraContainerID: [5d6d55498cd4a6b26a916da350844a88e120131e0fe6619b15f7e6997118bf0f], InterfaceID: [5d6d5549-eth0], Key: [5d6d5549-eth0], Name: [coredns-597bb9d4db-l9xps], Namespace: [kube-system]]. Current config [ID: [192.168.2.153], NCID: [f8ba6027-16ef-4116-95f2-923bbe9abaf1], IPAddress: [192.168.2.153], State: [Available], LastStateTransition: [2024-09-16T11:22:56Z] PodInfo: [%!s(<nil>)]]

kubectl run nginx --image=nginx
kubectl logs -n kube-system -l k8s-app=azure-cns
2024/09/16 18:43:19 [1] [azure-cnsrequestIPConfigsHandler] Received cns.IPConfigsRequest {DesiredIPAddresses:[] PodInterfaceID:70513325-eth0 InfraContainerID:7051332514dcd314f5e2e611a9fef059471e15980badffd953b1772a63166f9c OrchestratorContext:[123 34 80 111 100 78 97 109 101 34 58 34 110 103 105 110 120 34 44 34 80 111 100 78 97 109 101 115 112 97 99 101 34 58 34 100 101 102 97 117 108 116 34 125] Ifname: SecondaryInterfacesExist:false}.
2024/09/16 18:43:19 [1] [GetExistingIPConfig] IPConfigExists [false] for pod [70513325-eth0]
2024/09/16 18:43:19 [1] [updateIPConfigState] Changing IpId [192.168.1.47] state to [Assigned], podInfo [InfraContainerID: [7051332514dcd314f5e2e611a9fef059471e15980badffd953b1772a63166f9c], InterfaceID: [70513325-eth0], Key: [70513325-eth0], Name: [nginx], Namespace: [default]]. Current config [ID: [192.168.1.47], NCID: [4b663566-aa09-4a6f-98d1-353bd5d25d4a], IPAddress: [192.168.1.47], State: [Available], LastStateTransition: [2024-09-16T18:22:58Z] PodInfo: [%!s(<nil>)]]
2024/09/16 18:43:19 [1] IP config 70513325-eth0 initialized
2024/09/16 18:43:19 [1] [AssignDesiredIPConfigs] Successfully assigned IPs for pod InfraContainerID: [7051332514dcd314f5e2e611a9fef059471e15980badffd953b1772a63166f9c], InterfaceID: [70513325-eth0], Key: [70513325-eth0], Name: [nginx], Namespace: [default]
2024/09/16 18:43:19 [1] [azure-cnsrequestIPConfigsHandler] Sent cns.IPConfigsRequest {DesiredIPAddresses:[] PodInterfaceID:70513325-eth0 InfraContainerID:7051332514dcd314f5e2e611a9fef059471e15980badffd953b1772a63166f9c OrchestratorContext:[123 34 80 111 100 78 97 109 101 34 58 34 110 103 105 110 120 34 44 34 80 111 100 78 97 109 101 115 112 97 99 101 34 58 34 100 101 102 97 117 108 116 34 125] Ifname: SecondaryInterfacesExist:false} *cns.IPConfigsResponse &{PodIPInfo:[{PodIPConfig:{IPAddress:192.168.1.47 PrefixLength:16} NetworkContainerPrimaryIPConfig:{IPSubnet:{IPAddress:192.168.1.0 PrefixLength:16} DNSServers:[] GatewayIPAddress:} HostPrimaryIPInfo:{Gateway:10.224.0.1 PrimaryIP:10.224.0.5 Subnet:10.224.0.0/16} NICType:InfraNIC InterfaceName: MacAddress: SkipDefaultRoutes:false Routes:[]}] Response:{ReturnCode:Success Message:}}.
kubectl get po nginx -owide
nginx   1/1     Running   0          4m22s   192.168.1.47   aks-nodepool1-30840492-vmss000001   <none>           <none>
aks-nodepool1-30840492-vmss000001:/# cat cat /var/run/azure-vnet.json
                                                        "70513325-eth0": {
                                                                "Id": "70513325-eth0",
                                                                "SandboxKey": "",
                                                                "IfName": "azvc440f4556932",
                                                                "HostIfName": "azvc440f455693",
                                                                "MacAddress": "ZqPi31PX",
                                                                "InfraVnetIP": {
                                                                        "IP": "",
                                                                        "Mask": null
                                                                },
                                                                "LocalIP": "",
                                                                "IPAddresses": [
                                                                        {
                                                                                "IP": "192.168.1.47",
                                                                                "Mask": "//8AAA=="
                                                                        }
                                                                ],
                                                                "Gateways": [
                                                                        "0.0.0.0"
                                                                ],
                                                                "DNS": {
                                                                        "Suffix": "",
                                                                        "Servers": null,
                                                                        "Options": null
                                                                },
                                                                "Routes": [
                                                                        {
                                                                                "Dst": {
                                                                                        "IP": "0.0.0.0",
                                                                                        "Mask": "AAAAAA=="
                                                                                },
                                                                                "Src": "",
                                                                                "Gw": "169.254.1.1",
                                                                                "Protocol": 0,
                                                                                "DevName": "",
                                                                                "Scope": 0,
                                                                                "Priority": 0,
                                                                                "Table": 0
                                                                        }
                                                                ],
                                                                "VlanID": 0,
                                                                "EnableSnatOnHost": false,
                                                                "EnableInfraVnet": false,
                                                                "EnableMultitenancy": false,
                                                                "AllowInboundFromHostToNC": false,
                                                                "AllowInboundFromNCToHost": false,
                                                                "NetworkContainerID": "",
                                                                "NetworkNameSpace": "/var/run/netns/cni-37bc323b-6978-74ae-6bf2-1f881e9f0e3f",
                                                                "ContainerID": "7051332514dcd314f5e2e611a9fef059471e15980badffd953b1772a63166f9c",
                                                                "PODName": "nginx",
                                                                "PODNameSpace": "default",
                                                                "SecondaryInterfaces": {}
                                                        },
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl

## k8s-cni.azure.byo (byo cni)

```
# k8s-cni.azure.byo 

rg=rgbyo
az group create -n $rg -l $loc
az aks create -g $rg -n aks  --network-plugin none -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

NAME                                STATUS     ROLES    AGE   VERSION
aks-nodepool1-36608186-vmss000000   NotReady   <none>   98s   v1.30.10
aks-nodepool1-36608186-vmss000001   NotReady   <none>   85s   v1.30.10
NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
kube-system   cloud-node-manager-hlmx5              1/1     Running   0          86s
kube-system   cloud-node-manager-sq5tf              1/1     Running   0          99s
kube-system   coredns-659fcb469c-4bkl9              0/1     Pending   0          2m44s
kube-system   coredns-autoscaler-6f7d6d6464-9g7rr   0/1     Pending   0          2m44s
kube-system   csi-azuredisk-node-28bj2              3/3     Running   0          86s
kube-system   csi-azuredisk-node-k9f8n              3/3     Running   0          99s
kube-system   csi-azurefile-node-bcb9w              3/3     Running   0          86s
kube-system   csi-azurefile-node-bd79w              3/3     Running   0          99s
kube-system   konnectivity-agent-655bbc4455-265rr   1/1     Running   0          2m44s
kube-system   konnectivity-agent-655bbc4455-l9kp8   1/1     Running   0          2m44s
kube-system   kube-proxy-7plvk                      1/1     Running   0          99s
kube-system   kube-proxy-fw796                      1/1     Running   0          85s
kube-system   metrics-server-696749dc54-bv992       0/2     Pending   0          2m44s
kube-system   metrics-server-696749dc54-dw7bt       0/2     Pending   0          2m44s

# k describe po
  Warning  FailedScheduling  3m53s (x7 over 33m)  default-scheduler  0/2 nodes are available: 2 node(s) had untolerated taint {node.kubernetes.io/not-ready: }. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.

kubectl get node -o custom-columns='NAME:.metadata.name,STATUS:.status.conditions[?(@.type=="Ready")].message'
NAME                                STATUS
aks-nodepool1-36608186-vmss000000   container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
aks-nodepool1-36608186-vmss000001   container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized

az aks show -g $rg -n aks --query networkProfile
  "networkPlugin": "none",
  "networkPolicy": "none",
```

- https://learn.microsoft.com/en-us/azure/aks/use-byo-cni?tabs=azure-cli

```
# k8s-cni.azure.byo.calico

rg=rgbyo
az group create -n $rg -l $loc
az aks create -g $rg -n aks --pod-cidr 192.168.0.0/16 --network-plugin none -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/tigera-operator.yaml
kubectl create -f - <<EOF
kind: Installation
apiVersion: operator.tigera.io/v1
metadata:
  name: default
spec:
  kubernetesProvider: AKS
  cni:
    type: Calico
  calicoNetwork:
    bgp: Disabled
    ipPools:
     - cidr: 192.168.0.0/16
       encapsulation: VXLAN
---
apiVersion: operator.tigera.io/v1
kind: APIServer
metadata:
   name: default
spec: {}
EOF
watch kubectl get pods -n calico-system

NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-75d656cb66-bjz54   1/1     Running   0          66s
calico-node-l5hj8                          1/1     Running   0          66s
calico-node-tln9f                          1/1     Running   0          66s
calico-typha-b5f98dcc4-g74lf               1/1     Running   0          66s
csi-node-driver-mb8fj                      2/2     Running   0          66s
csi-node-driver-sn5h8                      2/2     Running   0          66s

kubectl get no; kubectl get po -A
NAME                                STATUS   ROLES    AGE     VERSION
aks-nodepool1-37563806-vmss000000   Ready    <none>   5m58s   v1.30.10
aks-nodepool1-37563806-vmss000001   Ready    <none>   5m55s   v1.30.10
aks-nodepool1-37563806-vmss000002   Ready    <none>   5m59s   v1.30.10
NAMESPACE          NAME                                      READY   STATUS    RESTARTS   AGE
calico-apiserver   calico-apiserver-5bbbc95699-9qtd7         1/1     Running   0          2m44s
calico-apiserver   calico-apiserver-5bbbc95699-qnpr2         1/1     Running   0          2m44s
calico-system      calico-kube-controllers-d7d576855-ztx8n   1/1     Running   0          2m44s
calico-system      calico-node-6jssl                         1/1     Running   0          103s
calico-system      calico-node-gpphh                         1/1     Running   0          103s
calico-system      calico-node-jn48g                         1/1     Running   0          103s
calico-system      calico-typha-58864b9977-gclkr             1/1     Running   0          2m35s
calico-system      calico-typha-58864b9977-jvnrx             1/1     Running   0          2m44s
calico-system      csi-node-driver-5nkgn                     2/2     Running   0          2m44s
calico-system      csi-node-driver-gmhf9                     2/2     Running   0          2m44s
calico-system      csi-node-driver-nh7mb                     2/2     Running   0          2m44s
kube-system        cloud-node-manager-6km2n                  1/1     Running   0          5m56s
kube-system        cloud-node-manager-q7twk                  1/1     Running   0          5m59s
kube-system        cloud-node-manager-x664p                  1/1     Running   0          6m
kube-system        coredns-659fcb469c-2vg6s                  1/1     Running   0          6m16s
kube-system        coredns-659fcb469c-z6vxs                  1/1     Running   0          84s
kube-system        coredns-autoscaler-6f7d6d6464-fl7rr       1/1     Running   0          6m16s
kube-system        csi-azuredisk-node-2tbvb                  3/3     Running   0          5m56s
kube-system        csi-azuredisk-node-5mhkr                  3/3     Running   0          6m
kube-system        csi-azuredisk-node-ctqbc                  3/3     Running   0          5m59s
kube-system        csi-azurefile-node-gfxk9                  3/3     Running   0          5m56s
kube-system        csi-azurefile-node-m9x85                  3/3     Running   0          5m59s
kube-system        csi-azurefile-node-n8gct                  3/3     Running   0          6m
kube-system        konnectivity-agent-6bffff765-mzxkz        1/1     Running   0          6m16s
kube-system        konnectivity-agent-6bffff765-tktms        1/1     Running   0          6m16s
kube-system        kube-proxy-9v6k7                          1/1     Running   0          5m56s
kube-system        kube-proxy-llrh9                          1/1     Running   0          6m
kube-system        kube-proxy-zfqtb                          1/1     Running   0          5m59s
kube-system        metrics-server-cd969dd86-dc8gk            2/2     Running   0          73s
kube-system        metrics-server-cd969dd86-ldbdc            2/2     Running   0          73s
tigera-operator    tigera-operator-797db67f8-85dq5           1/1     Running   0          2m50s
```

- https://docs.tigera.io/calico/latest/getting-started/kubernetes/managed-public-cloud/aks#install-aks-with-calico-networking
- https://www.tigera.io/blog/byocni-introducing-calico-cni-for-azure-aks/

## k8s-cni.azure.IPs

```
# azure-cni.create
rg=rg
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 2 --network-plugin azure
az aks get-credentials -g $rg -n aks --overwrite-existing

cidr="10.2.0.0/16" # success
subnet=subnet2
nodepool=nodepool2
count=2
maxpods=250
az network vnet subnet create -g $rg --vnet-name vnet -n $subnet --address-prefixes $cidr -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n $subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n $nodepool --vnet-subnet-id $subnetId -s $vmsize -c $count --max-pods $maxpods # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n $nodepool --no-wait

cidr="10.3.0.0/24" # 10.3.0.0 to 10.3.0.255 i.e. 256 hosts. success
subnet=subnet3
nodepool=nodepool3
count=1
maxpods=250
az network vnet subnet create -g $rg --vnet-name vnet -n $subnet --address-prefixes $cidr -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n $subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n $nodepool --vnet-subnet-id $subnetId -s $vmsize -c $count --max-pods $maxpods # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n $nodepool --no-wait

cidr="10.32.0.0/24" # 10.32.0.0 to 10.32.0.255 i.e. 256 hosts. InsufficientSubnetSize
subnet=subnet32
nodepool=nodepool32
count=2
maxpods=250
az network vnet subnet create -g $rg --vnet-name vnet -n $subnet --address-prefixes $cidr -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n $subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n $nodepool --vnet-subnet-id $subnetId -s $vmsize -c $count --max-pods $maxpods # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n $nodepool --no-wait

(InsufficientSubnetSize) Pre-allocated IPs 498 exceeds IPs available 251 in Subnet Cidr 10.32.0.0/24, Subnet Name subnet32. http://aka.ms/aks/insufficientsubnetsize
Code: InsufficientSubnetSize
Message: Pre-allocated IPs 498 exceeds IPs available 251 in Subnet Cidr 10.32.0.0/24, Subnet Name subnet32. http://aka.ms/aks/insufficientsubnetsize
Target: agentPoolProfile.vnetSubnetID
## (maxpodsxcount)-count=(250x2)-2=498
## hosts-subnetReserved=256-5=251

cidr="10.33.0.0/24" # 10.33.0.0 to 10.33.0.255 i.e. 256 hosts. InsufficientSubnetSize
subnet=subnet33
nodepool=nodepool33
count=3
maxpods=250
az network vnet subnet create -g $rg --vnet-name vnet -n $subnet --address-prefixes $cidr -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n $subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n $nodepool --vnet-subnet-id $subnetId -s $vmsize -c $count --max-pods $maxpods # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n $nodepool --no-wait

(InsufficientSubnetSize) Pre-allocated IPs 747 exceeds IPs available 251 in Subnet Cidr 10.33.0.0/24, Subnet Name subnet33. http://aka.ms/aks/insufficientsubnetsize
Code: InsufficientSubnetSize
Message: Pre-allocated IPs 747 exceeds IPs available 251 in Subnet Cidr 10.33.0.0/24, Subnet Name subnet33. http://aka.ms/aks/insufficientsubnetsize
Target: agentPoolProfile.vnetSubnetID
## (maxpodsxcount)-count=(250x3)-3=747
## hosts-subnetReserved=256-5=251

for i in {2..100}; do az aks nodepool delete -g $rg --cluster-name aks -n nodepool$i --no-wait; done
```

- https://learn.microsoft.com/en-us/azure/aks/concepts-network-ip-address-planning
- https://learn.microsoft.com/en-us/azure/aks/concepts-network-legacy-cni#ip-address-availability-and-exhaustion
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connectivity/insufficientsubnetsize-error-advanced-networking
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/error-code-subnetisfull-upgrade
- https://github.com/Azure/aks-engine/blob/master/examples/largeclusters/README.md

## k8s-cni.azure.traffic

```
# cni.azure.pod-to-pod traffic between nodes
# no NAT, enable IP forwarding, route table (likely a VFP configuration if not found, tbd for azure-cni)

kubectl get no -owide; kubectl get po -owide
kubectl delete po nginx; kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-60478455-vmss000000"}}}'
kubectl delete po nginx2; kubectl run nginx2 --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-60478455-vmss000001"}}}'
kubectl exec -it nginx -- curl -I http://10.224.0.31

# --network-plugin azure (tbd likely the same for --network-plugin kubenet and --network-plugin azure --network-plugin-mode overlay)
## source: pod (10.224.0.45)
## destination: pod (10.224.0.31)
## wireshark
2995	2025-03-24 18:16:02.899163	10.224.0.45	10.224.0.31	TCP	TCP	80	0x0df6 (3574)	37808 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=1120769543 TSecr=0 WS=128
3001	2025-03-24 18:16:02.927440	10.224.0.31	10.224.0.45	TCP	TCP	80	0x0000 (0)	80 ? 37808 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1410 SACK_PERM TSval=3543942995 TSecr=1120769543 WS=128
3004	2025-03-24 18:16:02.927495	10.224.0.45	10.224.0.31	TCP	TCP	72	0x0df7 (3575)	37808 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=1120769572 TSecr=3543942995
3007	2025-03-24 18:16:02.927570	10.224.0.45	10.224.0.31	HTTP	TCP	148	0x0df8 (3576)	HEAD / HTTP/1.1 
3010	2025-03-24 18:16:02.927642	10.224.0.31	10.224.0.45	TCP	TCP	72	0x89a8 (35240)	80 ? 37808 [ACK] Seq=1 Ack=77 Win=65152 Len=0 TSval=3543943008 TSecr=1120769572
3013	2025-03-24 18:16:02.927738	10.224.0.31	10.224.0.45	TCP	TCP	310	0x89a9 (35241)	80 ? 37808 [PSH, ACK] Seq=1 Ack=77 Win=65152 Len=238 TSval=3543943008 TSecr=1120769572
3016	2025-03-24 18:16:02.927748	10.224.0.45	10.224.0.31	TCP	TCP	72	0x0df9 (3577)	37808 ? 80 [ACK] Seq=77 Ack=239 Win=64128 Len=0 TSval=1120769572 TSecr=3543943008
3019	2025-03-24 18:16:02.927939	10.224.0.45	10.224.0.31	TCP	TCP	72	0x0dfa (3578)	37808 ? 80 [FIN, ACK] Seq=77 Ack=239 Win=64128 Len=0 TSval=1120769572 TSecr=3543943008
3026	2025-03-24 18:16:02.928043	10.224.0.31	10.224.0.45	TCP	TCP	72	0x89aa (35242)	80 ? 37808 [FIN, ACK] Seq=239 Ack=78 Win=65152 Len=0 TSval=3543943008 TSecr=1120769572
3030	2025-03-24 18:16:02.928058	10.224.0.45	10.224.0.31	TCP	TCP	72	0x0dfb (3579)	37808 ? 80 [ACK] Seq=78 Ack=240 Win=64128 Len=0 TSval=1120769572 TSecr=3543943008
## tcpdump destinationPodIp
aks-nodepool1-31795678-vmss000001:/# tcpdump host 10.244.0.8
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), snapshot length 262144 bytes
^C18:28:21.294495 IP 10.244.2.4.54450 > 10.244.0.8.http: Flags [S], seq 1339508035, win 64240, options [mss 1418,sackOK,TS val 2685917755 ecr 0,nop,wscale 7], length 0
18:28:21.294591 IP 10.244.0.8.http > 10.244.2.4.54450: Flags [S.], seq 2306304410, ack 1339508036, win 65160, options [mss 1460,sackOK,TS val 1239010359 ecr 2685917755,nop,wscale 7], length 0
18:28:21.294891 IP 10.244.2.4.54450 > 10.244.0.8.http: Flags [.], ack 1, win 502, options [nop,nop,TS val 2685917756 ecr 1239010359], length 0
18:28:21.295812 IP 10.244.2.4.54450 > 10.244.0.8.http: Flags [P.], seq 1:76, ack 1, win 502, options [nop,nop,TS val 2685917757 ecr 1239010359], length 75: HTTP: HEAD / HTTP/1.1
18:28:21.295839 IP 10.244.0.8.http > 10.244.2.4.54450: Flags [.], ack 76, win 509, options [nop,nop,TS val 1239010361 ecr 2685917757], length 0
18:28:21.296005 IP 10.244.0.8.http > 10.244.2.4.54450: Flags [P.], seq 1:239, ack 76, win 509, options [nop,nop,TS val 1239010361 ecr 2685917757], length 238: HTTP: HTTP/1.1 200 OK
18:28:21.296103 IP 10.244.2.4.54450 > 10.244.0.8.http: Flags [.], ack 239, win 501, options [nop,nop,TS val 2685917757 ecr 1239010361], length 0
18:28:21.299914 IP 10.244.2.4.54450 > 10.244.0.8.http: Flags [F.], seq 76, ack 239, win 501, options [nop,nop,TS val 2685917761 ecr 1239010361], length 0
18:28:21.300066 IP 10.244.0.8.http > 10.244.2.4.54450: Flags [F.], seq 239, ack 77, win 509, options [nop,nop,TS val 1239010365 ecr 2685917761], length 0
18:28:21.300185 IP 10.244.2.4.54450 > 10.244.0.8.http: Flags [.], ack 240, win 501, options [nop,nop,TS val 2685917761 ecr 1239010365], length 0
```

```
## enableIPForwarding, route table
--network-plugin azure
az vmss nic show -g MC_rg_akscni_swedencentral --vmss-name aks-nodepool1-60478455-vmss -n aks-nodepool1-60478455-vmss --instance-id 0 --query enableIPForwarding # false
az resource list -g MC_rg_akscni_swedencentral -otable # no route table
--network-plugin kubenet
az vmss nic show -g MC_rg_akskube_swedencentral --vmss-name aks-nodepool1-31795678-vmss -n aks-nodepool1-31795678-vmss --instance-id 0 --query enableIPForwarding # true
az resource list -g MC_rg_akskube_swedencentral -otable # aks-agentpool-12544801-routetable
--network-plugin azure --network-plugin-mode overlay
az vmss nic show -g MC_rg_akscnioverlay_swedencentral --vmss-name aks-nodepool1-17217300-vmss -n aks-nodepool1-17217300-vmss --instance-id 0 --query enableIPForwarding # true
az resource list -g MC_rg_akscnioverlay_swedencentral -otable # no route table
```

```
## other
ip route show
iptables -L -t nat
ip -d link show
tcpdump -i any port 4789 -nn
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl: A separate routing domain is created in the Azure Networking stack for the pod's private CIDR space, which creates an Overlay network for direct communication between pods. There's no need to provision custom routes on the cluster subnet or use an encapsulation method to tunnel traffic between pods

```
# cni.azure.pod-to-external traffic
# NAT
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl: Network Address Translation (NAT) uses the node's IP address to reach resources outside the cluster.
