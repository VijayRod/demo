RCA: The "AuthorizationFailed" error is self-explanatory. To resolve this, ensure that the object ID is granted the necessary access. You can follow the steps mentioned in the documentation at https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/error-code-linkedauthorizationfailed. Alternatively, you can use the az role assignment create command to grant the required permission to the object ID. Refer to the steps provided at https://learn.microsoft.com/en-us/azure/role-based-access-control/troubleshooting?tabs=bicep#symptom---unable-to-assign-a-role for more information.

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
# persistentvolume/pv-azuredisk   20Gi       RWO            Retain           Bound    default/pvc-azuredisk   managed-csi             64s
# 
# NAME                                  STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/pvc-azuredisk   Bound    pv-azuredisk   20Gi       RWO            managed-csi    64s
# 
# NAME        READY   STATUS              RESTARTS   AGE
# pod/mypod   0/1     ContainerCreating   0          64s
```

```
# Describe the pod.
kubectl describe pod mypod

# Here is a sample output below.
#  Warning  FailedAttachVolume  6s (x6 over 25s)  attachdetach-controller  AttachVolume.Attach failed for volume "pv-azuredisk" : rpc error: code = NotFound desc = Volume not found, failed with error: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 403, RawError: {"error":{"code":"AuthorizationFailed","message":"The client 'fefa5592-61de-4329-91e9-42073b8363bc' with object id 'fefa5592-61de-4329-91e9-42073b8363bc' does not have authorization to perform action 'Microsoft.Compute/disks/read' over scope '/subscriptions/dummys11-1111-1111-1111-111111111111/resourceGroups/resourceGroupName/providers/Microsoft.Compute/disks/myAKSDisk' or the scope is invalid. If access was recently granted, please refresh your credentials."}}
```

```
# To clean up the resources.
kubectl delete pod mypod
kubectl delete pvc pvc-azuredisk
kubectl delete pv pv-azuredisk
```

To resolve this issue, grant the necessary permissions to the object ID. For example, you can use the following command to grant the required permissions and then retry the previous operation:

```
# Run in Azure CLI. Replace with the actual object ID and with the appropriate scope for your scenario. 
az role assignment create --assignee-object-id fefa5592-61de-4329-91e9-42073b8363bc  --role "Contributor" --scope "/subscriptions/dummys11-1111-1111-1111-111111111111/resourceGroups/resourceGroupName"
```
