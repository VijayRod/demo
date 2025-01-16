## san

- https://www.techtarget.com/searchstorage/tip/Choosing-your-storage-networking-protocol: Fibre Channel was created to support SANs and address the shortcomings in SCSI and High-Performance Parallel Interface (HIPPI). It offers a reliable and scalable protocol and interface with high throughput and low latency, making it well suited for shared network storage. When used with optical fiber, Fibre Channel can support devices as far as 10 km apart.

## san.app.k8s.csi.acstor

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san

## san.app.k8s.csi.acstor.azuresan.storagepool.create

This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). After creating the storage pool, proceed to create a pod with a persistent volume that utilizes the newly created storage class.

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

## san.app.k8s.csi.acstor.azuresan.storagepool.create.pod

This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md), followed by adding the labeled node pool as described [here](storagepool-containerstorage_extension-create-nodepool.md), and finally creating the storage pool as mentioned [here](azuresan-storagepool-create.md). 

```
# Create the persistent volume claim and the pod.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: managedpvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: acstor-managed # replace with the name of your storage class if different
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
    - name: managedpv
      persistentVolumeClaim:
        claimName: managedpvc
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: managedpv
EOF
```
