## sc
- https://stackoverflow.com/questions/74741993/0-1-nodes-are-available-1-pod-has-unbound-immediate-persistentvolumeclaims: If you want the PVs automatically created from PVC claims you need a Provisioner installed in your Cluster.
- https://kubernetes.io/docs/concepts/storage/storage-classes/
  
## sc.op.update

- If the storage account parameter has been changed: the existing pvc would still use old storage class config, should remove that pvc and try again (by creating a new pvc)

## sc.parameters.useDataPlaneAPI
```
# useDataPlaneAPI aka storage account firewall
# By setting useDataPlaneAPI to "true", there is almost no (throttling) limit for creating file share. Just remember to enable public access in the storage account firewall settings.
# If useDataPlaneAPI isn't an option due to storage firewall requirements, the next move could be to space out the creation of PVs to avoid exceeding the SRP limits. See the section on Write_ObservationWindow_00:00:01.
```
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md: useDataPlaneAPI. specify whether use data plane API for file share create/delete/resize, this could solve the SRP API throttling issue since data plane API has almost no limit, while it would fail when there is firewall or vnet setting on storage account
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision: useDataPlaneAPI. Specify whether to use data plane API for file share create/delete/resize, which could solve the SRP API throttling issue because the data plane API has almost no limit, while it would fail when there's firewall or Vnet settings on storage account.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: useDataPlaneAPI: specify whether use data plane API for blob container create/delete, this could solve the SRP API throttling issue since data plane API has almost no limit, while it would fail when there is firewall or vnet setting on storage account
https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/driver-parameters.md: No useDataPlaneAPI

## sc.parameters.useDataPlaneAPI.azureblob

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: specify whether use data plane API for blob container create/delete, this could solve the SRP API throttling issue since data plane API has almost no limit, while it would fail when there is firewall or vnet setting on storage account i.e. make sure the storage account is not set to "Check Allow Access From (All Networks / Selected Networks)" "Selected Networks" i.e. set "Enabled from all networks" in the specified storage account
- https://learn.microsoft.com/en-us/answers/questions/1166011/getting-a-403-error-when-connecting-to-a-blob-cont: "Selected Networks" - It means the storage account is firewall enabled.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/controllerserver.go: if len(secrets) == 0 && useDataPlaneAPI {... "failed to GetStorageAccesskey on account

## sc.parameters.useDataPlaneAPI.azurefile

```
kubectl delete pvc pvc-azurefile
kubectl delete sc azurefile-dataplane
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-dataplane
mountOptions:
- mfsymlinks
- actimeo=30
parameters:
  skuName: Standard_LRS
  useDataPlaneAPI: "true"
provisioner: file.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-dataplane
EOF
kubectl get pvc -w

NAME            STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS          VOLUMEATTRIBUTESCLASS   AGE
pvc-azurefile   Pending                                      azurefile-dataplane   <unset>                 0s
pvc-azurefile   Pending   pvc-81a52b07-f3da-4a59-ad54-0a53a76d73dc   0                         azurefile-dataplane   <unset>                 1s
pvc-azurefile   Bound     pvc-81a52b07-f3da-4a59-ad54-0a53a76d73dc   100Gi      RWX            azurefile-dataplane   <unset>                 1s

az storage account list -g MC_rg_aks_swedencentral
    "networkRuleSet": {
      "bypass": "AzureServices",
      "defaultAction": "Allow",
```      

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/controllerserver.go: len(secret) == 0 && useDataPlaneAPI... failed to GetStorageAccesskey
- https://github.com/Azure/AKS/issues/804: Azure Files PV AuthorizationFailure when using advanced networking - I know why this only allow access from selected network for storage account does not work on AKS, that's because k8s persistentvolume-controller is on AKS master node which is not in the selected network, and that's why it could not create file share on that storage account... And in the near future, I don't think we would support this feature: only allow access from selected network for storage account... one workaround is use azure file static provisioning, that is create azure file share by user, and then user provide the storage account and file share in k8s... I think azure file static provisioning would work on this case, while dynamic provisioning (*specifically the default azurefile storage classes*) won't work
  - i.e. https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/create-file-share-failed-storage-account: The Kubernetes persistentvolume-controller isn't on the network that was chosen when the Allow access from network setting was enabled for Selected networks on the storage account.
