```
# Replace the below with appropriate values
vnet=vnet
akssubnet=akssubnet

# To create a virtual network with a subnet
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n $akssubnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name $vnet -n $akssubnet --query id -otsv)
```

```
# To create a virtual network with a subnet (2)
az network vnet create -g $rg -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $akssubnet --subnet-prefixes 10.2.0.0/24
```

```
az vm create -g $rg -n vm --image Ubuntu2204 --subnet $subnetId --admin-username azureuser --public-ip-sku Standard
```

```
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 1
```
