```
# rg=repro-failedstate
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n np1subnet --address-prefixes 10.240.0.0/16 -o none 
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n np1subnet --query id -otsv)
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 1
# az aks get-credentials -g $rg -n aks --overwrite-existing

az network vnet subnet create -g $rg --vnet-name $vnet -n np2 --address-prefixes 10.241.0.0/16 -o none
subnetId2=$(az network vnet subnet show -g $rg --vnet-name vnet -n np2 --query id -otsv)
 
az network nsg create -g $rg -n aks-agentpools-nsg
az network nsg rule create -g $rg --nsg-name aks-agentpools-nsg -n DenyAllOutBound-my --priority 100 --access Deny --direction Outbound --protocol "*" --destination-port-ranges "*" --no-wait
az network vnet subnet update -g $rg --vnet-name $vnet -n np2 --nsg aks-agentpools-nsg

az aks nodepool add -g $rg --cluster-name aks -n np2 --vnet-subnet-id $subnetId2 -s $vmsize --mode system # VMExtensionProvisioningError with vmssCSE exit status=50
```

```
az aks show -g $rg -n aks --query provisioningState -otsv # Succeeded
az aks nodepool show -g $rg --cluster-name aks -n np2 --query provisioningState -otsv # Failed

az aks update -g $rg -n aks -y # VMExtensionProvisioningError with vmssCSE exit status=50
az aks show -g $rg -n aks --query provisioningState -otsv # Failed

az aks nodepool add -g $rg --cluster-name aks -n np3 --vnet-subnet-id $subnetId2 -s $vmsize --mode user --no-wait # VMExtensionProvisioningError with vmssCSE exit status=50
```
