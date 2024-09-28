TBD

```
# Replace the below with appropriate values
rgname=testshack2
loc=swedencentral
vnet=myvnet
akssubnet=akssubnet
clustername=aksprivate
vnet2=myvnet2
vmsubnet=vmsubnet
vm=myvm
image=debian
user=azureuser

# To create a virtual network with an AKS cluster
az group create -n $rgname -l $loc
az network vnet create -g $rgname -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $akssubnet --subnet-prefixes 10.2.0.0/24
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $akssubnet --query id -otsv)
az aks create -g $rgname -n $clustername --vnet-subnet-id $subnetId --enable-private-cluster
privateFqdn=$(az aks show -g $rgname -n $clustername --query privateFqdn -otsv)

# To create a second *non-peered* virtual network
az network vnet create -g $rgname -n $vnet2 --address-prefix 11.2.0.0/16 --subnet-name $vmsubnet --subnet-prefixes 11.2.0.0/24
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet2 -n $vmsubnet --query id -otsv)
az vm create -g $rgname -n $vm --image $image --subnet $subnetId --admin-username $user --public-ip-sku Standard
ip=$(az vm show --show-details -g $rgname -n $vm --query publicIps --output tsv)

TBD
ssh azureuser@$ip 
## curl $privateFqdn
```

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal#options-for-connecting-to-the-private-cluster
- https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
