```
rg=rg
az group create -n $rg -l swedencentral
az vm create -g $rg -n vm --image Ubuntu2204 --admin-username azureuser --public-ip-sku Standard
ip=$(az vm show --show-details -g $rg -n vm --query publicIps --output tsv)
ssh azureuser@$ip

subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $subnet --query id -otsv)
az vm create -g $rgname -n $vm --image=Ubuntu2204 --subnet $subnetId
```

- https://azure.microsoft.com/en-us/blog/azure-virtual-machine-internals-part-1/
