This uses steps in 
https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#mount-file-share-as-an-inline-volume to use the Azure File CSI driver to mount an inline Azure File share as a volume in a pod. These are volumes that follow the lifecyle of the pod as indicated in https://kubernetes.io/blog/2022/08/29/csi-inline-volumes-ga/.

```
# Replace the below with appropriate values.
rgname=
storageAccountName="mystorageacct$RANDOM"
shareName=aksshare
```

```
# Create a storage account.
az storage account create -g $rgname -n $storageAccountName --kind FileStorage --sku Premium_LRS --enable-large-file-share --output none

# Retrieve the storage account key.
key=$(az storage account keys list -g $rgname -n $storageAccountName --query [0].value -o tsv)

# Create a file share.
az storage share-rm create -g $rgname --storage-account $storageAccountName -n $shareName --quota 1024 --enabled-protocols SMB --output none
```

```
# Create the Kubernetes secret to store the Azure storage account credentials. This assumes az aks get-credentials has already been run to retrieve access credentials.
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storageAccountName --from-literal=azurestorageaccountkey=$key

# Create the resources.
cat << EOF | kubectl create -f - 
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - image: nginx
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
    csi:
      driver: file.csi.azure.com
      readOnly: false
      volumeAttributes:
        secretName: azure-secret  # required
        shareName: $shareName  # required
        mountOptions: "dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock"  # optional
EOF
```

```
# Display the resource. Since this is an inline volume, there won't be a Persistent Volume (PV) associated with it.
kubectl get po,pv

# Here is a sample output below.
# NAME                                                        READY   STATUS      RESTARTS   AGE
# pod/mypod                                                   1/1     Running     0          33s

# Retrieve the node name.
kubectl get po -owide

# Here is a sample output below.
# NAME                                                    READY   STATUS      RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
# mypod                                                   1/1     Running     0          7m53s   10.244.0.13   aks-nodepool1-51397738-vmss000003   <none>           <none>
```

```
# Describe includes the below output. There is no persistent volume claim in this output.
kubectl describe po mypod

# Here is a sample output below.
Containers:
  mypod:
    Mounts:
      /mnt/azure from azure (rw)
Volumes:
  azure:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            file.csi.azure.com
    FSType:
    ReadOnly:          false
    VolumeAttributes:      mountOptions=dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock
                           secretName=azure-secret
                           shareName=aksshare
```

```
# /var/log/syslog from the node.
Jun 28 20:19:35 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0628 20:19:35.351636    1758 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"azure\" (UniqueName: \"kubernetes.io/csi/349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5-azure\") pod \"mypod\" (UID: \"349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5\") " pod="default/mypod"
Jun 28 20:19:35 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0628 20:19:35.452587    1758 reconciler.go:269] "operationExecutor.MountVolume started for volume \"azure\" (UniqueName: \"kubernetes.io/csi/349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5-azure\") pod \"mypod\" (UID: \"349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5\") " pod="default/mypod"
Jun 28 20:19:35 aks-nodepool1-51397738-vmss000003 kernel: [112291.557092] CIFS: Attempting to mount \\mystorageacct8461.file.core.windows.net\aksshare
Jun 28 20:19:35 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0628 20:19:35.581000    1758 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"azure\" (UniqueName: \"kubernetes.io/csi/349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5-azure\") pod \"mypod\" (UID: \"349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5\") " pod="default/mypod"

# Mount output from the node for this volume.
root@aks-nodepool1-51397738-vmss000003:/# mount | grep mystorageacct
//mystorageacct8461.file.core.windows.net/aksshare on /var/lib/kubelet/pods/349cbd5d-c4ed-4cb6-9a38-d282e6d0d3c5/volumes/kubernetes.io~csi/azure/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct8461,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
```

```
# Cleanup.
kubectl delete pod/mypod
az storage account delete -g $rgname -n $storageAccountName -y
```
