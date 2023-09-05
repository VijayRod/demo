TBD

```
# To create the resources
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: managed-csi-premium
  resources:
    requests:
      storage: 250Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  nodeSelector:
    kubernetes.azure.com/agentpool: d4s3
  volumes:
    - name: azuredisk
      persistentVolumeClaim:
        claimName: pvc-azuredisk
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
```

- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-disk
