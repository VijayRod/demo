Here is an example of an Azure File mount.

```
# Create the resources.
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-azurefile
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile
  resources:
    requests:
      storage: 100Gi
---
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
      claimName: my-azurefile
EOF
```

```
# Display information about the created resources.
kubectl get po,pv,pvc

# Here is a sample output below.
# NAME                 READY   STATUS    RESTARTS   AGE
# pod/mypod            1/1     Running   0          13s
#
# NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS   REASON   AGE
# persistentvolume/pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d   100Gi      RWX            Delete           Bound    default/my-azurefile   azurefile               11s
#
# NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/my-azurefile   Bound    pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d   100Gi      RWX            azurefile      13s
```

```
# Execute the below command in the container.
kubectl exec mypod -it -- mount | grep pvc

# Here is a sample output below.
# //fe531559d5f294407a15318.file.core.windows.net/pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d on /mnt/azure type cifs (rw,relatime,vers=3.1.1,cache=strict,username=fe531559d5f294407a15318,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
```

```
# Get the node name.
kubectl get po -owide

# Here is a sample output below.
# NAME             READY   STATUS    RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
# mypod            1/1     Running   0          5m53s   10.244.0.12   aks-nodepool1-51397738-vmss000003   <none>           <none>
```

```
# ssh to the node and search for the pvc name. Run the following command on the node with the name of the pv.
root@aks-nodepool1-51397738-vmss000003:/# mount | grep pvc-57ef31f0

# Here is a sample output below.
# //fe531559d5f294407a15318.file.core.windows.net/pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7cdc2c9d9e9dd380782b6aba2f5c52fabe14d035bb0f197fe039d98b2eac718e/globalmount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=fe531559d5f294407a15318,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
# //fe531559d5f294407a15318.file.core.windows.net/pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d on /var/lib/kubelet/pods/340aafe5-cb01-4cce-9ef1-3d21dbb01494/volumes/kubernetes.io~csi/pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=fe531559d5f294407a15318,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)

# In the above output:
# - fe531559d5f294407a15318 is the name of the storage account in the default MC_ node resource group.
# - addr has the (public) IP is of the file service of the storage account which can also been seen using the below command.
## nslookup fe531559d5f294407a15318.file.core.windows.net
### fe531559d5f294407a15318.file.core.windows.net   canonical name = file.gvx21prdstr02a.store.core.windows.net.
### Name:   file.gvx21prdstr02a.store.core.windows.net
### Address: 20.60.78.104
```

```
# View /var/log/syslog for the volume.
cat /var/log/syslog | grep pvc-57ef31f0
Jun 27 16:33:39 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0627 16:33:39.447353    1758 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_resourceGroupName#fe531559d5f294407a15318#pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d###default\") pod \"mypod\" (UID: \"340aafe5-cb01-4cce-9ef1-3d21dbb01494\") " pod="default/mypod"
Jun 27 16:33:39 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0627 16:33:39.548629    1758 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_resourceGroupName#fe531559d5f294407a15318#pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d###default\") pod \"mypod\" (UID: \"340aafe5-cb01-4cce-9ef1-3d21dbb01494\") " pod="default/mypod"
Jun 27 16:33:39 aks-nodepool1-51397738-vmss000003 kernel: [12336.839270] CIFS: Attempting to mount \\fe531559d5f294407a15318.file.core.windows.net\pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d
Jun 27 16:33:39 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0627 16:33:39.675678    1758 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_resourceGroupName#fe531559d5f294407a15318#pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d###default\") pod \"mypod\" (UID: \"340aafe5-cb01-4cce-9ef1-3d21dbb01494\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7cdc2c9d9e9dd380782b6aba2f5c52fabe14d035bb0f197fe039d98b2eac718e/globalmount\"" pod="default/mypod"
Jun 27 16:33:39 aks-nodepool1-51397738-vmss000003 kubelet[1758]: I0627 16:33:39.685414    1758 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_resourceGroupName#fe531559d5f294407a15318#pvc-57ef31f0-8234-419e-a997-313d5fb9bf9d###default\") pod \"mypod\" (UID: \"340aafe5-cb01-4cce-9ef1-3d21dbb01494\") " pod="default/mypod"
```
