This follows the steps in the link https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume to create a pod wwith a static persistent volume.

```
# Replace the below with appropriate values.
rgname=
clustername=aks
storageAccountName="mystorageacct$RANDOM"
shareName=aksshare
```

```
# Retrieve the node resource group name for the cluster.
nodeResourceGroupName=$(az aks show --resource-group $rgname --name $clustername --query nodeResourceGroup -o tsv)

# Create the storage account.
az storage account create -g $nodeResourceGroupName -n $storageAccountName --sku Premium_LRS --kind FileStorage --enable-large-file-share --output none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $nodeResourceGroupName -n $storageAccountName -o tsv)
STORAGE_KEY=$(az storage account keys list -g $nodeResourceGroupName --account-name $storageAccountName --query "[0].value" -o tsv)
echo Storage account key: $STORAGE_KEY

# Create the file share.
az storage share create -n $shareName --connection-string $AZURE_STORAGE_CONNECTION_STRING
```

```
# Create the kubernetes secret.
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storageAccountName --from-literal=azurestorageaccountkey=$STORAGE_KEY

# Create the kubernetes static persistent volume, persistent volume claim, and pod.
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
# Display information about the resources.
kubectl get po,pv,pvc

# Here is a sample output below.
NAME        READY   STATUS    RESTARTS   AGE
pod/mypod   1/1     Running   0          9s
NAME                         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM               STORAGECLASS        REASON   AGE
persistentvolume/azurefile   5Gi        RWX            Retain           Bound    default/azurefile   azurefile-premium            10s
NAME                              STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS        AGE
persistentvolumeclaim/azurefile   Bound    azurefile   5Gi        RWX            azurefile-premium   9s

# Describe the pod.
kubectl describe po mypod

# Here is a sample output below.
    Mounts:
      /mnt/azure from azure (rw)
Volumes:
  azure:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  azurefile
    ReadOnly:   false
    
# Create a file in the mounted volume.
kubectl exec -it mypod -- touch /mnt/azure/file1

# List the files in the mounted volume.
kubectl exec -it mypod -- ls /mnt/azure

# Here is a sample output below.
# file1
```    
  
```    
# To view the node syslog for the volume.
cat /var/log/syslog

# Here is a sample output below.
Jun 30 18:41:52 aks-nodepool1-51397738-vmss000005 kubelet[1679]: I0630 18:41:52.477729    1679 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"azurefile\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^id123456\") pod \"mypod\" (UID: \"19beb68f-9704-4310-8aed-701564a62b4c\") " pod="default/mypod"
Jun 30 18:41:52 aks-nodepool1-51397738-vmss000005 kubelet[1679]: I0630 18:41:52.578636    1679 reconciler.go:269] "operationExecutor.MountVolume started for volume \"azurefile\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^id123456\") pod \"mypod\" (UID: \"19beb68f-9704-4310-8aed-701564a62b4c\") " pod="default/mypod"
Jun 30 18:41:53 aks-nodepool1-51397738-vmss000005 kernel: [ 2853.410794] CIFS: No dialect specified on mount. Default has changed to a more secure dialect, SMB2.1 or later (e.g. SMB3.1.1), from CIFS (SMB1). To use the less secure SMB1 dialect to access old servers which do not support SMB3.1.1 (or even SMB3 or SMB2.1) specify vers=1.0 on mount.
Jun 30 18:41:53 aks-nodepool1-51397738-vmss000005 kernel: [ 2853.410797] CIFS: Attempting to mount \\mystorageacct23534.file.core.windows.net\aksshare
Jun 30 18:41:53 aks-nodepool1-51397738-vmss000005 kubelet[1679]: I0630 18:41:53.157644    1679 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"azurefile\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^id123456\") pod \"mypod\" (UID: \"19beb68f-9704-4310-8aed-701564a62b4c\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount\"" pod="default/mypod"
Jun 30 18:41:53 aks-nodepool1-51397738-vmss000005 kubelet[1679]: I0630 18:41:53.172641    1679 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"azurefile\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^id123456\") pod \"mypod\" (UID: \"19beb68f-9704-4310-8aed-701564a62b4c\") " pod="default/mypod"

# Mount output from the node for this volume.
root@aks-nodepool1-51397738-vmss000005:/# mount | grep mystorageacct

# Here is a sample output below.
//mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct23534,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,nobrl,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
//mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/pods/19beb68f-9704-4310-8aed-701564a62b4c/volumes/kubernetes.io~csi/azurefile/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct23534,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,nobrl,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
```

```
# To display information about the csi-azurefile located in the node where the pod is scheduled.
kubectl get po -n kube-system -owide | grep csi-azurefile | grep vmss000005

# Here is a sample output below.
csi-azurefile-node-ccsm4              3/3     Running   0          54m   10.224.0.4   aks-nodepool1-51397738-vmss000005   <none>           <none>

# To retrieve CSI driver logs.
kubectl logs -n kube-system csi-azurefile-node-ccsm4 -c azurefile

# Here is a sample output below.
I0630 18:41:52.587929       1 utils.go:76] GRPC call: /csi.v1.Node/NodeStageVolume
I0630 18:41:52.587945       1 utils.go:77] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["dir_mode=0777","file_mode=0777","uid=0","gid=0","mfsymlinks","cache=strict","nosharesock","nobrl"]}},"access_mode":{"mode":5}},"volume_context":{"resourceGroup":"MC_secureshack2_aks_swedencentral","shareName":"aksshare"},"volume_id":"id123456"}
W0630 18:41:52.588168       1 azurefile.go:601] parsing volumeID(id123456) return with error: error parsing volume id: "id123456", should at least contain two #
I0630 18:41:52.588367       1 nodeserver.go:302] cifsMountPath(/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount) fstype() volumeID(id123456) context(map[resourceGroup:MC_secureshack2_aks_swedencentral shareName:aksshare]) mountflags([dir_mode=0777 file_mode=0777 uid=0 gid=0 mfsymlinks cache=strict nosharesock nobrl]) mountOptions([dir_mode=0777 file_mode=0777 uid=0 gid=0 mfsymlinks cache=strict nosharesock nobrl actimeo=30]) volumeMountGroup()
I0630 18:41:53.156927       1 nodeserver.go:332] volume(id123456) mount //mystorageacct23534.file.core.windows.net/aksshare on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount succeeded
I0630 18:41:53.157115       1 utils.go:83] GRPC response: {}
I0630 18:41:53.169055       1 utils.go:76] GRPC call: /csi.v1.Node/NodePublishVolume
I0630 18:41:53.169071       1 utils.go:77] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount","target_path":"/var/lib/kubelet/pods/19beb68f-9704-4310-8aed-701564a62b4c/volumes/kubernetes.io~csi/azurefile/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["dir_mode=0777","file_mode=0777","uid=0","gid=0","mfsymlinks","cache=strict","nosharesock","nobrl"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"19beb68f-9704-4310-8aed-701564a62b4c","csi.storage.k8s.io/serviceAccount.name":"default","resourceGroup":"MC_secureshack2_aks_swedencentral","shareName":"aksshare"},"volume_id":"id123456"}
I0630 18:41:53.169544       1 nodeserver.go:109] NodePublishVolume: mounting /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount at /var/lib/kubelet/pods/19beb68f-9704-4310-8aed-701564a62b4c/volumes/kubernetes.io~csi/azurefile/mount with mountOptions: [bind]
I0630 18:41:53.172401       1 nodeserver.go:116] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/723ea299bae600c45c947090f00a881076794e75f5ff18cc4ae794a6091cc0ca/globalmount at /var/lib/kubelet/pods/19beb68f-9704-4310-8aed-701564a62b4c/volumes/kubernetes.io~csi/azurefile/mount successfully
I0630 18:41:53.172415       1 utils.go:83] GRPC response: {}
```

```
# Cleanup.
kubectl delete pod/mypod
kubectl delete pvc azurefile
kubectl delete pv azurefile
kubectl delete secret azure-secret
az storage account delete -g $rgname -n $storageAccountName -y
```
