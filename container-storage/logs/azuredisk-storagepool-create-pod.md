This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md), followed by adding the labeled node pool as described [here](storagepool-containerstorage_extension-create-nodepool.md) and creating the storage pool as mentioned [here](azuredisk-storagepool-create.md). 

```
# To create the persistent volume claim and the pod
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurediskpvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: acstor-azuredisk # replace with the name of your storage class if different
  resources:
    requests:
      storage: 100Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  nodeSelector:
    acstor.azure.com/io-engine: acstor
  volumes:
    - name: azurediskpv
      persistentVolumeClaim:
        claimName: azurediskpvc
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: azurediskpv
EOF
```

```
# To clean up
kubectl delete po fiopod
kubectl delete pvc azurediskpvc
```
