```
TBD

# To create the resources
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-nfs
  annotations:
        volume.beta.kubernetes.io/storage-class: azureblob-nfs-premium
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-nfs-premium
  resources:
    requests:
      storage: 100Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
    volumeMounts:
    - mountPath: /mnt/data
      name: azureblob
  volumes:
    - name: azureblob
      persistentVolumeClaim:
        claimName: pvc-azureblob-nfs
EOF
```
