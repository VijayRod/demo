```
id=$(az webapp show -g $rgname -n $app --query id -otsv)

vnet=vnet
vmsubnet=vmsubnet
az network vnet create -g $rgname -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $vmsubnet --subnet-prefixes 10.2.0.0/24
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $vmsubnet --query id -otsv)

# groupId=$(az network private-link-resource list --id $id --query [0].name -otsv)
az network private-endpoint create -g $rgname -n private-endpoint \
    --connection-name connection-1 --subnet $subnetId \
    --private-connection-resource-id $id --group-id sites
```
    
- https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-cli
