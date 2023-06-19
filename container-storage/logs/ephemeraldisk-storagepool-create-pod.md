This page follows the steps outlined in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk, incorporating the addition of the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md), followed by adding the labeled node pool and creating the storage pool according to the instructions provided [here](ephemeraldisk-storagepool-create.md).

```
# Create the persistent volume claim and the pod.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ephemeralpvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: acstor-ephemeraldisk # replace with the name of your storage class if different
  resources:
    requests:
      storage: 1Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  nodeSelector:
    acstor.azure.com/io-engine: acstor
    kubernetes.azure.com/agentpool: npnvme
  volumes:
    - name: ephemeralpv
      persistentVolumeClaim:
        claimName: ephemeralpvc
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: ephemeralpv
EOF
```
