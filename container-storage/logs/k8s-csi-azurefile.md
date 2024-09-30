## azurefile-csi

```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azurefile                file.csi.azure.com   Delete          Immediate              true                   9h
azurefile-csi            file.csi.azure.com   Delete          Immediate              true                   9h
azurefile-csi-premium    file.csi.azure.com   Delete          Immediate              true                   9h
azurefile-premium        file.csi.azure.com   Delete          Immediate              true                   9h

kubectl describe sc azurefile
Name:                  azurefile
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
AllowVolumeExpansion:  True
MountOptions:
  mfsymlinks
  actimeo=30
  nosharesock
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-azurefile-node           1         1         1       1            1           <none>          9h
csi-azurefile-node-win       0         0         0       0            0           <none>          9h
```

```
kubectl delete po nginx-azurefile
kubectl delete pvc pvc-azurefile
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/pvc-azurefile-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/nginx-pod-azurefile.yaml

kubectl get po nginx-azurefile -owide
kubectl get pvc pvc-azurefile
kubectl get pv
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md: volumeAttributes.shareName. Azure file share name
- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/aks/storage: (Volume refers to a) Static or dynamically created file share (not a storage account)

## azurefile-csi.driver.parameter

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#create-a-custom-storage-class
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#storage-class-parameters-for-dynamic-persistentvolumes

## azurefile-csi.driver.parameter.skuName

```
kubectl describe sc | grep -E 'Name|Parameters'
Name:                  azurefile
Parameters:            skuName=Standard_LRS
Name:                  azurefile-csi
Parameters:            skuName=Standard_LRS
Name:                  azurefile-csi-premium
Parameters:            skuName=Premium_LRS
Name:                  azurefile-premium
Parameters:            skuName=Premium_LRS
```

## azurefile-csi.driver.parameter.storageAccount

```
az storage account list -g MC_rg_aks_swedencentral
    "name": "fd121983a51b4483dab274b",
    "networkRuleSet": {
      "bypass": "AzureServices",
      "defaultAction": "Allow", # Public network access = Enabled from all networks
```

## azurefile-csi.driver.parameter.useDataPlaneAPI aka storage account firewall: 

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/controllerserver.go: len(secret) == 0 && useDataPlaneAPI... failed to GetStorageAccesskey
- https://github.com/Azure/AKS/issues/804: Azure Files PV AuthorizationFailure when using advanced networking - I know why this only allow access from selected network for storage account does not work on AKS, that's because k8s persistentvolume-controller is on AKS master node which is not in the selected network, and that's why it could not create file share on that storage account... And in the near future, I don't think we would support this feature: only allow access from selected network for storage account... one workaround is use azure file static provisioning, that is create azure file share by user, and then user provide the storage account and file share in k8s... I think azure file static provisioning would work on this case, while dynamic provisioning (*specifically the default azurefile storage classes*) won't work

## azurefile-csi.secret.dynamic

```
kubectl get secret
NAMESPACE     NAME                                                   TYPE                            DATA   AGE
default       azure-storage-account-fd121983a51b4483dab274b-secret   Opaque                          2      45s

kubectl describe secret
Name:         azure-storage-account-fd121983a51b4483dab274b-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
azurestorageaccountkey:   88 bytes
azurestorageaccountname:  23 bytes
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#storage-class-parameters-for-dynamic-persistentvolumes: If secretNamespace isn't specified, the secret is created in the same namespace as the pod

## azurefile-csi.secret.static

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#static-provisioning-parameters-for-persistentvolume: volumeAttributes.secretName... nodeStageSecretRef.name: If empty, driver uses kubelet identity to get account key.
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#mount-file-share-as-an-inline-volume: volumeAttributes.secretName
