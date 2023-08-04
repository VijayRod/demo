```
# Replace the below with appropriate values
vnet=myvnet
akssubnet=akssubnet

# To create a virtual network with a subnet
az network vnet create -g $rgname --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet -n $akssubnet --address-prefixes 10.240.0.0/16 -o none 

# To create a virtual network with a subnet (2)
az network vnet create -g $rgname -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $akssubnet --subnet-prefixes 10.2.0.0/24

# To retrieve the subnet Id
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $akssubnet --query id -otsv)
```
