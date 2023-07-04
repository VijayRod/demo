The "Permission denied" mount error is likely caused by an incorrect storage account name or key in the secret, as indicated in the GitHub comment at https://github.com/Azure/AKS/issues/2383#issuecomment-859539446. To fix this issue, consider deleting the existing secret and creating a new one with the accurate storage account name and key. You can find additional reasons for this error in the Microsoft troubleshooting documentation available at https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-file-share#mounterror13.

```
# Replace the below with appropriate values.
rgname=
clustername=aks
storageAccountName="mystorageacct$RANDOM"
shareName=aksshare
```

```
# To retrieve the node resource group name for the cluster.
nodeResourceGroupName=$(az aks show --resource-group $rgname --name $clustername --query nodeResourceGroup -o tsv)

# To create the storage account.
az storage account create -g $nodeResourceGroupName -n $storageAccountName --sku Premium_LRS --kind FileStorage --enable-large-file-share --output none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $nodeResourceGroupName -n $storageAccountName -o tsv)
STORAGE_KEY=$(az storage account keys list -g $nodeResourceGroupName --account-name $storageAccountName --query "[0].value" -o tsv)
echo Storage account key: $STORAGE_KEY

# To create the file share.
az storage share create -n $shareName --connection-string $AZURE_STORAGE_CONNECTION_STRING
```

```
# To create the kubernetes secret.
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storageAccountName --from-literal=azurestorageaccountkey=$STORAGE_KEY
```

```
# To regenerate the access key for the storage account in this TEST environment.
az storage account keys renew -g $nodeResourceGroupName -n $storageAccountName --key key1 -o none

# Alternatively, you can recreate the storage account with the same name in this TEST environment, as doing so will results in new keys.
# az storage account delete -g $rgname -n $storageAccountName -y
# az storage account create -g $nodeResourceGroupName -n $storageAccountName --sku Premium_LRS --kind FileStorage --enable-large-file-share --output none
# export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $nodeResourceGroupName -n $storageAccountName -o tsv)
# az storage share create -n $shareName --connection-string $AZURE_STORAGE_CONNECTION_STRING
```

```
# To create the kubernetes static persistent volume, persistent volume claim, and pod.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: file.csi.azure.com
  name: azurefile
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: azurefile-premium
  csi:
    driver: file.csi.azure.com
    readOnly: false
    volumeHandle: id123456  # make sure this volumeid is unique for every identical share in the cluster
    volumeAttributes:
      resourceGroup: $nodeResourceGroupName  # optional, only set this when storage account is not in the same resource group as node
      shareName: $shareName
    nodeStageSecretRef:
      name: azure-secret
      namespace: default
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    - uid=0
    - gid=0
    - mfsymlinks
    - cache=strict
    - nosharesock
    - nobrl
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azurefile-premium
  volumeName: azurefile
  resources:
    requests:
      storage: 5Gi
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
      claimName: azurefile
EOF
```

```
# To display information about the resources.
kubectl get po,pv,pvc

# Here is a sample output below. The pod is in the "ContainerCreating" state.
NAME        READY   STATUS              RESTARTS   AGE
pod/mypod   0/1     ContainerCreating   0          12s
NAME                         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS        REASON   AGE
persistentvolume/azurefile   5Gi        RWX            Retain           Bound    default/azurefile   azurefile-premium            13s
NAME                              STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS        AGE
persistentvolumeclaim/azurefile   Bound    azurefile   5Gi        RWX            azurefile-premium   12s

# To describe the pod.
kubectl describe po mypod

# Here is a sample output below.
  Warning  FailedMount  8s (x6 over 24s)  kubelet            MountVolume.MountDevice failed for volume "azurefile" : rpc error: code = Internal desc = volume(id123456) mount //mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount failed with mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o dir_mode=0777,file_mode=0777,uid=0,gid=0,mfsymlinks,cache=strict,nosharesock,nobrl,actimeo=30,<masked> //mystorageacct23534.file.core.windows.net/aksshare /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount
Output: mount error(13): Permission denied
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
```

```
# To view the node syslog for the volume.
cat /var/log/syslog

# Here is a sample output below.
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kubelet[1679]: I0630 19:21:27.505248    1679 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"azurefile\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^id123456\") pod \"mypod\" (UID: \"efa51ab7-5ecb-4910-a25f-1be61e02b47d\") " pod="default/mypod"
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kubelet[1679]: I0630 19:21:27.605742    1679 reconciler.go:269] "operationExecutor.MountVolume started for volume \"azurefile\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^id123456\") pod \"mypod\" (UID: \"efa51ab7-5ecb-4910-a25f-1be61e02b47d\") " pod="default/mypod"
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kernel: [ 5227.915396] CIFS: Attempting to mount \\mystorageacct23534.file.core.windows.net\aksshare
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kernel: [ 5227.922476] CIFS: Status code returned 0xc000006d STATUS_LOGON_FAILURE
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kernel: [ 5227.922486] CIFS: VFS: \\mystorageacct23534.file.core.windows.net Send error in SessSetup = -13
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kernel: [ 5227.928799] CIFS: VFS: cifs_mount failed w/return code = -13
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kubelet[1679]: E0630 19:21:27.648172    1679 csi_attacher.go:345] kubernetes.io/csi: attacher.MountDevice failed: rpc error: code = Internal desc = volume(id123456) mount //mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount failed with mount failed: exit status 32
Jun 30 19:21:27 aks-nodepool1-51397738-vmss000005 kubelet[1679]: E0630 19:21:27.648668    1679 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/csi/file.csi.azure.com^id123456 podName: nodeName:}" failed. No retries permitted until 2023-06-30 19:21:28.148649949 +0000 UTC m=+5201.922446133 (durationBeforeRetry 500ms). Error: MountVolume.MountDevice failed for volume "azurefile" (UniqueName: "kubernetes.io/csi/file.csi.azure.com^id123456") pod "mypod" (UID: "efa51ab7-5ecb-4910-a25f-1be61e02b47d") : rpc error: code = Internal desc = volume(id123456) mount //mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount failed with mount failed: exit status 32

# Then follow the retries after 1s, 2s, 4s, 8s, 16s, 32s, 1m4s, 2m2s, etc. as mentioned in the log entries.
Jun 30 19:21:28 aks-nodepool1-51397738-vmss000005 kubelet[1679]: E0630 19:21:28.254652    1679 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/csi/file.csi.azure.com^id123456 podName: nodeName:}" failed. No retries permitted until 2023-06-30 19:21:29.254633502 +0000 UTC m=+5203.028429686 (durationBeforeRetry 1s). Error: MountVolume.MountDevice failed for volume "azurefile" (UniqueName: "kubernetes.io/csi/file.csi.azure.com^id123456") pod "mypod" (UID: "efa51ab7-5ecb-4910-a25f-1be61e02b47d") : rpc error: code = Internal desc = volume(id123456) mount //mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount failed with mount failed: exit status 32

# No output rows for the mount command.
root@aks-nodepool1-51397738-vmss000005:/# mount | grep mystorageacct
```

```
# To display information about the csi-azurefile located in the node where the pod is scheduled.
kubectl get po -n kube-system -owide | grep csi-azurefile | grep vmss000005

# Here is a sample output below.
csi-azurefile-node-ccsm4              3/3     Running   0          54m   10.224.0.4   aks-nodepool1-51397738-vmss000005   <none>           <none>

# To retrieve CSI driver logs.
kubectl logs -n kube-system csi-azurefile-node-ccsm4 -c azurefile

# Here is a sample output below.
I0630 19:21:27.614458       1 utils.go:76] GRPC call: /csi.v1.Node/NodeStageVolume
I0630 19:21:27.614472       1 utils.go:77] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["dir_mode=0777","file_mode=0777","uid=0","gid=0","mfsymlinks","cache=strict","nosharesock","nobrl"]}},"access_mode":{"mode":5}},"volume_context":{"resourceGroup":"MC_secureshack2_aks_swedencentral","shareName":"aksshare"},"volume_id":"id123456"}
W0630 19:21:27.614589       1 azurefile.go:601] parsing volumeID(id123456) return with error: error parsing volume id: "id123456", should at least contain two #
I0630 19:21:27.614638       1 nodeserver.go:302] cifsMountPath(/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount) fstype() volumeID(id123456) context(map[resourceGroup:MC_secureshack2_aks_swedencentral shareName:aksshare]) mountflags([dir_mode=0777 file_mode=0777 uid=0 gid=0 mfsymlinks cache=strict nosharesock nobrl]) mountOptions([dir_mode=0777 file_mode=0777 uid=0 gid=0 mfsymlinks cache=strict nosharesock nobrl actimeo=30]) volumeMountGroup()
E0630 19:21:27.647784       1 mount_linux.go:195] Mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o dir_mode=0777,file_mode=0777,uid=0,gid=0,mfsymlinks,cache=strict,nosharesock,nobrl,actimeo=30,<masked> //mystorageacct23534.file.core.windows.net/aksshare /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount
Output: mount error(13): Permission denied
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
E0630 19:21:27.647818       1 utils.go:81] GRPC error: rpc error: code = Internal desc = volume(id123456) mount //mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount failed with mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o dir_mode=0777,file_mode=0777,uid=0,gid=0,mfsymlinks,cache=strict,nosharesock,nobrl,actimeo=30,<masked> //mystorageacct23534.file.core.windows.net/aksshare /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount
Output: mount error(13): Permission denied
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
```

```
# To cleanup.
kubectl delete pod/mypod
kubectl delete pvc azurefile
kubectl delete pv azurefile
kubectl delete secret azure-secret
az storage account delete -g $rgname -n $storageAccountName -y
```

Here are some related links:
- [AKS/issues/2383#issuecomment-859539446](https://github.com/Azure/AKS/issues/2383#issuecomment-859539446): it's most likely your secret does not have correct account name or key, would you remove that secret in namespace and then `kubectl create secret`
- [troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-file-share#mounterror13](https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-file-share#mounterror13).
