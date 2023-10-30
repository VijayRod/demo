```
rg=rg
az group create -n $rg -l swedencentral
az disk create -g $rg -n myDataDisk --size-gb 100 #--sku Premium_LRS
diskId=$(az disk show -g $rg -n myDataDisk --query id -o tsv)
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview
- https://stackoverflow.com/questions/62685770/is-it-possible-to-rent-azure-disk-and-connect-to-them-via-iscsi-from-my-pc: Azure Disks can't be mounted over iSCSI. You can have an Azure Files share and store your databases there. Or if this is SQL Server you can store database files directly on Azure Blob Storage.
