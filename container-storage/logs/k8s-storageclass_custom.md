```
kubectl delete po fiopod
kubectl delete pvc pvc-azuredisk
kubectl delete sc azuredisk-custom
kubectl delete sc azurefile-custom

# To create the resources
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azuredisk-custom
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: azurefile-custom
provisioner: file.csi.azure.com # replace with "kubernetes.io/azure-file" if aks version is less than 1.21
allowVolumeExpansion: true
mountOptions:
 - dir_mode=0777
 - file_mode=0777
 - uid=0
 - gid=0
 - mfsymlinks
 - cache=strict
 - actimeo=30
parameters:
  skuName: Premium_LRS
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: azuredisk-custom # Or azurefile-custom
  resources:
    requests:
      storage: 250Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  volumes:
    - name: azuredisk
      persistentVolumeClaim:
        claimName: pvc-azuredisk
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: azuredisk
EOF
kubectl get po,pv,pvc,sc
```

- https://kubernetes.io/docs/concepts/storage/storage-classes/
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#built-in-storage-classes
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#create-a-storage-class
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#storage-classes
