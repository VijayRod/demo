```
az aks create -g $rg -n akscni -s $vmsize -c 1 --network-plugin azure
cat /var/run/azure-vnet.json
cat /var/run/azure-vnet-ipam.json
cat /etc/cni/net.d/10-azure.conflist
```

```
aks-nodepool1-59385832-vmss000000:/# cat /etc/cni/net.d/10-azure.conflist
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

aks-nodepool1-59385832-vmss000000:/# ip netns | grep 0a376d016a78
cni-1770aa7f-262a-c2ad-1c19-0a376d016a78 (id: 2)
aks-nodepool1-59385832-vmss000000:/# ip netns pids cni-1770aa7f-262a-c2ad-1c19-0a376d016a78
11255
11303
11338
11339
aks-nodepool1-59385832-vmss000000:/# ps aux
65535      11255  0.0  0.0    972     4 ?        Ss   09:46   0:00 /pause
root       11303  0.0  0.0  11404  7580 ?        Ss   09:46   0:00 nginx: master process nginx -g daemon off;
systemd+   11338  0.0  0.0  11868  2880 ?        S    09:46   0:00 nginx: worker process
systemd+   11339  0.0  0.0  11868  2880 ?        S    09:46   0:00 nginx: worker process

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
# No related entries in the azure-vnet.json, azure-vnet-ipam.json, 10-azure.conflist files.

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
```

- https://github.com/Azure/azure-container-networking
- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overview
- https://learn.microsoft.com/en-us/azure/aks/concepts-network#azure-cni-advanced-networking
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#azure-kubernetes-service-limits: Maximum pods per node: with Azure Container Networking Interface
- https://learn.microsoft.com/en-us/azure/virtual-network/container-networking-overview
