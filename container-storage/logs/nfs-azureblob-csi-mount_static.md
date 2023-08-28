```
# Replace the below with appropriate values.
rgname=secureshack2
clustername=aksblob
nodeResourceGroupName=$(az aks show --resource-group $rgname --name $clustername --query nodeResourceGroup -o tsv)
volumeHandle="vid$RANDOM"
storageAccountName="mystor$RANDOM"
containerName="c$RANDOM"
```

```
# To create the storage container TBD (use portal)
# az storage account create --kind BlockBlobStorage --sku Premium_LRS --access-tier Premium --enable-hierarchical-namespace true --enable-nfs-v3 true -g $rgname -n $storageAccountName --allow-blob-public-access true
# az storage container create --account-name $storageAccountName -n $containerName --public-access blob --auth-mode login

# To create the resources
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: blob.csi.azure.com
  name: pv-blob
spec:
  capacity:
    storage: 1Pi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain  # If set as "Delete" container would be removed after pvc deletion
  storageClassName: azureblob-nfs-premium
  csi:
    driver: blob.csi.azure.com
    readOnly: false
    # make sure volumeid is unique for every identical storage blob container in the cluster
    # character `#` is reserved for internal use and cannot be used in volumehandle
    volumeHandle: $volumeHandle
    volumeAttributes:
      resourceGroup: $nodeResourceGroupName
      storageAccount: $storageAccountName
      containerName: $containerName
      protocol: nfs
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-blob
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  volumeName: pv-blob
  storageClassName: azureblob-nfs-premium
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-blob
spec:
  nodeSelector:
    "kubernetes.io/os": linux
  containers:
    - image: mcr.microsoft.com/oss/nginx/nginx:1.17.3-alpine
      name: nginx-blob
      volumeMounts:
        - name: blob01
          mountPath: "/mnt/blob"
  volumes:
    - name: blob01
      persistentVolumeClaim:
        claimName: pvc-blob
EOF
```

```
# To display the resources
kubectl get po,pv,pvc

# To cleanup
kubectl delete po nginx-blob
kubectl delete pvc pvc-blob
kubectl delete pv pv-blob
```

- https://ovidiuborlean.medium.com/mount-azure-blob-containers-with-nfs-in-aks-cluster-23a07c591463
