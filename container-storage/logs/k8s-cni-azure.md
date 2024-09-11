```
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
