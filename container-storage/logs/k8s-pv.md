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

## pv.provision.static

```
# az disk delete -g MC_rg_aks_swedencentral -n disk
az disk create -g MC_rg_aks_swedencentral -n disk --size-gb 20 --query id --output tsv
diskId=$(az disk show -g MC_rg_aks_swedencentral -n disk --query id -otsv)
kubectl delete pv pv-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: disk.csi.azure.com
  name: pv-azuredisk
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: managed-csi
  csi:
    driver: disk.csi.azure.com
    volumeHandle: $diskId
    volumeAttributes:
      fsType: ext4
EOF
kubectl get pv
kubectl delete pvc pvc-azuredisk
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
      storage: 20Gi
  volumeName: pv-azuredisk
  storageClassName: managed-csi
EOF
kubectl get pvc

kubectl get pv -w
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-azuredisk   20Gi       RWO            Retain           Pending               managed-csi    <unset>            0s
pv-azuredisk   20Gi       RWO            Retain           Available             managed-csi    <unset>            0s
pv-azuredisk   20Gi       RWO            Retain           Available     default/pvc-azuredisk   managed-csi    <unset>                          14s
pv-azuredisk   20Gi       RWO            Retain           Bound         default/pvc-azuredisk   managed-csi    <unset>                          14s
kubectl get pvc -w
NAME            STATUS    VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-azuredisk   Pending       pv-azuredisk   0                         managed-csi    <unset>                 0s
pvc-azuredisk   Bound         pv-azuredisk   20Gi       RWO            managed-csi    <unset>                 15s
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#statically-provision-a-volume

## pv.reclaimPolicy

```
kubectl describe pv task-pv-volume
Reclaim Policy:  Delete
```

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection: volumes can either be Retained, Recycled, or Deleted.

## pv.status.bound

```
storageclass.volumeBindingMode
```
