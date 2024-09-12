```
az aks create -g $rg -n akscal --network-plugin azure --network-policy calico -s $vmsize -c 1
az aks create -g $rg -n akskubecal --network-plugin kubenet --network-policy calico -s $vmsize -c 1
az aks create -g $rg -n akskube --network-plugin kubenet # default
az aks get-credentials -g $rg -n akscal --overwrite-existing
az aks get-credentials -g $rg -n akskubecal --overwrite-existing
az aks get-credentials -g $rg -n akskube --overwrite-existing
kubectl get no
```

- https://learn.microsoft.com/en-us/azure/aks/use-byo-cni?tabs=azure-cli
- https://kubernetes.io/docs/concepts/cluster-administration/networking/#the-kubernetes-network-model
- https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
- https://github.com/containernetworking/cni
- ** https://www.tkng.io/cni/: The Kubernetes Networking Guide
- https://docs.tigera.io/calico-cloud/networking/
- https://labs.iximiuz.com/tutorials/container-networking-from-scratch
- https://github.com/tigera-solutions/install-calico-on-aks: Networking options for AKS cluster

```
# /etc/cni/net.d

akscal - 10-azure.conflist
aks-nodepool1-36628055-vmss000000:/var# cat /etc/cni/net.d/10-azure.conflist
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

akskubecal - 10-calico.conflist
aks-nodepool1-64104225-vmss000000:/# cat /etc/cni/net.d/10-calico.conflist
{
  "name": "k8s-pod-network",
  "cniVersion": "0.3.1",
  "plugins": [
	{
		"container_settings": {
			"allow_ip_forwarding": true
		},
		"datastore_type": "kubernetes",
		"ipam": {
			"subnet": "usePodCidr",
			"type": "host-local"
		},
		"kubernetes": {
			"k8s_api_root": "https://akskubecal-rg-efec8e-11111111.hcp.swedencentral.azmk8s.io:443",
			"kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
		},
		"log_file_max_age": 30,
		"log_file_max_count": 10,
		"log_file_max_size": 100,
		"log_file_path": "/var/log/calico/cni/cni.log",
		"log_level": "Info",
		"mtu": 0,
		"nodename_file_optional": false,
		"policy": {
			"type": "k8s"
		},
		"type": "calico"
	},
	{
		"capabilities": {
			"bandwidth": true
		},
		"type": "bandwidth"
	},
	{
		"capabilities": {
			"portMappings": true
		},
		"snat": true,
		"type": "portmap"
	}
]
}

akskube - 10-containerd-net.conflist
aks-nodepool1-10522532-vmss000000:/# cat /etc/cni/net.d/10-containerd-net.conflist
{
    "cniVersion": "0.3.1",
    "name": "kubenet",
    "plugins": [{
    "type": "bridge",
    "bridge": "cbr0",
    "mtu": 1500,
    "addIf": "eth0",
    "isGateway": true,
    "ipMasq": false,
    "promiscMode": true,
    "hairpinMode": false,
    "ipam": {
        "type": "host-local",
        "ranges": [[{"subnet": "10.244.2.0/24"}]],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
    },
    {
    "type": "portmap",
    "capabilities": {"portMappings": true},
    "externalSetMarkChain": "KUBE-MARK-MASQ"
    }]
}
```

```
# /opt/cni/bin

akscal
aks-nodepool1-36628055-vmss000000:/# ls /opt/cni/bin/azure*
/opt/cni/bin/azure-vnet       /opt/cni/bin/azure-vnet-ipamv6     /opt/cni/bin/azure-vnet-telemetry.config
/opt/cni/bin/azure-vnet-ipam  /opt/cni/bin/azure-vnet-telemetry

akskubecal
aks-nodepool1-64104225-vmss000000:/# ls /opt/cni/bin/cal*
/opt/cni/bin/calico  /opt/cni/bin/calico-ipam

akskube
aks-nodepool1-10522532-vmss000000:/# ls /opt/cni/bin/ # no additional files present
```

- https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/: If you want to enable traffic shaping support, you must add the bandwidth plugin to your CNI configuration file (default /etc/cni/net.d) and ensure that the binary is included in your CNI bin dir (default /opt/cni/bin).
- https://stackoverflow.com/questions/49112336/container-runtime-network-not-ready-cni-config-uninitialized: Unable to update cni config: No networks found in /etc/cni/net.d. Container runtime network not ready
- https://github.com/tigera-solutions/install-calico-on-aks: Using kubenet + Calico networking plugin and network policy. This option is a bit misleading in its naming as it suggests that kubenet is used while in reality the cluster is configured to use Calico CNI with Host-Local IPAM and Calico network policy engine...

