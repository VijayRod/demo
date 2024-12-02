## k8s-cni

```
# See the section on container logs

az aks create -g $rg -n akscal --network-plugin azure --network-policy calico -s $vmsize -c 1
az aks create -g $rg -n akskubecal --network-plugin kubenet --network-policy calico -s $vmsize -c 1
az aks create -g $rg -n akskube --network-plugin kubenet # default
az aks get-credentials -g $rg -n akscal --overwrite-existing
az aks get-credentials -g $rg -n akskubecal --overwrite-existing
az aks get-credentials -g $rg -n akskube --overwrite-existing
kubectl get no
```

```
az aks create -g $rg -n akscni --network-plugin azure -s $vmsize -c 2
az aks create -g $rg -n akscnioverlay --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16 -s $vmsize -c 2
az aks get-credentials -g $rg -n akscni --overwrite-existing
az aks get-credentials -g $rg -n akscnioverlay --overwrite-existing
```

- https://learn.microsoft.com/en-us/azure/aks/use-byo-cni?tabs=azure-cli
- https://kubernetes.io/docs/concepts/cluster-administration/networking/#the-kubernetes-network-model
- https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/
- https://github.com/containernetworking/cni
- ** https://www.tkng.io/cni/: The Kubernetes Networking Guide
- https://docs.tigera.io/calico-cloud/networking/
- https://github.com/tigera-solutions/install-calico-on-aks: Networking options for AKS cluster

More:
- https://www.caseyc.net/cni-talk-kubecon-18.pdf
- https://www.altoros.com/blog/kubernetes-networking-writing-your-own-simple-cni-plug-in-with-bash/
- https://azuregulfblog.wordpress.com/wp-content/uploads/2019/04/aks_basicnetwork_technicalpaper.pdf
- https://logingood.github.io/kubernetes/cni/2016/05/14/netns-and-cni.html
- https://dougbtv.com/nfvpe/2017/06/22/cni-tutorial/
- https://karampok.me/posts/chained-plugins-cni/
- https://stevegriffith.nyc/posts/aks-networking-part2/
- https://labs.iximiuz.com/tutorials/container-networking-from-scratch

## k8s-cni./etc/cni/net.d

```
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

### k8s-cni./opt/cni/bin

```
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

## k8s-cni.pod.egress.azure.transparent

```
kubectl run nginx --image=nginx
sleep 10
kubectl get po -owide
nginx            1/1     Running   0          56s   10.224.0.32   aks-nodepool1-21988115-vmss000000   <none>           <none>

aks-nodepool1-21988115-vmss000000:/# apt update && apt install net-tools -y && route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.224.0.1      0.0.0.0         UG    100    0        0 eth0
10.224.0.0      0.0.0.0         255.255.0.0     U     100    0        0 eth0
10.224.0.1      0.0.0.0         255.255.255.255 UH    100    0        0 eth0
10.224.0.5      0.0.0.0         255.255.255.255 UH    0      0        0 azv59a2ee5f1fb
10.224.0.14     0.0.0.0         255.255.255.255 UH    0      0        0 azv45ad16253fe
10.224.0.32     0.0.0.0         255.255.255.255 UH    0      0        0 azvc440f455693
168.63.129.16   10.224.0.1      255.255.255.255 UGH   100    0        0 eth0
169.254.169.254 10.224.0.1      255.255.255.255 UGH   100    0        0 eth0

az network vnet subnet show -g MC_rg_akscni_swedencentral --vnet-name aks-vnet-29277632 -n aks-subnet --query addressPrefix -otsv
10.224.0.0/16 # 10.224.0.1 Reserved by Azure for the default gateway.

aks-nodepool1-21988115-vmss000000:/# ip addr # | grep azvc440f455693
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 7c:1e:52:1d:08:1f brd ff:ff:ff:ff:ff:ff
    inet 10.224.0.4/16 metric 100 brd 10.224.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::7e1e:52ff:fe1d:81f/64 scope link
       valid_lft forever preferred_lft forever
...
8: azvc440f455693@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-1f519b11-2afb-0b8f-4220-5ee7bb07af0a
    inet6 fe80::a8aa:aaff:feaa:aaaa/64 scope link
       valid_lft forever preferred_lft forever
       
aks-nodepool1-21988115-vmss000000:/# ip netns pids cni-1f519b11-2afb-0b8f-4220-5ee7bb07af0a # ip netns
36405
36538
36572
36573

aks-nodepool1-21988115-vmss000000:/# ps -aux | grep nginx
root       36538  0.0  0.0  11416  7508 ?        Ss   20:55   0:00 nginx: master process nginx -g daemon off;
systemd+   36572  0.0  0.0  11880  2784 ?        S    20:55   0:00 nginx: worker process
systemd+   36573  0.0  0.0  11880  2784 ?        S    20:55   0:00 nginx: worker process

aks-nodepool1-21988115-vmss000000:/# nsenter -t 36538 -n ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
7: eth0@if8: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether fa:54:ea:32:98:8c brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.224.0.32/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::f854:eaff:fe32:988c/64 scope link
       valid_lft forever preferred_lft forever

root@aks-nodepool1-21988115-vmss000000:/# crictl pods nginx
POD ID              CREATED             STATE               NAME                             NAMESPACE           ATTEMPT             RUNTIME
d6470858c09cf       6 minutes ago       Ready               nginx                            default             0                   (default)

aks-nodepool1-21988115-vmss000000:/# crictl inspectp d6470858c09cf | grep pid
    "pid": 36405,
```

- https://stevegriffith.nyc/posts/bridge-vs-transparent/

k8s-cni.pod.egress.azure.overlay aka Azure CNI Overlay

```
kubectl run nginx --image=nginx
sleep 10
kubectl get po -owide
nginx            1/1     Running   0          4m33s   192.168.0.192   aks-nodepool1-34233576-vmss000000   <none>           <none>

aks-nodepool1-34233576-vmss000000:/# apt update && apt install net-tools -y && route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.224.0.1      0.0.0.0         UG    100    0        0 eth0
10.224.0.0      0.0.0.0         255.255.0.0     U     100    0        0 eth0
10.224.0.1      0.0.0.0         255.255.255.255 UH    100    0        0 eth0
168.63.129.16   10.224.0.1      255.255.255.255 UGH   100    0        0 eth0
169.254.169.254 10.224.0.1      255.255.255.255 UGH   100    0        0 eth0
192.168.0.23    0.0.0.0         255.255.255.255 UH    0      0        0 azv0a0b823946e
192.168.0.115   0.0.0.0         255.255.255.255 UH    0      0        0 azvd127591233b
192.168.0.192   0.0.0.0         255.255.255.255 UH    0      0        0 azvc440f455693
192.168.0.221   0.0.0.0         255.255.255.255 UH    0      0        0 azv91f99aa0756

az network vnet subnet show -g MC_rg_akscnioverlay_swedencentral --vnet-name aks-vnet-37980258 -n aks-subnet --query addressPrefix -otsv
10.224.0.0/16 # 10.224.0.1 Reserved by Azure for the default gateway.

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 60:45:bd:fd:72:85 brd ff:ff:ff:ff:ff:ff
    inet 10.224.0.5/16 metric 100 brd 10.224.255.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::6245:bdff:fefd:7285/64 scope link
       valid_lft forever preferred_lft forever
...
18: azvc440f455693@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:aa:aa:aa:aa:aa brd ff:ff:ff:ff:ff:ff link-netns cni-6d4439f3-7a95-d008-518f-8d2becaf8f31
    inet6 fe80::a8aa:aaff:feaa:aaaa/64 scope link
       valid_lft forever preferred_lft forever
       
aks-nodepool1-34233576-vmss000000:/# ip netns pids cni-6d4439f3-7a95-d008-518f-8d2becaf8f31
56546
56665
56700
56701

aks-nodepool1-34233576-vmss000000:/# ps -aux | grep nginx
root       56665  0.0  0.0  11416  7464 ?        Ss   22:26   0:00 nginx: master process nginx -g daemon off;
systemd+   56700  0.0  0.0  11880  2872 ?        S    22:26   0:00 nginx: worker process
systemd+   56701  0.0  0.0  11880  2872 ?        S    22:26   0:00 nginx: worker process

aks-nodepool1-34233576-vmss000000:/# nsenter -t 56665 -n ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
17: eth0@if18: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ba:06:92:24:8d:a1 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.0.192/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::b806:92ff:fe24:8da1/64 scope link
       valid_lft forever preferred_lft forever

kubectl get nnc -n kube-system -owide
NAME                                REQUESTED IPS   ALLOCATED IPS   SUBNET
                   SUBNET CIDR      NC ID                                  NC MODE   NC TYPE   NC VERSION
aks-nodepool1-34233576-vmss000000   0               256             routingdomain_fb71a450-e4af-5861-8f2a-7252c613411c_overlaysubnet   192.168.0.0/16   0a64a24c-9110-4bd0-a688-4b575b8e2e91   static    overlay   0
aks-nodepool1-34233576-vmss000001   0               256             routingdomain_fb71a450-e4af-5861-8f2a-7252c613411c_overlaysubnet   192.168.0.0/16   6d37af7f-cc3d-4a29-a4a4-8349e4750beb   static    overlay   0
```

- https://learn.microsoft.com/en-us/azure/architecture/operator-guides/aks/troubleshoot-network-aks: If using Azure CNI for dynamic IP allocation
