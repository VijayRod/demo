## azuredisk-csi

```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
default (default)        disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed                  disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed-csi              disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed-csi-premium      disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed-premium          disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h

kubectl describe sc default
Name:                  default
IsDefaultClass:        Yes
Annotations:           storageclass.kubernetes.io/is-default-class=true
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-azuredisk-node           1         1         1       1            1           <none>          9h
csi-azuredisk-node-win       0         0         0       0            0           <none>          9h
```

## azuredisk-csi.driver.parameter

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#create-a-custom-storage-class

## azuredisk-csi.driver.parameter.skuName

```
kubectl describe sc | grep -E 'Name|Parameters'
Name:                  default
Parameters:            skuname=StandardSSD_LRS
Name:                  managed
Parameters:            cachingmode=ReadOnly,kind=Managed,storageaccounttype=StandardSSD_LRS
Name:                  managed-csi
Parameters:            skuname=StandardSSD_LRS
Name:                  managed-csi-premium
Parameters:            skuname=Premium_LRS
Name:                  managed-premium
Parameters:            cachingmode=ReadOnly,kind=Managed,storageaccounttype=Premium_LRS
```
