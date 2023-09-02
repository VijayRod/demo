```
rg=rg
az group create -n $rg -l swedencentral
az disk create -g $rg -n myDataDisk --size-gb 100
diskId=$(az disk show -g $rg -n myDataDisk --query id -o tsv)

az snapshot create -g $rg -n snap --source $diskId # --incremental true
az snapshot show -g $rg -n snap
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/snapshot-copy-managed-disk
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-incremental-snapshots
