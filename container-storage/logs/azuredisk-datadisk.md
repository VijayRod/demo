```
rg=rg
az group create -n $rg -l swedencentral
az vm create -g $rg -n vm --image Ubuntu2204 --admin-username azureuser --public-ip-sku Standard
ip=$(az vm show --show-details -g $rg -n vm --query publicIps --output tsv)
az vm disk attach -g $rg --vm-name vm --name myDataDisk --new --size-gb 250 --sku Premium_LRS

az disk create -g $rg -n myDataDisk --size-gb 250 --sku Premium_LRS
diskId=$(az disk show -g vm -n myDataDisk --query 'id' -o tsv)
az vm disk attach -g $rg --vm-name vm --name $diskId
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/attach-managed-disk-portal
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/add-disk?tabs=ubuntu
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types
