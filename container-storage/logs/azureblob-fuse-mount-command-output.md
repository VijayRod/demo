### Mount command output

```
# kubectl exec -it nginx-blob -- df -h | grep fuse
blobfuse2               123.9G     23.6G    100.3G  19% /mnt/blob

# kubectl exec -it nginx-blob -- mount | grep fuse
blobfuse2 on /mnt/blob type fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other)

# kubectl exec -it nginx-blob -- mount -t fuse
blobfuse2 on /mnt/blob type fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other)
```

### Steps for the above

After creating a storage account with a container, and setting up the secret, the Persistent Volume (PV) mount was created using the steps mentioned in the [official Azure documentation](https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-blobfuse%2Csecret).

First, create the secret:

```
kubectl create secret generic azure-secret --from-literal azurestorageaccountname=vrblobstor --from-literal azurestorageaccountkey="KEY" --type=Opaque
```

Then, apply the following YAML configuration:

```
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: blob.csi.azure.com
  name: pv-blob
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain  # If set as "Delete," the container would be removed after PVC deletion
  storageClassName: azureblob-fuse-premium
  mountOptions:
    - -o allow_other
    - --file-cache-timeout-in-seconds=120
  csi:
    driver: blob.csi.azure.com
    readOnly: false
    # volumeid has to be unique for every identical storage blob container in the cluster
    # character `#` is reserved for internal use and cannot be used in volumehandle
    volumeHandle: a123456
    volumeAttributes:
      containerName: mycontainer
    nodeStageSecretRef:
      name: azure-secret
      namespace: default
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-blob
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  volumeName: pv-blob
  storageClassName: azureblob-fuse-premium
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-blob
spec:
  nodeSelector:
    "kubernetes.io/os": linux
  containers:
    - image: mcr.microsoft.com/oss/nginx/nginx:1.17.3-alpine
      name: nginx-blob
      volumeMounts:
        - name: blob01
          mountPath: "/mnt/blob"
  volumes:
    - name: blob01
      persistentVolumeClaim:
        claimName: pvc-blob
EOF
```

To view the Persistent Volume (PV), use the following command:

```
kubectl get pv,pvc,po
```

To clean up, execute the following commands:

```
kubectl delete po/nginx-blob
kubectl delete pvc/pvc-blob
kubectl delete pv/pv-blob
```

Feel free to ask if you have any further questions!
