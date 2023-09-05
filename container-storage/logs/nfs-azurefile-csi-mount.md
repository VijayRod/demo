```
kubectl delete po fiopod
kubectl delete pvc pvc-azurefile-nfs
kubectl delete sc azurefile-csi-nfs

# To create the resources
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi-nfs
provisioner: file.csi.azure.com
allowVolumeExpansion: true
parameters:
  protocol: nfs
mountOptions:
  - nconnect=4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-nfs
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: azurefile-csi-nfs
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
        claimName: pvc-azurefile-nfs
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

- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#create-nfs-file-share-storage-class
