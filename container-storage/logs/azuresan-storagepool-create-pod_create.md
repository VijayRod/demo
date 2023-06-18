This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). 

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
