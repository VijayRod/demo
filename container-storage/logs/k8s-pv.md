## pv

```
kubectl api-resources | grep pv
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
persistentvolumeclaims              pvc                 v1                                     true         PersistentVolumeClaim
persistentvolumes                   pv                  v1                                     false        PersistentVolume
```

To manually define a persistent volume instead of using a persistent volume class, use the steps to statically provision a volume.

```
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: default
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
        - name: azuredisk01
          mountPath: "/mnt/azuredisk"
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get po,pv,pvc
# kubectl delete po nginx-azuredisk; kubectl delete pvc pvc-azuredisk
```
    
- https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#volume-v1-core
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#volumes
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#persistent-volumes

## pv.delete

```
kubectl describe pv task-pv-volume
Reclaim Policy:  Delete
```

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection: volumes can either be Retained, Recycled, or Deleted.
