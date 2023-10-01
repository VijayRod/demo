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
reclaimPolicy: Delete # Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
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
kubectl exec nginx-azuredisk -- ls /mnt/azuredisk
## lost+found
kubectl exec nginx-azuredisk -- touch /mnt/azuredisk/myfile

## kubectl get pv pvc-78be510e-8dad-485d-9446-98d1cc4f8e1c
kubectl patch pv pvc-78be510e-8dad-485d-9446-98d1cc4f8e1c -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}' --type=merge # PV Retain

kubectl delete po nginx-azuredisk nginx-azuredisk2
kubectl delete pvc pvc-azuredisk pvc-azuredisk2 # PVC delete
kubectl patch pv pvc-78be510e-8dad-485d-9446-98d1cc4f8e1c --type=json -p='[{"op": "remove", "path": "/spec/claimRef"}]' # PV delete claimRef

cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk2
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: default-custom
  volumeName: pvc-78be510e-8dad-485d-9446-98d1cc4f8e1c # PVC volumeName
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk2
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
        claimName: pvc-azuredisk2
EOF
sleep 30
kubectl get po,pv,pvc
kubectl exec nginx-azuredisk2 -- ls /mnt/azuredisk

lost+found
myfile
```

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recovering-from-failure-when-expanding-volumes: Re-create the PVC with smaller size than PV and set volumeName field of the PVC to the name of the PV
