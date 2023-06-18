This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). 

```
# Create the storage pool.
cat << EOF | kubectl apply -f -
apiVersion: containerstorage.azure.com/v1alpha1
kind: StoragePool
metadata:
  name: managed
  namespace: acstor
spec:
  poolType:
    elasticSan: {}
  resources:
    requests: {"storage": 1Ti}
EOF
```
