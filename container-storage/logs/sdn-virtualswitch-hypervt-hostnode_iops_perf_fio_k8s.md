> ## fio.k8s

```
# determinants: disk size, disk type (e.g., standard ssd), virtualization (e.g., accelerated networking), vm size (e.g., nvme), vm node image, vm osdisk size and type (e.g., 128 GB Ephemeral), pv accessModes of ReadWriteOnce
```
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssds
- https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1 --enable-blob-driver
az aks get-credentials -g $rg -n aks --overwrite-existing

size=100Gi
kubectl delete pods --all
kubectl delete pvc --all
kubectl delete sc azurefile-csi-nfs
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi-nfs
provisioner: file.csi.azure.com
allowVolumeExpansion: true
parameters:
  protocol: nfs
mountOptions:
  - nconnect=4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
  annotations:
        volume.beta.kubernetes.io/storage-class: azureblob-fuse-premium
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-premium
  resources:
    requests:
      storage: $size
---
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
      storage: $size
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-nfs
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: azurefile-csi-nfs
  resources:
    requests:
      storage: $size
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-smb
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-premium
  resources:
    requests:
      storage: $size
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk-scsi
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: $size
  storageClassName: managed-csi-premium
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
      - mountPath: /mnt/azureblob-fuse
        name: volume-azureblob-fuse
      - mountPath: /mnt/azureblob-nfs
        name: volume-azureblob-nfs
      - mountPath: /mnt/azuredisk-scsi  
        name: volume-azuredisk-scsi  
      - mountPath: /mnt/azurefile-nfs
        name: volume-azurefile-nfs
      - mountPath: /mnt/azurefile-smb
        name: volume-azurefile-smb
  volumes:
    - name: volume-azureblob-fuse
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
    - name: volume-azureblob-nfs
      persistentVolumeClaim:
        claimName: pvc-azureblob-nfs
    - name: volume-azuredisk-scsi
      persistentVolumeClaim:
        claimName: pvc-azuredisk-scsi
    - name: volume-azurefile-nfs
      persistentVolumeClaim:
        claimName: pvc-azurefile-nfs
    - name: volume-azurefile-smb
      persistentVolumeClaim:
        claimName: pvc-azurefile-smb
EOF
sleep 20
kubectl get pv,pvc,sc
kubectl describe pv | grep VolumeH
kubectl get po -owide
kubectl exec -it fiopod -- ls /mnt
```

```
# clear
kubectl exec -it fiopod -- fio --name=benchtest --size=10g --filename=/mnt/azureblob-fuse/test --direct=1 --rw=randwrite --ioengine=libaio --bs=4k --iodepth=256 --numjobs=4 --time_based --runtime=30
kubectl exec -it fiopod -- fio --name=benchtest --size=10g --filename=/mnt/azureblob-nfs/test --direct=1 --rw=randwrite --ioengine=libaio --bs=4k --iodepth=256 --numjobs=4 --time_based --runtime=30
kubectl exec -it fiopod -- fio --name=benchtest --size=10g --filename=/mnt/azurefile-nfs/test --direct=1 --rw=randwrite --ioengine=libaio --bs=4k --iodepth=256 --numjobs=4 --time_based --runtime=30
kubectl exec -it fiopod -- fio --name=benchtest --size=10g --filename=/mnt/azurefile-smb/test --direct=1 --rw=randwrite --ioengine=libaio --bs=4k --iodepth=256 --numjobs=4 --time_based --runtime=30
kubectl exec -it fiopod -- fio --name=benchtest --size=10g --filename=/mnt/azuredisk-scsi/test --direct=1 --rw=randwrite --ioengine=libaio --bs=4k --iodepth=256 --numjobs=4 --time_based --runtime=30
date
```

> ## fio.standard-ssd
```
# managed-csi: skuname=StandardSSD_LRS
size=100Gi
kubectl delete po pvc-azuredisk-scsi
kubectl delete pvc pvc-azuredisk-scsi
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk-scsi
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: $size
  storageClassName: managed-csi
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
      - mountPath: /mnt/azuredisk-scsi  
        name: volume-azuredisk-scsi  
  volumes:
    - name: volume-azuredisk-scsi
      persistentVolumeClaim:
        claimName: pvc-azuredisk-scsi
EOF
kubectl get po -owide -w
kubectl get pv,pvc,sc
kubectl describe pv | grep VolumeH

kubectl exec -it fiopod -- fio --name=benchtest --size=10g --filename=/mnt/azuredisk-scsi/test --direct=1 --rw=randwrite --ioengine=libaio --bs=4k --iodepth=256 --numjobs=4 --time_based --runtime=30
date
```
