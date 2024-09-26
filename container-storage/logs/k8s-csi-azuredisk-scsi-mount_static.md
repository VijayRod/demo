```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)

diskUri=$(az disk create -g $noderg -n myAKSDisk --size-gb 20 --query id --output tsv)

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
    readOnly: false
    volumeHandle: $diskUri # unique value
    volumeAttributes:
      fsType: ext4
---
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
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
    - name: azure
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get po,pv,pvc
# kubectl delete po mypod; kubectl delete pvc pvc-azuredisk; kubectl delete pv pv-azuredisk
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#statically-provision-a-volume
