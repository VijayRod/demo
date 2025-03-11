## ipam

- https://github.com/containernetworking/cni/blob/main/SPEC.md#ip-address-management-ipam-interface
- https://github.com/tigera-solutions/install-calico-on-aks
  - Using kubenet networking plugin. It provides a very basic network configuration with Host-Local IPAM and /24 routes in the VNET associated with the host...
  - Using kubenet + Calico networking plugin and network policy. This option is a bit misleading in its naming as it suggests that kubenet is used while in reality the cluster is configured to use Calico CNI with Host-Local IPAM and Calico network policy engine...
- https://docs.tigera.io/calico/latest/networking/ipam/get-started-ip-addresses#calico-ipam
- https://docs.tigera.io/calico/latest/networking/ipam/get-started-ip-addresses#host-local-ipam

## ipam.azure

- https://docs.cilium.io/en/v1.9/concepts/networking/ipam/azure/#ipam-azure
- https://github.com/Azure/azure-container-networking/blob/master/docs/cni.md: azure-vnet-ipam CNI plugin implements the CNI IPAM plugin interface.
- https://github.com/Azure/ipam
- https://azure.github.io/ipam/#/
  
```
# ipam

akscal - azure-vnet-ipam
aks-nodepool1-36628055-vmss000000:/var# cat /etc/cni/net.d/10-azure.conflist
   "plugins":[
         "ipam":{
            "type":"azure-vnet-ipam"

akskubecal - ipam "type":"host-local"
aks-nodepool1-64104225-vmss000000:/# cat /etc/cni/net.d/10-calico.conflist
  "plugins": [
		"ipam": {
			"subnet": "usePodCidr",
			"type": "host-local
			
akskube
    "ipam": {
        "type": "host-local",
        "ranges": [[{"subnet": "10.244.2.0/24"}]],
        "routes": [{"dst": "0.0.0.0/0"}]
```

```
# ipam.log

akskubecal
aks-nodepool1-64104225-vmss000000:/# cat /var/log/calico/cni/cni.log | grep IPAM
2024-09-11 04:17:11.643 [INFO][6520] utils.go 344: Calico CNI passing podCidr to host-local IPAM: 0.0.0.0/0 ContainerID="aa1c1133fff09fab8f0a801b08ee94e2fac9487ffbad15f7c59fcdb29334748d"
2024-09-11 04:17:11.808 [INFO][6530] utils.go 344: Calico CNI passing podCidr to host-local IPAM: 10.244.0.0/24 ContainerID="82bd05f006f257bd609df4de2624d58e4c68819a7e57f3e449ac65f35ffc94ec" Namespace="kube-system" Pod="konnectivity-agent-7cb8bc976f-z8dq7" WorkloadEndpoint="aks--nodepool1--64104225--vmss000000-k8s-konnectivity--agent--7cb8bc976f--z8dq7-eth0"
2024-09-11 04:17:12.947 [INFO][6726] utils.go 344: Calico CNI passing podCidr to host-local IPAM: 10.244.0.0/24 ContainerID="4ee6efe4fd5fe9ba09bb5a7510440ec9afc749b7e32b8b114a5ee3069a14b959" Namespace="kube-system" Pod="coredns-597bb9d4db-nkqfz" WorkloadEndpoint="aks--nodepool1--64104225--vmss000000-k8s-coredns--597bb9d4db--nkqfz-eth0"
```

```
# ipam.azure-vnet-ipam
# pre-requisite: azure-cni cluster is required as this uses azure-vnet-ipam otherwise the azure-vnet-ipam.log file will be empty

aks-nodepool1-40097676-vmss000000:/# cat /var/log/azure-vnet-ipam.log
2025/03/05 18:15:58 [8443] Released process lock
2025/03/05 18:16:54 [9152] Acquiring process lock
2025/03/05 18:16:54 [9152] Acquired process lock with timeout value of 10s
2025/03/05 18:16:54 [9152] [cni-ipam] Plugin azure-vnet-ipam version v1.4.59.
2025/03/05 18:16:54 [9152] [cni-ipam] Running on Linux version 5.15.0-1079-azure (buildd@lcy02-amd64-098) (gcc (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0, GNU ld (GNU Binutils for Ubuntu) 2.38) #88-Ubuntu SMP Thu Jan 16 19:18:54 UTC 2025
2025/03/05 18:16:54 [9152] [ipam] Restored state, &{Version:v1.4.59 TimeStamp:2025-03-05 16:15:58.801819581 +0000 UTC AddrSpaces:map[local:0xc0004417d0] store:0xc00013a940 source:<nil> netApi:<nil> Mutex:{state:0 sema:0}}
2025/03/05 18:16:54 [9152] [cni-ipam] Plugin started.
2025/03/05 18:16:54 [9152] [cni-ipam] Processing DEL command with args {ContainerID:32970baf99617ff8068c2ac0c880074b38a73de164bea9d595cb505c7bb71768 Netns:/var/run/netns/cni-8d01d157-df2c-41e4-dcc1-0e2a90041da8 IfName:eth0 Args:K8S_POD_UID=0c2b7f49-4c67-425c-a90a-a665b564c5b4;IgnoreUnknown=1;K8S_POD_NAMESPACE=kube-system;K8S_POD_NAME=metrics-server-6998bdf5b-sq47j;K8S_POD_INFRA_CONTAINER_ID=32970baf99617ff8068c2ac0c880074b38a73de164bea9d595cb505c7bb71768 Path:/opt/cni/bin StdinData:{"cniVersion":"0.3.0","name":"azure","type":"azure-vnet","mode":"transparent","ipsToRouteViaHost":["169.254.20.10"],"ipam":{"type":"azure-vnet-ipam","subnet":"10.224.0.0/16","ipAddress":"10.224.0.5"},"dns":{},"runtimeConfig":{"dns":{}},"windowsSettings":{}}}.
2025/03/05 18:16:54 [9152] [cni-ipam] Read network configuration &{CNIVersion:0.3.0 Name:azure Type:azure-vnet Mode:transparent Master: AdapterName: Bridge: LogLevel: LogTarget: InfraVnetAddressSpace: IPV6Mode: ServiceCidrs: VnetCidrs: PodNamespaceForDualNetwork:[] IPsToRouteViaHost:[169.254.20.10] MultiTenancy:false EnableSnatOnHost:false EnableExactMatchForPodName:false DisableHairpinOnHostInterface:false DisableIPTableLock:false CNSUrl: ExecutionMode: IPAM:{Mode: Type:azure-vnet-ipam Environment: AddrSpace: Subnet:10.224.0.0/16 Address:10.224.0.5 QueryInterval:} DNS:{Nameservers:[] Domain: Search:[] Options:[]} RuntimeConfig:{PortMappings:[] DNS:{Servers:[] Searches:[] Options:[]}} WindowsSettings:{EnableLoopbackDSR:false HnsTimeoutDurationInSeconds:0} AdditionalArgs:[]}.
2025/03/05 18:16:54 [9152] [ipam] Starting source azure.
2025/03/05 18:16:54 [9152] [ipam] Refreshing address source.
2025/03/05 18:16:54 [9152] [Utils] Initializing HTTP client with connection timeout: 10, response header timeout: 10
2025/03/05 18:16:54 [9152] [ipam] Wireserver call http://168.63.129.16/machine/plugins?comp=nmagent&type=getinterfaceinfov1 to retrieve IP List
2025/03/05 18:16:54 [9152] [ipam] xml name received:{ Interfaces} interfaces:1
2025/03/05 18:16:54 [9152] [ipam] processing interface:eth0 IsPrimary:true macAddress:7c1e52f9f3c4 ips:1
2025/03/05 18:16:54 [9152] [ipam] Number of IPAddress found in ipsubnet 10.224.0.0/16: 29
2025/03/05 18:16:54 [9152] [ipam] got 28 addresses from interface eth0, subnet 10.224.0.0/16
2025/03/05 18:16:54 [9152] [ipam] merging address space
2025/03/05 18:16:54 [9152] [ipam] saving ipam state.
2025/03/05 18:16:54 [9152] [ipam] Save succeeded.
2025/03/05 18:16:54 [9152] [ipam] Releasing address with address:10.224.0.5 options:map[azure.address.id:32970baf99617ff8068c2ac0c880074b38a73de164bea9d595cb505c7bb71768].
2025/03/05 18:16:54 [9152] [ipam] Address release completed with address:10.224.0.5 err:<nil>.
2025/03/05 18:16:54 [9152] [ipam] saving ipam state.
2025/03/05 18:16:54 [9152] [ipam] Save succeeded.
2025/03/05 18:16:54 [9152] [cni-ipam] DEL command completed with err:<nil>.
2025/03/05 18:16:54 [9152] [cni-ipam] Plugin stopped.
2025/03/05 18:16:54 [9152] Released process lock
2025/03/05 18:16:58 [9257] Acquiring process lock

cat /etc/cni/net.d/10-azure.conflist
cat /var/run/azure-vnet.json
cat /var/run/azure-vnet-ipam.json

```

```
# ipam.azure-vnet-ipam.error.No available addresses
# azure-vnet-ipam.log
2025/03/01 18:57:25 [9209] [ipam] saving ipam state.
2025/03/01 18:57:25 [9209] [ipam] Save succeeded.
2025/03/01 18:57:25 [9209] [ipam] Requesting address with address: options:map[azure.address.id:xxx].
2025/03/01 18:57:25 [9209] [ipam] Address request failed with No available addresses
2025/03/01 18:57:25 [9209] [azure-vnet-ipam] Failed to allocate address: No available addresses.
2025/03/01 18:57:25 [9209] [cni-ipam] ADD command completed with result:<nil> err:Failed to allocate address: No available addresses.
```
