## cni.azure.overlay

```
rg=rgcni
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16  -s $vmsize -c 2
# az aks update -g $rg -n aks --network-plugin-mode overlay --pod-cidr 192.168.0.0/16
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks show -g $rg -n aks --query networkProfile.networkPluginMode
"overlay"

kubectl describe no
Labels:             agentpool=nodepool1
                    kubernetes.azure.com/azure-cni-overlay=true
                    kubernetes.azure.com/network-name=aks-vnet-14939177
                    kubernetes.azure.com/network-resourcegroup=rgcni
                    kubernetes.azure.com/network-subnet=aks-subnet
                    kubernetes.azure.com/network-subscription=redacts-1111-1111-1111-111111111111
                    kubernetes.azure.com/nodenetwork-vnetguid=eb6bc04b-710d-4348-8020-be2a2b853bf5
                    kubernetes.azure.com/podnetwork-type=overlay
```

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl: Like Azure CNI Overlay, Kubenet assigns IP addresses to pods from an address space logically different from the VNet

## cni.azure.overlay.upgrade

- https://learn.microsoft.com/en-us/azure/aks/azure-cni-overlay?tabs=kubectl#upgrade-an-existing-cluster-to-cni-overlay: azure-ip-masq-agent-config(, exists and is not intentionally in-place) it should be deleted
