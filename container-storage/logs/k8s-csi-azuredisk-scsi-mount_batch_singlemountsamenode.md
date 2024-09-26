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
