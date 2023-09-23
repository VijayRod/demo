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
```

```
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
