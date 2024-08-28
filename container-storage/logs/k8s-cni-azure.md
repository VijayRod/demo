```
cat /var/run/azure-vnet.json
cat /var/run/azure-vnet-ipam.json
cat /etc/cni/net.d/10-azure.conflist
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
