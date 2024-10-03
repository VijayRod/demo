## k8s-cni.azure.podsubnet

```
az feature register --namespace Microsoft.ContainerService --name AzureVnetScalePreview
az feature show --namespace Microsoft.ContainerService --name AzureVnetScalePreview
```

- https://learn.microsoft.com/en-us/azure/aks/concepts-network-azure-cni-pod-subnet

## k8s-cni.azure.podsubnet.static

```
rg=rg
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n nodesubnet --address-prefixes 10.240.0.0/16 -o none
az network vnet subnet create -g $rg --vnet-name vnet -n podsubnet --address-prefixes 10.40.0.0/13 -o none
nodesubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n nodesubnet --query id -otsv)
podsubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n podsubnet --query id -otsv)
az aks create -g $rg -n akspodsubnet --network-plugin azure --pod-ip-allocation-mode StaticBlock --vnet-subnet-id $nodesubnetId --pod-subnet-id $podsubnet --enable-addons monitoring -s $vmsize -c 2
az aks get-credentials -g $rg -n akspodsubnet --overwrite-existing
```

```
az aks show -g $rg -n akspodsubnet
  "agentPoolProfiles": [
      "name": "nodepool1",
      "podIpAllocationMode": "StaticBlock",
      "podSubnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/podsubnet",
      "vnetSubnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/nodesubnet",
      
kubectl get nnc -n kube-system
NAMESPACE     NAME                                ALLOCATED IPS   NC MODE   NC VERSION
kube-system   aks-nodepool1-36149301-vmss000000   255             static    0
kube-system   aks-nodepool1-36149301-vmss000001   255             static    0

kubectl get nnc -n kube-system -owide
NAME                                REQUESTED IPS   ALLOCATED IPS   SUBNET      SUBNET CIDR    NC ID                  NC MODE   NC TYPE     NC VERSION
aks-nodepool1-36149301-vmss000000   250             255             podsubnet   10.40.0.0/13   68eb969e-c8a9-4f82-a0c6-9b3ec8f9b276   static    vnetblock   0
aks-nodepool1-36149301-vmss000001   250             255             podsubnet   10.40.0.0/13   bf0a349b-c6e5-4fa8-bbbd-c84ee001b851   static    vnetblock   0

kubectl describe nnc -n kube-system aks-nodepool1-36149301-vmss000000
Name:         aks-nodepool1-36149301-vmss000000
Namespace:    kube-system
Labels:       kubernetes.azure.com/podnetwork-delegationguid=3371eec1-b861-4dca-838d-c6bfe7032461
              kubernetes.azure.com/podnetwork-subnet=podsubnet
              kubernetes.azure.com/podnetwork-type=vnetblock
...
Spec:
  Requested IP Count:  250
Status:
  Assigned IP Count:  255
  Network Containers:
    Assignment Mode:  static
...
    Resource Group ID:     rg
    Subcription ID:        redacts-1111-1111-1111-111111111111
    Subnet Address Space:  10.40.0.0/13
    Subnet ID:             podsubnet
    Subnet Name:           podsubnet
    Type:                  vnetblock
    Version:               0
    Vnet ID:               vnet
```    

```    
az network vnet subnet create -g $rg --vnet-name $vnet -n nodesubnet2 --address-prefixes 10.244.0.0/16 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n podsubnet2 --address-prefixes 10.244.0.0/26 -o none
nodesubnet2Id=$(az network vnet subnet show -g $rg --vnet-name vnet -n nodesubnet2 --query id -otsv)
podsubnet2Id=$(az network vnet subnet show -g $rg --vnet-name vnet -n podsubnet2 --query id -otsv)
az aks nodepool add -g $rg --cluster-name akspodsubnet  -n nodepool2 --vnet-subnet-id $node2subnet2Id --pod-subnet-id $podsubnet2Id --pod-ip-allocation-mode StaticBlock -c 2 --no-wait # --max-pods 250
````

- https://azure.microsoft.com/en-us/updates/public-preview-azure-cni-static-block-ip-allocation-support-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni-static-block-allocation
- https://learn.microsoft.com/en-us/azure/aks/concepts-network-azure-cni-pod-subnet#static-block-allocation-mode-preview
