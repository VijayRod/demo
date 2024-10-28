## k8s-storageclass.allowVolumeExpansion

```
kubectl delete po nginx-azuredisk
kubectl delete pvc pvc-azuredisk
kubectl delete sc default-custom
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: default-custom
parameters:
  skuname: StandardSSD_LRS
provisioner: disk.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: false # false
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
      storage: 10Gi
  storageClassName: default-custom
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
        - name: azuredisk01
          mountPath: /mnt/azuredisk
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get po,pv,pvc
kubectl patch pvc pvc-azuredisk -p '{"spec":{"resources":{"requests":{"storage":"300Gi"}}}}' --type=merge
```

```
Error from server (Forbidden): persistentvolumeclaims "pvc-azuredisk" is forbidden: only dynamically provisioned pvc can be resized and the storageclass that provisions the pvc must support resize
```
  
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/: You can only expand a PVC if its storage class's allowVolumeExpansion field is set to true.
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#csi-volume-expansion
- https://github.com/kubernetes-sigs/azurefile-csi-driver/issues/573: you should resize pvc instead of pv
- https://kubernetes.io/blog/2022/05/05/volume-expansion-ga/#storage-driver-support
