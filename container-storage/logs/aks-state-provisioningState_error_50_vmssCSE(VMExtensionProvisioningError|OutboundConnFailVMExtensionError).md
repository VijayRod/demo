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

az aks nodepool add -g $rg --cluster-name aks -n np2 --vnet-subnet-id $subnetId2 -s $vmsize --mode system -c 1 # VMExtensionProvisioningError with vmssCSE exit status=50
```

```
az aks show -g $rg -n aks --query provisioningState -otsv # Succeeded
az aks nodepool show -g $rg --cluster-name aks -n np2 --query provisioningState -otsv # Failed

kubectl get no
NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-42802770-vmss000000   Ready    agent   18m   v1.26.6

az aks update -g $rg -n aks -y # VMExtensionProvisioningError with vmssCSE exit status=50
az aks show -g $rg -n aks --query provisioningState -otsv # Failed

az aks nodepool add -g $rg --cluster-name aks -n np3 --vnet-subnet-id $subnetId2 -s $vmsize --mode user --no-wait # VMExtensionProvisioningError with vmssCSE exit status=50
```

```
az network vnet subnet create -g $rg --vnet-name $vnet -n np3subnet --address-prefixes 10.242.0.0/16 -o none 
az network nsg create -g $rg -n np3nsg
az network vnet subnet update -g $rg --vnet-name $vnet -n np3subnet --nsg np3nsg
np3subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n np3subnet --query id -otsv)
az aks nodepool add -g $rg --cluster-name aks -n np3 --vnet-subnet-id $np3subnetId -s $vmsize --mode user -c 1
az network nsg rule create -g $rg --nsg-name np3nsg -n DenyAllOutBound-my --priority 100 --access Deny --direction Outbound --protocol "*" --destination-port-ranges "*" --no-wait
az aks nodepool scale -g $rg --cluster-name aks -n np3 -c 2 # VMExtensionProvisioningError (OutboundConnFailVMExtensionError) with exit status=50
kubectl get no

NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-42802770-vmss000000   Ready    agent   58m   v1.26.6
aks-np3-39636099-vmss000000         Ready    agent   28m   v1.26.6
```
