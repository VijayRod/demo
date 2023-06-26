RCA: The error "ParentResourceNotFound" can occur when the specified storage account defined in the storage class doesn't exist or when the resourceGroup parameter and value are not specified in the storage class. To resolve this, ensure the storage account exists and include the resourceGroup parameter in the storage class with the appropriate value.

```
# Create a custom storage class and a persistent volume claim.
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: private-azurefile-csi
provisioner: file.csi.azure.com
allowVolumeExpansion: true
parameters:
  storageAccount: azprodstorage0626
  server: azprodstorage0626.file.core.windows.net 
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=0
  - gid=0
  - mfsymlinks
  - cache=strict  # https://linux.die.net/man/8/mount.cifs
  - nosharesock  # reduce probability of reconnect race
  - actimeo=30  # reduce latency for metadata-heavy workload
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: private-azurefile-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: private-azurefile-csi
  resources:
    requests:
      storage: 100Gi
EOF
```

```
# Display information about the persistent volume and the persistent volume claim (no pv in the output and pvc is in Pending state).
kubectl get pv,pvc

# Here is a sample output below.
# NAME                                          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS            AGE
# persistentvolumeclaim/private-azurefile-pvc   Pending                                      private-azurefile-csi   29s
```

```
# Describe the persistent volume claim.
kubectl describe pvc private-azurefile-pvc

# Here is a sample output below.
#  Warning  ProvisioningFailed    11s (x5 over 26s)  file.csi.azure.com_csi-azurefile-controller-5dc77fc85b-wznhl_2bc06242-e5a8-4f9e-971f-71be4ceca27a  failed to provision volume with StorageClass "private-azurefile-csi": rpc error: code = Internal desc = storage.FileSharesClient#Get: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="ParentResourceNotFound" Message="Can not perform requested operation on nested resource. Parent resource 'azprodstorage0626' not found."
```

```
# Cleanup
k delete pvc private-azurefile-pvc
k delete sc private-azurefile-csi
```

To resolve the issue, add the "resourceGroup" parameter in the storage class.

```
# Create a custom storage class and a persistent volume claim.
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: private-azurefile-csi
provisioner: file.csi.azure.com
allowVolumeExpansion: true
parameters:
  resourceGroup: resourceGroupName
  storageAccount: azprodstorage0626
  server: azprodstorage0626.file.core.windows.net 
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=0
  - gid=0
  - mfsymlinks
  - cache=strict  # https://linux.die.net/man/8/mount.cifs
  - nosharesock  # reduce probability of reconnect race
  - actimeo=30  # reduce latency for metadata-heavy workload
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: private-azurefile-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: private-azurefile-csi
  resources:
    requests:
      storage: 100Gi
EOF      
```

```
# Display information about the persistent volume and the persistent volume claim.
kubectl get pv,pvc

# Here is a sample output below.
# NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                           STORAGECLASS            REASON   AGE
# persistentvolume/pvc-12639778-ce3e-4c0a-aca0-73e9c54791f9   100Gi      RWX            Delete           Bound    default/private-azurefile-pvc   private-azurefile-csi            13s
#
# NAME                                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
# persistentvolumeclaim/private-azurefile-pvc   Bound    pvc-12639778-ce3e-4c0a-aca0-73e9c54791f9   100Gi      RWX            private-azurefile-csi   14s
```
