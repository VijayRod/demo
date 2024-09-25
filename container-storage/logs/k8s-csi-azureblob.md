## azureblob-fuse

Here are steps from https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi to install this driver.
      
```
rg=rgblob
az group create -g $rg -l swedencentral
az aks create -g $rg -n aks --enable-blob-driver

az aks show -g $rg -n aks --query storageProfile.blobCsiDriver -otsv
True
```

```
# Alternate installation
az aks create -g $rg -n aks

# Here is a sample output below.
#   "storageProfile": {
#     "blobCsiDriver": null,

# To enable the Azure blob CSI driver.
az aks update --enable-blob-driver -g $rg -n aks

# Here is a sample output below.
# Please make sure there is no open-source Blob CSI driver installed before enabling. (y/N): y
# ...
#   "storageProfile": {
#     "blobCsiDriver": {
#       "enabled": true
```

```
# To get credentials for running commands further below.
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azureblob-fuse-premium   blob.csi.azure.com   Delete          Immediate              true                   74s
azureblob-nfs-premium    blob.csi.azure.com   Delete          Immediate              true                   74s

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-blob-node                1         1         1       1            1           <none>          44m

# To retrieve related pods.
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below. Each node has a csi-blob-node pod. This does not include controller pods unlike the open source version.
csi-blob-node-wvn8q                   3/3     Running   0          104m   10.224.0.4    aks-nodepool1-14487815-vmss000002   <none>           <none>
csi-blob-node-zlvql                   3/3     Running   0          104m   10.224.0.5    aks-nodepool1-14487815-vmss000000   <none>           <none>
csi-blob-node-zp2rl                   3/3     Running   0          104m   10.224.0.6    aks-nodepool1-14487815-vmss000001   <none>           <none>

# To know the image. 
kubectl get po -n kube-system csi-blob-node-wvn8q -oyaml | grep image: | grep blob

# Here is a sample output below.
#    image: mcr.microsoft.com/oss/kubernetes-csi/blob-csi:v1.19.5
```

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/nodeserver.go
- https://github.com/Azure/AKS/tree/master/vhd-notes
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-blob-storage
- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi
- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi#azure-blob-storage-csi-driver-features
- https://github.com/kubernetes-sigs/blob-csi-driver#usage (features)
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, Azure Blob Storage CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in blobfuse plugin would be incorporated into this driver.

## azureblob-fuse.driver.parameter
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#storage-class-parameters-for-dynamic-persistent-volumes

## azureblob-fuse.driver.parameter.isHnsEnabled
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: enable Hierarchical namespace for Azure DataLake storage account
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#before-you-begin: To support an Azure DataLake Gen2 storage account when using blobfuse mount...

## azureblob-fuse.driver.parameter.protocol.fuse

```
kubectl describe sc azureblob-fuse-premium
Name:                  azureblob-fuse-premium
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:
  -o allow_other
  --file-cache-timeout-in-seconds=120
  --use-attr-cache=true
  --cancel-list-on-mount-seconds=10
  -o attr_timeout=120
  -o entry_timeout=120
  -o negative_timeout=120
  --log-level=LOG_WARNING
  --cache-size-mb=1000
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>
```

## azureblob-fuse.driver.parameter.protocol.fuse.nfs

```
kubectl describe sc azureblob-nfs-premium
Name:                  azureblob-nfs-premium
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           blob.csi.azure.com
Parameters:            protocol=nfs,skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

## azureblob-fuse.driver.parameter.skuName.GRS

```
kubectl delete po mypod
kubectl delete pvc pvc-azureblob-fuse
kubectl delete sc azureblob-fuse-my
cat << EOF | k create -f -
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  labels:
    kubernetes.io/cluster-service: "true"
  name: azureblob-fuse-my
mountOptions:
- -o allow_other
- --file-cache-timeout-in-seconds=120
- --use-attr-cache=true
- --cancel-list-on-mount-seconds=10
- -o attr_timeout=120
- -o entry_timeout=120
- -o negative_timeout=120
- --log-level=LOG_WARNING
- --cache-size-mb=1000
parameters:
  skuName: Standard_GRS
provisioner: blob.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-my
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
EOF
kubectl get po -w
# kubectl describe pv

az storage account list -g MC_rgcni_akseadsv5_swedencentral | grep -E 'id|"name"'
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fuse414dbe20ef224a7a9ae",
    "name": "fuse414dbe20ef224a7a9ae",
      "name": "Premium_LRS",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fusec76e7488ea2047c9a2b",
    "name": "fusec76e7488ea2047c9a2b",
      "name": "Standard_GRS",
```

## azureblob-fuse.driver.parameter.skuName.LRS

```
kubectl describe sc azureblob-fuse-premium
Parameters:            skuName=Premium_LRS

az storage account list -g MC_rgcni_akseadsv5_swedencentral | grep -E 'id|"name"'
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fuse414dbe20ef224a7a9ae",
    "name": "fuse414dbe20ef224a7a9ae",
      "name": "Premium_LRS",
```

## azureblob-fuse.driver.parameter.useDataPlaneAPI aka storage account firewall: 

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: specify whether use data plane API for blob container create/delete, this could solve the SRP API throttling issue since data plane API has almost no limit, while it would fail when there is firewall or vnet setting on storage account i.e. make sure the storage account is not set to "Check Allow Access From (All Networks / Selected Networks)" "Selected Networks" i.e. set "Enabled from all networks" in the specified storage account
- https://learn.microsoft.com/en-us/answers/questions/1166011/getting-a-403-error-when-connecting-to-a-blob-cont: "Selected Networks" - It means the storage account is firewall enabled.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/controllerserver.go: if len(secrets) == 0 && useDataPlaneAPI {... "failed to GetStorageAccesskey on account
