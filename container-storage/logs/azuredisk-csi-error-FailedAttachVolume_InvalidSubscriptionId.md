RCA: The "InvalidSubscriptionId" error is self-explanatory. To resolve this issue, ensure that you provide a valid subscription ID in the volume handle of the persistent volume.

```
# Create a persistent volume, persistent volume claim and pod.
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
    volumeHandle: /subscriptions/<subscriptionID>/resourceGroups/resourceGroupName/providers/Microsoft.Compute/disks/myAKSDisk
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
  - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
    name: mypod
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
    - name: azure
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
```

```
# Display information about the persistent volume, persistent volume claim and pod (pv and pvc are in bound status, pod is stuck in ContainerCreating status).
kubectl get pv,pvc,pod

# Here is a sample output below.
# NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
# persistentvolume/pv-azuredisk   20Gi       RWO            Retain           Bound    default/pvc-azuredisk   managed-csi             62s
# 
# NAME                                  STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/pvc-azuredisk   Bound    pv-azuredisk   20Gi       RWO            managed-csi    62s
# 
# NAME        READY   STATUS              RESTARTS   AGE
# pod/mypod   0/1     ContainerCreating   0          62s
```

```
# Describe the pod.
kubectl describe pod mypod

# Here is a sample output below.
#  Warning   FailedAttachVolume   pod/mypod    AttachVolume.Attach failed for volume "pv-azuredisk" : rpc error: code = NotFound desc = Volume not found, failed with error: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 400, RawError: {"error":{"code":"InvalidSubscriptionId","message":"The provided subscription identifier '<subscriptionID>' is malformed or invalid."}}
```

```
# To clean up the resources.
kubectl delete pod mypod
kubectl delete pvc pvc-azuredisk
kubectl delete pv pv-azuredisk
```
