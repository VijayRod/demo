This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). The disk for the storage pool is created in the MC_ node resource group by the Azure Container Storage orchestrator. 

```
cat << EOF | kubectl apply -f -
apiVersion: containerstorage.azure.com/v1alpha1
kind: StoragePool
metadata:
  name: azuredisk
  namespace: acstor
spec:
  poolType:
    azureDisk: {}
  resources:
    requests: {"storage": 1Ti}
EOF
```

```
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
# Cleanup.
kubectl delete pod fiopod
kubectl delete pvc azurediskpvc
kubectl delete storagepool azuredisk -n acstor
```
