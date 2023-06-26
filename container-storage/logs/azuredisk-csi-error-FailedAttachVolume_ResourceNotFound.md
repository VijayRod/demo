RCA: The "ResourceNotFound" error is self-explanatory. Ensure that a managed disk exists in the specified volumeHandle path of the persistent volume.

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
    volumeHandle: /subscriptions/dummys11-1111-1111-1111-111111111111/resourceGroups/resourceGroupName/providers/Microsoft.Compute/disks/myAKSDisk
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
# persistentvolume/pv-azuredisk   20Gi       RWO            Retain           Bound    default/pvc-azuredisk   managed-csi             69s
# 
# NAME                                  STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/pvc-azuredisk   Bound    pv-azuredisk   20Gi       RWO            managed-csi    69s
# 
# NAME        READY   STATUS              RESTARTS   AGE
# pod/mypod   0/1     ContainerCreating   0          68s
```

```
# Describe the pod.
kubectl describe pod mypod

# Here is a sample output below.
#  Warning  FailedAttachVolume  4s (x6 over 23s)  attachdetach-controller  AttachVolume.Attach failed for volume "pv-azuredisk" : rpc error: code = NotFound desc = Volume not found, failed with error: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 404, RawError: {"error":{"code":"ResourceNotFound","message":"The Resource 'Microsoft.Compute/disks/myAKSDisk' under resource group 'resourceGroupName' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix"}}
```

```
# To clean up the resources.
kubectl delete pod mypod
kubectl delete pvc pvc-azuredisk
kubectl delete pv pv-azuredisk
```
