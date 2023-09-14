```
kubectl describe sc | grep -E 'sku|Provisioner'
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           blob.csi.azure.com
Parameters:            protocol=nfs,skuName=Premium_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_LRS
Provisioner:           disk.csi.azure.com
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_LRS
Provisioner:           disk.csi.azure.com
Parameters:            skuname=Premium_LRS
Provisioner:           disk.csi.azure.com
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-disk-volume#error1: Disk cannot be attached to the VM because it is not in the same zone as the VM. In AKS, the default and other built-in StorageClasses for Azure disks use locally redundant storage (LRS). topology.disk.csi.azure.com/zone
