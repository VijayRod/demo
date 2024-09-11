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
- https://github.com/containernetworking/cni/blob/main/SPEC.md#ip-address-management-ipam-interface
- https://github.com/tigera-solutions/install-calico-on-aks
  - Using kubenet networking plugin. It provides a very basic network configuration with Host-Local IPAM and /24 routes in the VNET associated with the host...
  - Using kubenet + Calico networking plugin and network policy. This option is a bit misleading in its naming as it suggests that kubenet is used while in reality the cluster is configured to use Calico CNI with Host-Local IPAM and Calico network policy engine...
- https://docs.tigera.io/calico/latest/networking/ipam/get-started-ip-addresses#calico-ipam
- https://docs.tigera.io/calico/latest/networking/ipam/get-started-ip-addresses#host-local-ipam
