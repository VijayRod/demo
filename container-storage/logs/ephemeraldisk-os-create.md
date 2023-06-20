Here are the commands to create a cluster with an ephemeral OS disk.

```
# Replace values in the below.
rgname=resourceGroupName
clustername=akseph
```

```
# Create a cluster.
az aks create -g $rgname -n $clustername --node-osdisk-type Ephemeral -s Standard_DS3_v2
az aks get-credentials -g $rgname -n $clustername --overwrite-existing
```

Here are some related links:
- [aks/cluster-configuration#ephemeral-os](https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#ephemeral-os)
- [azure-samples/aks-ephemeral-os-disk](https://learn.microsoft.com/en-us/samples/azure-samples/aks-ephemeral-os-disk/aks-ephemeral-os-disk/), also at [Azure-Samples/aks-ephemeral-os-disk](https://github.com/Azure-Samples/aks-ephemeral-os-disk)
- [fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure/ba-p/3565605)
- [virtual-machines/ephemeral-os-disks](https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks).
