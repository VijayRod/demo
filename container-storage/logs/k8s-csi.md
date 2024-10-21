## k8s-csi

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

k get crd | grep stor
volumesnapshotclasses.snapshot.storage.k8s.io           2024-10-15T18:38:35Z
volumesnapshotcontents.snapshot.storage.k8s.io          2024-10-15T18:38:35Z
volumesnapshots.snapshot.storage.k8s.io                 2024-10-15T18:38:35Z

k api-resources | grep stor
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
volumesnapshotclasses               vsclass,vsclasses   snapshot.storage.k8s.io/v1             false        VolumeSnapshotClass
volumesnapshotcontents              vsc,vscs            snapshot.storage.k8s.io/v1             false        VolumeSnapshotContent
volumesnapshots                     vs                  snapshot.storage.k8s.io/v1             true         VolumeSnapshot
csidrivers                                              storage.k8s.io/v1                      false        CSIDriver
csinodes                                                storage.k8s.io/v1                      false        CSINode
csistoragecapacities                                    storage.k8s.io/v1                      true         CSIStorageCapacity
storageclasses                      sc                  storage.k8s.io/v1                      false        StorageClass
volumeattachments                                       storage.k8s.io/v1                      false        VolumeAttachment

k describe no
Name:               aks-nodepool1-19171753-vmss000000
Roles:              <none>
Labels:             agentpool=nodepool1
                    storageprofile=managed
                    storagetier=Premium_LRS
                    topology.disk.csi.azure.com/zone=
```

- [kubernetes.io/blog/2019/01/15/container-storage-interface-ga/](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/)
- [container-storage-interface/spec](https://github.com/container-storage-interface/spec/blob/master/spec.md)
- https://kubernetes-csi.github.io/docs/

## k8s-csi.apiresources.csidrivers

```
kubectl get csidrivers
NAME                 ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS                REQUIRESREPUBLISH   MODES                  AGE
disk.csi.azure.com   true             false            false             <unset>                      false               Persistent             5m43s
file.csi.azure.com   false            true             false             api://AzureADTokenExchange   false               Persistent,Ephemeral   5m42s

kubectl describe csidrivers disk.csi.azure.com
Name:         disk.csi.azure.com
Namespace:
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              kubernetes.io/cluster-service=true
Annotations:  csiDriver: v1.29.9
              snapshot: v6.3.3
API Version:  storage.k8s.io/v1
Kind:         CSIDriver
Metadata:
  Creation Timestamp:  2024-10-10T08:49:02Z
  Resource Version:    458
  UID:                 18feb06c-6b0b-4776-8b6d-7a43470db107
Spec:
  Attach Required:     true
  Fs Group Policy:     File
  Pod Info On Mount:   false
  Requires Republish:  false
  Se Linux Mount:      false
  Storage Capacity:    false
  Volume Lifecycle Modes:
    Persistent
Events:  <none>

kubectl describe csidrivers file.csi.azure.com
Name:         file.csi.azure.com
Namespace:
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              kubernetes.io/cluster-service=true
Annotations:  csiDriver: v1.30.5
              snapshot: v6.3.3
API Version:  storage.k8s.io/v1
Kind:         CSIDriver
Metadata:
  Creation Timestamp:  2024-10-10T08:49:03Z
  Resource Version:    486
  UID:                 4a98ac56-471f-425d-8a1d-21aa386dc069
Spec:
  Attach Required:     false
  Fs Group Policy:     ReadWriteOnceWithFSType
  Pod Info On Mount:   true
  Requires Republish:  false
  Se Linux Mount:      false
  Storage Capacity:    false
  Token Requests:
    Audience:  api://AzureADTokenExchange
  Volume Lifecycle Modes:
    Persistent
    Ephemeral
Events:  <none>
```

- https://kubernetes-csi.github.io/docs/drivers.html

## k8s-csi.apiresources.csinodes

```
kubectl get csinodes
NAME                                DRIVERS   AGE
aks-nodepool1-25700344-vmss000000   2         4m19s
```

## k8s-csi.csi-controller

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/csi-blob-controller.yaml
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/deploy/csi-azurefile-controller.yaml
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/pkg/azuredisk/azure_controller_common.go
  
## k8s-csi.csi-controller.batch

```
tbd use a vmsize that allows a large number of disks to be attached

# Exclusive to azuredisk (not applicable to azurefile)
# https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/pkg/azuredisk/azure_controller_common.go

	// default initial delay in milliseconds for batch disk attach/detach
	defaultAttachDetachInitialDelayInMs = 1000
	
	if c.AttachDetachInitialDelayInMs > 0 && requestNum == 1 {
		klog.V(2).Infof("wait %dms for more requests on node %s, current disk attach: %s", c.AttachDetachInitialDelayInMs, node, diskURI)
		time.Sleep(time.Duration(c.AttachDetachInitialDelayInMs) * time.Millisecond)
```

- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi: In-tree drivers attach or detach disks in serial, while CSI drivers attach or detach disks in batch. There's significant improvement when there are multiple disks attaching to one node.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/slow-attach-detach-operations-azure-disk: The operations are done sequentially. This limitation is a known issue with the in-tree Azure disk driver

## k8s-csi.csi-controller.batch.singlemountsamenode

```
storageAccountName="mystorageacct$RANDOM"
shareName=aksshare
noderg=$(az aks show --resource-group $rgname --name $clustername --query nodeResourceGroup -o tsv)
az storage account create -g $noderg -n $storageAccountName --sku Premium_LRS --kind FileStorage --enable-large-file-share --output none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $noderg -n $storageAccountName -o tsv)
key=$(az storage account keys list -g $noderg --account-name $storageAccountName --query "[0].value" -o tsv)
echo Storage account key: $STORAGE_KEY
az storage share create -n $shareName --connection-string $AZURE_STORAGE_CONNECTION_STRING

# aks-nodepool1-37233090-vmss000000
mkdir /tmp/test
sudo mount -v -t cifs //mystorageacct26411.file.core.windows.net/aksshare /tmp/test -o  username=mystorageacct26411,password=$key,dir_mode=0777,file_mode=0777,cache=strict,actimeo=30
mkdir /tmp/test2
sudo mount -v -t cifs //mystorageacct26411.file.core.windows.net/aksshare /tmp/test2 -o  username=mystorageacct26411,password=$key,dir_mode=0777,file_mode=0777,cache=strict,actimeo=30
ls /tmp/test2

mount -t cifs
//mystorageacct26411.file.core.windows.net/aksshare on /tmp/test type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct26411,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
//mystorageacct26411.file.core.windows.net/aksshare on /tmp/test2 type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct26411,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)

touch /tmp/test/myfile
ls /tmp/test2 # myfile

umount /tmp/test
umount /tmp/test2
az storage account delete -g $rgname -n $storageAccountName -y
```

```
node=aks-nodepool1-37233090-vmss000000
kubectl delete po mypod2
kubectl delete po mypod
kubectl delete pvc my-azurefile
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
  nodeSelector:
    kubernetes.io/hostname: $node
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
    - mountPath: /mnt/azure
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: my-azurefile
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod2
spec:
  nodeSelector:
    kubernetes.io/hostname: $node
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
    - mountPath: /mnt/azure
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: my-azurefile
EOF
sleep 10

# Single mount invocation for multiple pods using the same share in the same node
kubectl logs -n kube-system -l app=csi-azurefile-node -c azurefile
I1106 18:46:05.486682       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount /var/lib/kubelet/pods/ec34b542-b5d0-4ce6-9c87-dce7f032ac7d/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount)
I1106 18:46:05.488765       1 nodeserver.go:118] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount at /var/lib/kubelet/pods/ec34b542-b5d0-4ce6-9c87-dce7f032ac7d/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount successfully
I1106 18:46:05.488778       1 utils.go:83] GRPC response: {}
I1106 18:46:07.159916       1 utils.go:76] GRPC call: /csi.v1.Node/NodePublishVolume
I1106 18:46:07.159927       1 utils.go:77] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount","target_path":"/var/lib/kubelet/pods/e9e10f5b-3e56-451f-a5d8-747369e7749e/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["mfsymlinks","actimeo=30","nosharesock"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"e9e10f5b-3e56-451f-a5d8-747369e7749e","csi.storage.k8s.io/pv/name":"pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf","csi.storage.k8s.io/pvc/name":"my-azurefile","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1699263724991-3752-file.csi.azure.com"},"volume_id":"mc_rg2_aks_swedencentral#mystorageacct26411#pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf###default"}
I1106 18:46:07.160348       1 nodeserver.go:111] NodePublishVolume: mounting /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount at /var/lib/kubelet/pods/e9e10f5b-3e56-451f-a5d8-747369e7749e/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount with mountOptions: [bind]
I1106 18:46:07.160366       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount /var/lib/kubelet/pods/e9e10f5b-3e56-451f-a5d8-747369e7749e/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount)
I1106 18:46:07.165144       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount /var/lib/kubelet/pods/e9e10f5b-3e56-451f-a5d8-747369e7749e/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount)
I1106 18:46:07.166497       1 nodeserver.go:118] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount at /var/lib/kubelet/pods/e9e10f5b-3e56-451f-a5d8-747369e7749e/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount successfully
I1106 18:46:07.166512       1 utils.go:83] GRPC response: {}

mount -t cifs
//mystorageacct26411.file.core.windows.net/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/7f9a2c625ee3ee07bd17dd5675e02cee88e32aa2c9c40e845e8e929819833ee4/globalmount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct26411,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
//mystorageacct26411.file.core.windows.net/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf on /var/lib/kubelet/pods/ec34b542-b5d0-4ce6-9c87-dce7f032ac7d/volumes/kubernetes.io~csi/pvc-b979cc56-14c6-4b10-a55f-efa789f36fdf/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct26411,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/nodeserver.go: NodeStageVolume - if isDirMounted { klog.V(2).Infof("NodeStageVolume: volume %s is already mounted on %s"
  
## k8s-csi.csi-provisioner

```
# PVC binding delays - If the Persistent Volume (PV) and Persistent Volume Claim (PVC) are slow to bind, taking more than a minute for example, it's likely related to the external-provisioner. Both the kube-controller-manager and external-provisioner are upstream components. Reducing the number of PVCs you currently have might help speed things up. If that doesn't work, consider submitting a request at https://github.com/kubernetes/kubernetes/issues.

https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/charts/latest/azurefile-csi-driver/values.yaml
image:
  baseRepo: mcr.microsoft.com
    repository: /k8s/csi/azurefile-csi
    repository: /oss/kubernetes-csi/csi-provisioner
...
# tbd Note: This is part of the azurefile image.
    
https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/csi-blob-controller.yaml
  name: csi-blob-controller
        - name: csi-provisioner
          image: mcr.microsoft.com/oss/kubernetes-csi/csi-provisioner:v5.1.0

https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/deploy/csi-azurefile-controller.yaml
  name: csi-azurefile-controller
      containers:
        - name: csi-provisioner
          image: mcr.microsoft.com/oss/kubernetes-csi/csi-provisioner:v5.1.0

# azurefile pvc create
kubectl logs -n kube-system csi-azurefile-node-z6hwf -c azurefile | grep provis
I1015 18:31:12.907895       1 utils.go:102] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/887992b95f884070b532f7b3c7562d588ab9589a4e7620aacdeffab9356e9e28/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["mfsymlinks","actimeo=30","nosharesock"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb","csi.storage.k8s.io/pvc/name":"pvc-azurefile","csi.storage.k8s.io/pvc/namespace":"default","secretnamespace":"default","skuName":"Standard_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1728991686922-1668-file.csi.azure.com"},"volume_id":"MC_rg_aks_swedencentral#faf7a164ba5d246afaf9fa6#pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb###default"}
I1015 11:31:13.209240       1 utils.go:102] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/887992b95f884070b532f7b3c7562d588ab9589a4e7620aacdeffab9356e9e28/globalmount","target_path":"/var/lib/kubelet/pods/a491ff30-53c1-4cc0-b8ad-0fef1d694602/volumes/kubernetes.io~csi/pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["mfsymlinks","actimeo=30","nosharesock"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"nginx-azurefile","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"a491ff30-53c1-4cc0-b8ad-0fef1d694602","csi.storage.k8s.io/pv/name":"pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb","csi.storage.k8s.io/pvc/name":"pvc-azurefile","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","csi.storage.k8s.io/serviceAccount.tokens":"***stripped***","secretnamespace":"default","skuName":"Standard_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1728991686922-1668-file.csi.azure.com"},"volume_id":"MC_rg_aks_swedencentral#faf7a164ba5d246afaf9fa6#pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb###default"}
```

- https://kubernetes-csi.github.io/docs/external-provisioner.html: registry.k8s.io/sig-storage/csi-provisioner. The CSI external-provisioner is a sidecar container that watches the Kubernetes API server for PersistentVolumeClaim objects.
- https://github.com/kubernetes-csi/external-provisioner: The external-provisioner is a sidecar container that dynamically provisions volumes by calling CreateVolume and DeleteVolume functions of CSI drivers. It is necessary because internal persistent volume controller running in Kubernetes controller-manager does not have any direct interfaces to CSI drivers.
- https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner: You can also run and specify external provisioners, which are independent programs that follow a specification defined by Kubernetes. Authors of external provisioners have full discretion over where their code lives, how the provisioner is shipped, how it needs to be run, what volume plugin it uses (including Flex), etc. The repository kubernetes-sigs/sig-storage-lib-external-provisioner houses a library for writing external provisioners that implements the bulk of the specification. Some external provisioners are listed under the repository kubernetes-sigs/sig-storage-lib-external-provisioner.
