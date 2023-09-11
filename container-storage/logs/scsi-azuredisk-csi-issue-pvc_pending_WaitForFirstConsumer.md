RCA: The PVC (Persistent Volume Claim) in a pending state with WaitForFirstConsumer indicates that the binding and provisioning of the persistent volume are delayed until a pod using the persistent volume claim is created. This behaviour is expected and more information can be found at https://kubernetes.io/docs/concepts/storage/storage-classes/#volume-binding-mode. To resolve this, you can create a pod that uses the persistent volume claim.

```
# Create the pvc.
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
EOF
```

```
# kubectl get pvc my-azuredisk has the pending state.
NAME           STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        AGE
my-azuredisk   Pending                                                                        default             2s

# kubectl describe pvc my-azuredisk shows the reason "WaitForFirstConsumer".
Name:          my-azuredisk
Namespace:     default
StorageClass:  default
Status:        Pending
Volume:
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:
Access Modes:
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type    Reason                Age                From                         Message
  ----    ------                ----               ----                         -------
  Normal  WaitForFirstConsumer  16s (x2 over 25s)  persistentvolume-controller  waiting for first consumer to be created before binding
  
# kubectl get sc default has the VOLUMEBINDINGMODE as WaitForFirstConsumer.
NAME                PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
default (default)   disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   16d  
```  

```  
# Create the pod.
cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: my-azuredisk
EOF

# kubectl get pvc my-azuredisk now has the bound state.
NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
my-azuredisk   Bound    pvc-f3bc5dc9-8802-4d24-a130-a4720c9475bc   100Gi      RWO            default        32s
```

```
# Cleanup.
kubectl delete po mypod
kubectl delete pvc my-azuredisk
```
