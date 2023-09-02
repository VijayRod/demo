Here is an example of an Azure File mount using the `azurefile-premium` storage class. The storage class describe and the CSI driver logs show the storage account's skuName as `Premium_LRS`. On the other hand, for a mount with the `azurefile` storage class, the storage class describe and the CSI driver logs indicate the storage account's skuName as `Standard_LRS`, with the same mount options as as the `azurefile-premium` storage class.

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
  storageClassName: azurefile-premium
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
# persistentvolume/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf   100Gi      RWX            Delete           Bound    default/my-azurefile   azurefile               11s
#
# NAME                                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistentvolumeclaim/my-azurefile   Bound    pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf   100Gi      RWX            azurefile      13s
```

```
# Execute the below command in the container.
kubectl exec mypod -it -- mount | grep pvc

# Here is a sample output below.
# //fe531559d5f294407a15318.file.core.windows.net/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf on /mnt/azure type cifs (rw,relatime,vers=3.1.1,cache=strict,username=fe531559d5f294407a15318,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
```

```
# Get the node name.
kubectl get po -owide

# Here is a sample output below.
# NAME             READY   STATUS    RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
# mypod            1/1     Running   0          5m53s   10.244.0.12   aks-nodepool1-51397738-vmss000004   <none>           <none>
```

```
# ssh to the node and search for the pvc name. Run the following command on the node with the name of the pv.
root@aks-nodepool1-51397738-vmss000004:/# mount | grep pvc-a0be56a7

# Here is a sample output below.
# //fe531559d5f294407a15318.file.core.windows.net/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=fe531559d5f294407a15318,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
# //fe531559d5f294407a15318.file.core.windows.net/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf on /var/lib/kubelet/pods/a9426f1c-2c39-450c-bf01-1b14251e48dd/volumes/kubernetes.io~csi/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=fe531559d5f294407a15318,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.78.104,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)

# In the above output:
# - fe531559d5f294407a15318 is the name of the storage account in the default MC_ node resource group.
# - addr has the (public) IP is of the file service of the storage account which can also been seen using the below command.
## nslookup fe531559d5f294407a15318.file.core.windows.net
### fe531559d5f294407a15318.file.core.windows.net   canonical name = file.gvx21prdstr02a.store.core.windows.net.
### Name:   file.gvx21prdstr02a.store.core.windows.net
### Address: 20.60.78.104
```

```
# To view the node syslog for the volume.
cat /var/log/syslog | grep pvc-a0be56a7

# Here is a sample output below.
Jun 29 19:29:07 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 19:29:07.171131    1620 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default\") pod \"mypod\" (UID: \"a9426f1c-2c39-450c-bf01-1b14251e48dd\") " pod="default/mypod"
Jun 29 19:29:07 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 19:29:07.272255    1620 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default\") pod \"mypod\" (UID: \"a9426f1c-2c39-450c-bf01-1b14251e48dd\") " pod="default/mypod"
Jun 29 19:29:07 aks-nodepool1-51397738-vmss000004 kernel: [35459.933436] CIFS: Attempting to mount \\fe531559d5f294407a15318.file.core.windows.net\pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf
Jun 29 19:29:07 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 19:29:07.419761    1620 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default\") pod \"mypod\" (UID: \"a9426f1c-2c39-450c-bf01-1b14251e48dd\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount\"" pod="default/mypod"
Jun 29 19:29:07 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 19:29:07.427158    1620 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default\") pod \"mypod\" (UID: \"a9426f1c-2c39-450c-bf01-1b14251e48dd\") " pod="default/mypod"
```

```
# To display information about the csi-azurefile located in the node where the pod is scheduled.
kubectl get po -n kube-system -owide | grep csi-azurefile | grep vmss000004

# Here is a sample output below.
# csi-azurefile-node-h72r5              3/3     Running   0          9h      10.224.0.4   aks-nodepool1-51397738-vmss000004   <none>           <none>

# To retrieve CSI driver logs.
kubectl logs -n kube-system csi-azurefile-node-h72r5 -c azurefile

# Here is a sample output below.
I0629 19:29:07.278639       1 utils.go:76] GRPC call: /csi.v1.Node/NodeStageVolume
I0629 19:29:07.278654       1 utils.go:77] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["mfsymlinks","actimeo=30","nosharesock"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf","csi.storage.k8s.io/pvc/name":"my-azurefile","csi.storage.k8s.io/pvc/namespace":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1688031486058-8081-file.csi.azure.com"},"volume_id":"mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default"}
I0629 19:29:07.332618       1 nodeserver.go:302] cifsMountPath(/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount) fstype() volumeID(mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default) context(map[csi.storage.k8s.io/pv/name:pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf csi.storage.k8s.io/pvc/name:my-azurefile csi.storage.k8s.io/pvc/namespace:default secretnamespace:default skuName:Premium_LRS storage.kubernetes.io/csiProvisionerIdentity:1688031486058-8081-file.csi.azure.com]) mountflags([mfsymlinks actimeo=30 nosharesock]) mountOptions([mfsymlinks actimeo=30 nosharesock file_mode=0777 dir_mode=0777]) volumeMountGroup()
I0629 19:29:07.419358       1 nodeserver.go:332] volume(mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default) mount //fe531559d5f294407a15318.file.core.windows.net/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount succeeded
I0629 19:29:07.419399       1 utils.go:83] GRPC response: {}
I0629 19:29:07.423503       1 utils.go:76] GRPC call: /csi.v1.Node/NodePublishVolume
I0629 19:29:07.423516       1 utils.go:77] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount","target_path":"/var/lib/kubelet/pods/a9426f1c-2c39-450c-bf01-1b14251e48dd/volumes/kubernetes.io~csi/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["mfsymlinks","actimeo=30","nosharesock"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"a9426f1c-2c39-450c-bf01-1b14251e48dd","csi.storage.k8s.io/pv/name":"pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf","csi.storage.k8s.io/pvc/name":"my-azurefile","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1688031486058-8081-file.csi.azure.com"},"volume_id":"mc_secureshack2_aks_swedencentral#fe531559d5f294407a15318#pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf###default"}
I0629 19:29:07.423978       1 nodeserver.go:109] NodePublishVolume: mounting /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount at /var/lib/kubelet/pods/a9426f1c-2c39-450c-bf01-1b14251e48dd/volumes/kubernetes.io~csi/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf/mount with mountOptions: [bind]
I0629 19:29:07.426968       1 nodeserver.go:116] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/06ab806af170755d9683d9ab14656e692502e907eaa632a1c279767918262a97/globalmount at /var/lib/kubelet/pods/a9426f1c-2c39-450c-bf01-1b14251e48dd/volumes/kubernetes.io~csi/pvc-a0be56a7-96f5-4c9d-b1b8-b234fa742ddf/mount successfully
I0629 19:29:07.426983       1 utils.go:83] GRPC response: {}
```

```
# To cleanup.
kubectl delete po mypod
kubectl delete pvc my-azurefile
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/azurefile.go
- https://github.com/Azure/AKS/tree/master/vhd-notes
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/csi-debug.md
- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi
