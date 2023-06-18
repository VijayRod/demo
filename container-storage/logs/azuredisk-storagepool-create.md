This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). Afterward, create a pod with a persistent volume that utilizes the created storage class.

```
# Create the storage pool.
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



