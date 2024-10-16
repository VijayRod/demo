## ephemeraldisk-os

Here are the commands to create a cluster with an ephemeral OS disk.

```
# aks
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks --node-osdisk-type Ephemeral -s $vmsize -c 2
az aks get-credentials -g $rg -n $aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n np2 --node-osdisk-type Ephemeral # --node-osdisk-size 128

kubectl describe no
Capacity:
  ephemeral-storage:  129886128Ki
Allocatable:
  ephemeral-storage:  119703055367
Allocated resources:
  Resource           Requests     Limits
  --------           --------     ------
  ephemeral-storage  0 (0%)       0 (0%)
```

- [aks/cluster-configuration#ephemeral-os](https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#ephemeral-os)
- [azure-samples/aks-ephemeral-os-disk](https://learn.microsoft.com/en-us/samples/azure-samples/aks-ephemeral-os-disk/aks-ephemeral-os-disk/), also at [Azure-Samples/aks-ephemeral-os-disk](https://github.com/Azure-Samples/aks-ephemeral-os-disk)
  - [fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure/ba-p/3565605)
    
```
# vm
az vm create -g $rg -n vm --image Ubuntu2204 --ephemeral-os-disk # --admin-username azureuser --public-ip-sku Standard --ephemeral-placement CacheDisk or ResourceDisk

TBD (No ephemeral property in the below)
az vm show -g $rg -n vm --query storageProfile.osDisk.managedDisk.id -otsv
az disk show -id 
az vm get-instance-view -g $rg -n vm
```

- [virtual-machines/ephemeral-os-disks](https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks).
