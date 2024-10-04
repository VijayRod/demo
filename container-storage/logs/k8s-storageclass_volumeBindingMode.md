## sc.volumeBindingMode

```
kubectl describe sc | grep -e Provisioner -e VolumeBind
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
```

```
kubectl delete pvc pvc-azuredisk-wait pvc-azuredisk-immediate
kubectl delete sc scwait scimmediate
cat << EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: scwait
parameters:
  skuname: StandardSSD_LRS
provisioner: disk.csi.azure.com
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk-wait
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: scwait
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: scimmediate
parameters:
  skuname: StandardSSD_LRS
provisioner: disk.csi.azure.com
volumeBindingMode: Immediate # Default
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk-immediate
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: scimmediate
EOF
kubectl get pv,pvc

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                             STORAGECLASS   REASON   AGE
persistentvolume/pvc-fdbc8954-58e6-4d53-9753-7ec663404f81   10Gi       RWO            Delete           Bound    default/pvc-azuredisk-immediate   scimmediate             49s
NAME                                            STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-azuredisk-immediate   Bound     pvc-fdbc8954-58e6-4d53-9753-7ec663404f81   10Gi       RWO            scimmediate    53s
persistentvolumeclaim/pvc-azuredisk-wait        Pending                                                                        scwait         53s

kubectl describe pvc pvc-azuredisk-wait
  Normal  WaitForFirstConsumer  <invalid> (x7 over <invalid>)  persistentvolume-controller  waiting for first consumer to be created before binding
```  

```
kubectl delete po mypod
cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: pvc-azuredisk-wait
EOF
kubectl get pvc pvc-azuredisk-wait
# persistentvolumeclaim/pvc-azuredisk-wait        Bound    pvc-ab121f0e-76af-44ad-9281-c9cc92a50590   10Gi       RWO            scwait         62s
```
  
- https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode

### sc.volumeBindingMode.pv

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#binding

### sc.volumeBindingMode.pvc

```
# pv.azurefile
kubectl delete pvc pvc-azurefile
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-csi # VolumeBindingMode:  Immediate
EOF
kubectl get pvc -w

NAME            STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS    VOLUMEATTRIBUTESCLASS   AGE
pvc-azurefile   Pending                                      azurefile-csi   <unset>                 0s
pvc-azurefile   Pending   pvc-f42aa6f8-6ca1-4c21-8396-032f1ce9aee3   0                         azurefile-csi   <unset>                 24s
pvc-azurefile   Bound     pvc-f42aa6f8-6ca1-4c21-8396-032f1ce9aee3   100Gi      RWX            azurefile-csi   <unset>                 24s

# pv.azuredisk.dynamic
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
      storage: 10Gi
  storageClassName: managed-csi # VolumeBindingMode:     WaitForFirstConsumer
EOF
kubectl get pvc -w

pvc-azuredisk   Pending                                                                        managed-csi     <unset>                 0s

# pv.azuredisk.static
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

#### sc.volumeBindingMode.pvc.error "pod has unbound immediate PersistentVolumeClaims"

Pod is in a pending state with an error "pod has unbound immediate PersistentVolumeClaims".

```
>       Events:
>          Type     Reason            Age                From               Message
>          ----     ------            ----               ----               -------
>          Warning  FailedScheduling  27s (x2 over 27s)  default-scheduler  error while running >"VolumeBinding" filter plugin for pod "mysql-0": pod has unbound immediate PersistentVolumeClaims
```

- https://stackoverflow.com/questions/74741993/0-1-nodes-are-available-1-pod-has-unbound-immediate-persistentvolumeclaims: You need to create a PV in order to get a PVC bound...
- https://stackoverflow.com/questions/60774220/kubernetes-pod-has-unbound-immediate-persistentvolumeclaims: PersistentVolumeClaims will remain unbound indefinitely if a matching PersistentVolume does not exist. The PersistentVolume is matched with accessModes and capacity...
