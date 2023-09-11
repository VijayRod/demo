```
rg=rg
az group create -n $rg -l swedencentral
az disk create -g $rg -n myDataDisk --size-gb 100 #--sku Premium_LRS
diskId=$(az disk show -g $rg -n myDataDisk --query id -o tsv)
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview
