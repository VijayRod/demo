Root cause: One reason for the error "Volume capability not supported" in the describe of a Persistent Volume Claim (PVC), along with both the pod and PVC being in a `pending` state, is that the PVC is associated with an Azure disk. This association can occur either through an explicitly defined storage class in the PVC or the default storage class. The error occurs because an Azure disk can only be mounted with the AccessMode type `ReadWriteOnce`, not `ReadWriteMany`, as mentioned in https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision. This is also indicated in https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes. To resolve this issue, either recreate the PVC with `ReadWriteOnce` or create a `ReadWriteMany` PVC that uses an Azure File storage class.

```
# Create the persistent volume claim and the pod.
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: azure-managed-disk-many
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod-many
spec:
  containers:
    - name: mypod
      image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
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
        claimName: azure-managed-disk-many
EOF
```

```
# Display information about the created persistent volume claim and the pod (both will be in a pending state).
kubectl get po,pvc

# Here is a sample output below.
#
# NAME                          READY   STATUS             RESTARTS         AGE
# pod/mypod-many                0/1     Pending            0                38m
#
# NAME                                            STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/azure-managed-disk-many   Pending                                      default        38m
```

```
# Describe the persistent volume claim.
kubectl describe pvc azure-managed-disk-many

# Here is a sample output below.
# Warning  ProvisioningFailed    30s (x8 over 2m37s)   disk.csi.azure.com_csi-azuredisk-controller-76d4f9c85f-2zlqd_45efaf4e-7105-4dbf-9df7-81e812cf3a5e  failed to provision volume with StorageClass "default": rpc error: code = InvalidArgument desc = Volume capability not supported
```

```
# Cleanup.  
kubectl delete pod/mypod-many
kubectl delete persistentvolumeclaim/azure-managed-disk-many
```

Here's a sample with `ReadWriteOnce` to resolve this.

```
# Create the persistent volume claim and the pod.
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: azure-managed-disk
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
    - name: mypod
      image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
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
        claimName: azure-managed-disk
EOF
```

```
# Display information about the created persistent volume claim and the pod.
kubectl get po,pvc

# Here is a sample output below.
#
# NAME                          READY   STATUS             RESTARTS         AGE
# pod/mypod                     1/1     Running            0                23s
# 
# NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/azure-managed-disk   Bound    pvc-22746172-f4c5-4d68-88b7-5a46add212b7   5Gi        RWO            default        24s
```

```
# Cleanup.  
kubectl delete pod/mypod
kubectl delete persistentvolumeclaim/azure-managed-disk
```

Another way to resolve this is using `ReadWriteMany` with an Azure File resource through an Azure File storage class.

```
# Create the persistent volume claim and the pod.
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: pvc-azurefile
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azurefile
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod-file
spec:
  containers:
    - name: mypod
      image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
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
        claimName: pvc-azurefile
EOF
```

```
# Display information about the created persistent volume claim and the pod.
kubectl get po,pvc

# Here is a sample output below.
#
# NAME                          READY   STATUS             RESTARTS         AGE
# pod/mypod-file                1/1     Running            0                33s
# 
# NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/pvc-azurefile   Bound    pvc-4b569404-9ab1-4b97-9308-46f16bfff99d   5Gi        RWX            azurefile      33s
```

```
# Cleanup.  
kubectl delete pod/mypod-file
kubectl delete persistentvolumeclaim/pvc-azurefile
```
