## aks
```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n npmar -s $vmsize # --os-sku Mariner
az aks nodepool delete -g $rg --cluster-name aks -n np2 --no-wait
```

```
az aks create -g $rg -n akseph -s $vmsize -c 1 --node-osdisk-type Ephemeral -s Standard_DS3_v2
az aks create -g $rg -n aksgen -s $vmsize -c 1 -s Standard_D4s_v5 # Also non-ephemeral
```

```
rg=rg
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 2 --network-plugin azure
az aks get-credentials -g $rg -n aks --overwrite-existing

subnet=subnet2
nodepool=nodepool2
az network vnet subnet create -g $rg --vnet-name vnet -n $subnet --address-prefixes 10.2.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n $subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n $nodepool --vnet-subnet-id $subnetId -s $vmsize -c 2 # --max-pods 250 # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n $nodepool --no-wait

for i in {2..100}; do az aks nodepool delete -g $rg --cluster-name aks -n nodepool$i --no-wait; done
```

- https://github.com/Azure/azure-rest-api-specs/blob/main/specification/containerservice/resource-manager/Microsoft.ContainerService/aks/stable/2023-02-01/managedClusters.json
- https://github.com/andyzhangx/demo/blob/master/debug/README.md
- https://github.com/feiskyer/kubernetes-handbook/blob/master/README.md
- https://learn.microsoft.com/en-us/azure/aks/
- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/create-or-update?tabs=HTTP#examples
- https://learn.microsoft.com/en-us/training/paths/aks-cluster-architecture/
- https://cloudacademy.com/course/introduction-to-aks-954/course-introduction/
- https://learn.microsoft.com/en-us/azure/architecture/guide/multitenant/service/aks
- https://learn.microsoft.com/en-us/azure/aks/best-practices-app-cluster-reliability
- https://github.com/Azure/AKS/
- https://issuetracker.google.com/savedsearches/559746: Open Kubernetes Engine Issues
- https://github.com/Azure/aks-gbb-officehours/blob/main/README.md: updates up to 2022
- https://www.youtube.com/@theakscommunity
- https://azure.github.io/AKS/: AKS Engineering Blog
- https://github.com/Azure/AKS/?tab=readme-ov-file#important-links

## aks.core.reconcile

```
k describe ds -n kube-system csi-azuredisk-node | grep Limits: -A 1.
kubectl set resources daemonset csi-azuredisk-node -c=azuredisk --limits=memory=1200Mi -n kube-system # AKS quickly reverts back my change
```

## aks.core.remediator

- https://learn.microsoft.com/en-us/azure/aks/node-auto-repair: AKS initiates repair operations with the user account aks-remediator.

## aks.spec.agentPool.vmSize

- https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions#supported-vm-sizes
- https://learn.microsoft.com/en-us/azure/aks/gpu-cluster?#supported-gpu-enabled-vms
- https://aka.ms/aks/restricted-skus

## aks.spec.sku.Automatic

```
# create
az aks create -g $rg -n aksauto --sku automatic
az aks get-credentials -g $rg -n aksauto --overwrite-existing

# misc
az aks show -g $rg -n aks --query kind # "Automatic"
az aks show -g $rg -n aks --query sku.name # "Automatic"

# create.custom-vnet
tbd BadRequest
rg=rgvnet
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
# az aks create -g $rg -n aksauto --vnet-subnet-id $subnetId --sku automatic # (OnlySupportedOnUserAssignedMSICluster) System-assigned managed identity not supported for custom resource VirtualNetworks. Please use user-assigned managed identity.
userIdentityName="userIdentity$RANDOM"
az identity create -g $rg -n $userIdentityName
userIdentityUri=$(az identity show -g $rg --name $userIdentityName --query id -otsv); echo $userIdentityUri
# az aks create -g $rg -n aksauto --vnet-subnet-id $subnetId --sku automatic --enable-managed-identity --assign-identity $userIdentityUri # (InvalidParameter) Outbound type is managedNATGateway but agent pool 'nodepool1' is using custom VNet, which is not allowed.
userIdentityUri=$(az identity show -g $rg --name $userIdentityName --query id -otsv); echo $userIdentityUri
az network public-ip create -g $rg -n natIp --sku standard
az network nat gateway create -g $rg -n natGateway --public-ip-addresses natIp
az network vnet subnet update --ids $subnetId --nat-gateway natGateway
# az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 --nat-gateway natGateway
az aks create -g $rg -n aksauto --vnet-subnet-id $subnetId --sku automatic --enable-managed-identity --assign-identity $userIdentityUri --outbound-type userAssignedNATGateway
# (BadRequest) Managed cluster 'Automatic' SKU should enable 'OutboundType' feature with recommended values; Managed cluster 'Automatic' should only allow cluster with managed identity to be created.
az aks get-credentials -g $rg -n aks --overwrite-existing
```

- https://azure.microsoft.com/en-us/updates/public-preview-aks-automatic/
- https://learn.microsoft.com/en-us/azure/aks/intro-aks-automatic
- https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-automatic-deploy
- https://azure.github.io/AKS/2024/05/22/aks-automatic

## aks.scale
- https://learn.microsoft.com/en-us/azure/aks/best-practices-performance-scale-large
