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

```
kubectl get pv | grep nfs
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS              REASON   AGE
pvc-917a5c08-ad17-49ca-b10f-829e6238081e   250Gi      RWO            Delete           Bound    default/pvc-azurefile-nfs     azurefile-csi-nfs  13m

kubectl describe pv pvc-917a5c08-ad17-49ca-b10f-829e6238081e | grep VolumeH
    VolumeHandle:      mc_rgblob_aksblob_centralus#fa59c59b1608c402e85685a#pvcn-917a5c08-ad17-49ca-b10f-829e6238081e###default

nslookup fa59c59b1608c402e85685a.file.core.windows.net
fa59c59b1608c402e85685a.file.core.windows.net   canonical name = file.dsm07prdstf50a.store.core.windows.net.
Name:   file.dsm07prdstf50a.store.core.windows.net
Address: 20.60.241.redacted
```

```
kubectl delete po fiopod
kubectl delete pvc pvc-azurefile-nfs
kubectl delete sc azurefile-csi-nfs
```

- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#create-nfs-file-share-storage-class
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-files
