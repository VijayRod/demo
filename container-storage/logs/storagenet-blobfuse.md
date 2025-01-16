## blobfuse.app.k8s.csi.azureblob

- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi?tabs=NFS: The data on the object storage can be accessed by applications using BlobFuse or Network File System (NFS) 3.0 protocol.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, Azure Blob Storage CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in blobfuse plugin would be incorporated into this driver.
- https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-how-to-deploy
- https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-troubleshooting
- https://github.com/Azure/azure-storage-fuse/blob/main/TSG.md

## blobfuse.app.k8s.csi.azureblob.inline

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/nginx-blobfuse-inline-volume.yaml
 
## blobfuse.app.k8s.csi.azureblob.mount

```
# To create the resources
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
  annotations:
        volume.beta.kubernetes.io/storage-class: azureblob-fuse-premium
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-premium
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
    image: mcr.microsoft.com/oss/nginx/nginx:1.17.3-alpine
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
EOF
kubectl get po,pv,pvc
```

```
NAME        READY   STATUS    RESTARTS   AGE
pod/mypod   1/1     Running   0          13s
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                        STORAGECLASS             REASON   AGE
persistentvolume/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447   5Gi        RWX            Delete           Bound    default/pvc-azureblob-fuse   azureblob-fuse-premium            12s
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             AGE
persistentvolumeclaim/pvc-azureblob-fuse   Bound    pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447   5Gi        RWX            azureblob-fuse-premium   13s
```

```
# kubectl get po -owide
NAME    READY   STATUS    RESTARTS   AGE     IP           NODE                                NOMINATED NODE   READINESS GATES
mypod   1/1     Running   0          5m48s   10.244.1.2   aks-nodepool1-14487815-vmss00000t   <none>           <none>

# kubectl exec mypod -it -- df -h
Filesystem                Size      Used Available Use% Mounted on
blobfuse2              1000.0M         0   1000.0M   0% /mnt/blob

# kubectl exec mypod -it -- mount | grep /mnt
blobfuse2 on /mnt/blob type fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other)

# kubectl exec mypod -it -- mount -t fuse
blobfuse2 on /mnt/blob type fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other)

# root@aks-nodepool1-14487815-vmss00000T:/# mount | grep pvc-
blobfuse2 on /var/lib/kubelet/pods/0bc3b0e6-77f6-44f2-958c-939e6383cfa6/volumes/kubernetes.io~csi/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447/mount type fuse (rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other)

# /var/log/syslog
Aug  1 14:11:20 aks-nodepool1-14487815-vmss00000T kubelet[1616]: I0801 14:11:20.493940    1616 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#\") pod \"mypod\" (UID: \"0bc3b0e6-77f6-44f2-958c-939e6383cfa6\") " pod="default/mypod"
Aug  1 14:11:20 aks-nodepool1-14487815-vmss00000T kubelet[1616]: I0801 14:11:20.595046    1616 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#\") pod \"mypod\" (UID: \"0bc3b0e6-77f6-44f2-958c-939e6383cfa6\") " pod="default/mypod"
Aug  1 14:11:20 aks-nodepool1-14487815-vmss00000T blobfuse-proxy[3858]: I0801 14:11:20.666127    3858 server.go:67] received mount request: protocol: , server default blobfuseVersion: 1, mount args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --empty-dir-check=false --tmp-path=/mnt/mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# --container-name=pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 --pre-mount-validate=true --use-https=true
Aug  1 14:11:20 aks-nodepool1-14487815-vmss00000T blobfuse-proxy[3858]: I0801 14:11:20.666162    3858 server.go:76] append --ignore-open-flags=true to mount args
Aug  1 14:11:20 aks-nodepool1-14487815-vmss00000T blobfuse-proxy[3858]: I0801 14:11:20.666212    3858 server.go:80] mount with v2, protocol: , args: mount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --empty-dir-check=false --tmp-path=/mnt/mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# --container-name=pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 --pre-mount-validate=true --use-https=true --ignore-open-flags=true
Aug  1 14:11:22 aks-nodepool1-14487815-vmss00000T blobfuse-proxy[3858]: I0801 14:11:22.692667    3858 server.go:93] successfully mounted
Aug  1 14:11:22 aks-nodepool1-14487815-vmss00000T blobfuse-proxy[3858]: I0801 14:11:22.692687    3858 server.go:96] blobfuse output: *** blobfuse2: A new version [2.0.4] is available. Consider upgrading to latest version for bug-fixes & new features. ***
Aug  1 14:11:22 aks-nodepool1-14487815-vmss00000T kubelet[1616]: I0801 14:11:22.721375    1616 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#\") pod \"mypod\" (UID: \"0bc3b0e6-77f6-44f2-958c-939e6383cfa6\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount\"" pod="default/mypod"
Aug  1 14:11:22 aks-nodepool1-14487815-vmss00000T kubelet[1616]: I0801 14:11:22.733508    1616 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#\") pod \"mypod\" (UID: \"0bc3b0e6-77f6-44f2-958c-939e6383cfa6\") " pod="default/mypod"
```

```
# kubectl describe pv | grep VolumeH
    VolumeHandle:      mc_rg_aks_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#

# kubectl get po -n kube-system -owide | grep csi-blob | grep vmss00000t
csi-blob-node-hzzxc                   3/3     Running   0          24m     10.224.0.6    aks-nodepool1-14487815-vmss00000t   <none>           <none>

# kubectl logs -n kube-system csi-blob-node-hzzxc -c blob
I0801 14:11:20.599847    4041 utils.go:75] GRPC call: /csi.v1.Node/NodeStageVolume
I0801 14:11:20.599863    4041 utils.go:76] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["-o allow_other","--file-cache-timeout-in-seconds=120","--use-attr-cache=true","--cancel-list-on-mount-seconds=10","-o attr_timeout=120","-o entry_timeout=120","-o negative_timeout=120","--log-level=LOG_WARNING","--cache-size-mb=1000"]}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447","csi.storage.k8s.io/pv/name":"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447","csi.storage.k8s.io/pvc/name":"pvc-azureblob-fuse","csi.storage.k8s.io/pvc/namespace":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1690898500711-6097-blob.csi.azure.com"},"volume_id":"mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#"}
I0801 14:11:20.600274    4041 blob.go:416] volumeID(mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#) authEnv: []
I0801 14:11:20.664215    4041 blob.go:758] got storage account(fusea5e2a60b1f5b42c08bb) from secret
I0801 14:11:20.664256    4041 nodeserver.go:357] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount
protocol
volumeId mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#
context map[containername:pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 csi.storage.k8s.io/pv/name:pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 csi.storage.k8s.io/pvc/name:pvc-azureblob-fuse csi.storage.k8s.io/pvc/namespace:default secretnamespace:default skuName:Premium_LRS storage.kubernetes.io/csiProvisionerIdentity:1690898500711-6097-blob.csi.azure.com]
mountflags [-o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000]
mountOptions [-o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --empty-dir-check=false --tmp-path=/mnt/mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# --container-name=pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 --pre-mount-validate=true --use-https=true]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --empty-dir-check=false --tmp-path=/mnt/mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# --container-name=pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 --pre-mount-validate=true --use-https=true
serverAddress fusea5e2a60b1f5b42c08bb.blob.core.windows.net
I0801 14:11:20.664285    4041 nodeserver.go:154] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --empty-dir-check=false --tmp-path=/mnt/mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# --container-name=pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 --pre-mount-validate=true --use-https=true
I0801 14:11:20.665640    4041 nodeserver.go:163] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --empty-dir-check=false --tmp-path=/mnt/mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# --container-name=pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447 --pre-mount-validate=true --use-https=true
I0801 14:11:22.719896    4041 mount_linux.go:283] Detected umount with safe 'not mounted' behavior
I0801 14:11:22.720384    4041 nodeserver.go:593] blobfuse mount at /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount success
I0801 14:11:22.720508    4041 nodeserver.go:411] volume(mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#) mount on "/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount" succeeded
I0801 14:11:22.720522    4041 utils.go:82] GRPC response: {}
I0801 14:11:22.724980    4041 utils.go:75] GRPC call: /csi.v1.Node/NodePublishVolume
I0801 14:11:22.724993    4041 utils.go:76] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount","target_path":"/var/lib/kubelet/pods/0bc3b0e6-77f6-44f2-958c-939e6383cfa6/volumes/kubernetes.io~csi/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["-o allow_other","--file-cache-timeout-in-seconds=120","--use-attr-cache=true","--cancel-list-on-mount-seconds=10","-o attr_timeout=120","-o entry_timeout=120","-o negative_timeout=120","--log-level=LOG_WARNING","--cache-size-mb=1000"]}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447","csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"0bc3b0e6-77f6-44f2-958c-939e6383cfa6","csi.storage.k8s.io/pv/name":"pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447","csi.storage.k8s.io/pvc/name":"pvc-azureblob-fuse","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1690898500711-6097-blob.csi.azure.com"},"volume_id":"mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default#"}
I0801 14:11:22.725426    4041 nodeserver.go:127] NodePublishVolume: volume mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# mounting /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount at /var/lib/kubelet/pods/0bc3b0e6-77f6-44f2-958c-939e6383cfa6/volumes/kubernetes.io~csi/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447/mount with mountOptions: [bind]
I0801 14:11:22.725508    4041 mount_linux.go:244] Detected OS without systemd
I0801 14:11:22.725516    4041 mount_linux.go:219] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount /var/lib/kubelet/pods/0bc3b0e6-77f6-44f2-958c-939e6383cfa6/volumes/kubernetes.io~csi/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447/mount)
I0801 14:11:22.731921    4041 mount_linux.go:219] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount /var/lib/kubelet/pods/0bc3b0e6-77f6-44f2-958c-939e6383cfa6/volumes/kubernetes.io~csi/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447/mount)
I0801 14:11:22.733282    4041 nodeserver.go:143] NodePublishVolume: volume mc_secureshack2_aksblob_swedencentral#fusea5e2a60b1f5b42c08bb#pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447##default# mount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/4fab3de30c5e55f9335bb7ef28104333fd8d1309aa8bf4419be4add0227830bf/globalmount at /var/lib/kubelet/pods/0bc3b0e6-77f6-44f2-958c-939e6383cfa6/volumes/kubernetes.io~csi/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447/mount successfully
I0801 14:11:22.733299    4041 utils.go:82] GRPC response: {}
```

```
# To cleanup
kubectl delete po mypod
kubectl delete pvc pvc-azureblob-fuse
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision
- https://github.com/Azure/AKS/tree/master/vhd-notes
- https://github.com/Azure/azure-storage-fuse
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/csi-debug.md#troubleshooting-connection-failure-on-agent-node

## blobfuse.app.k8s.csi.azureblob.mount.cache

Scenario: File edits made through the blob (fuse) container are not immediately visible in the associated pod volume. For instance, edits can be performed in Storage Explorer by either double-clicking the file or selecting the file and clicking "Open", then updating the file.

- Environment: This pertains to a pod within an AKS cluster configured with --enable-blob-driver, using either a static or dynamic blobfuse volume.

- Root Cause Analysis (RCA): The issue stems from the local page cache at the node/pod level.

- Temporary Mitigation: To address this issue temporarily, ensure that blob file updates become visible in the pod by deleting the local cache on the node using the command associated with /proc/sys/vm/drop_caches.

- Solution: To resolve this, consider using the following configuration in a custom storage class for dynamic volumes or in a static persistent volume to disable the kernel page cache. Keep in mind that disabling the kernel cache may lead to increased calls to Azure Storage, potentially impacting cost and performance. You can verify the presence of these options using kubectl get pv -oyaml.

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azureblob-fuse-premium2
provisioner: blob.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
mountOptions:
  - -o allow_other
  - --cancel-list-on-mount-seconds=10  # prevent billing charges on mounting
  - --log-level=LOG_WARNING
  - --file-cache-timeout-in-seconds=0 # this
  - --use-attr-cache=false # this
  - --cache-size-mb=0 # this
  - -o direct_io # this
  - -o attr_timeout=0 # this too
  - -o entry_timeout=0 # this too
  - -o negative_timeout=0 # this too

kubectl exec -it mypod2 -- cat /mnt/blob/empty.txt
```

- https://github.com/Azure/azure-storage-fuse: Blobfuse2 supports both reads and writes however, it does not guarantee continuous sync of data written to storage using other APIs or other mounts of Blobfuse2. For data integrity it is recommended that multiple sources do not modify the same blob/file.
- https://github.com/Azure/azure-storage-fuse#frequently-asked-questions: Why am I not able to see the updated contents of file(s), which were updated through means other than Blobfuse2 mount?...
- https://github.com/Azure/azure-storage-fuse/issues/1235#issuecomment-1700767145

## blobfuse.app.k8s.csi.azureblob.opensource

Here are steps from https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-csi-driver-master.md to install the <ins>open-source</ins> Azure Blob Storage CSI driver. The support policy can be found [here](https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/support.md).

```
# Replace the below with appropriate values
rgname=resourceGroupName
clustername=aksblobpopen
```

```
# Install the cluster. Optionally, run az aks show for an existing cluster.
az aks create -g secureshack2 -n aksblobpopen

# To get credentials for running commands further below.
az aks get-credentials -g secureshack2 -n aksblobpopen
```

```
# Install the open-source Azure Blob CSI driver.
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/deploy/install-driver.sh | bash -s master blobfuse-proxy --

# Here is a sample output below.
Installing Azure Blob Storage CSI driver, version: master ...
serviceaccount/csi-blob-controller-sa created
clusterrole.rbac.authorization.k8s.io/blob-external-provisioner-role created
clusterrolebinding.rbac.authorization.k8s.io/blob-csi-provisioner-binding created
clusterrole.rbac.authorization.k8s.io/blob-external-resizer-role created
clusterrolebinding.rbac.authorization.k8s.io/blob-csi-resizer-role created
clusterrole.rbac.authorization.k8s.io/csi-blob-controller-secret-role created
clusterrolebinding.rbac.authorization.k8s.io/csi-blob-controller-secret-binding created
serviceaccount/csi-blob-node-sa configured
clusterrole.rbac.authorization.k8s.io/csi-blob-node-secret-role configured
clusterrolebinding.rbac.authorization.k8s.io/csi-blob-node-secret-binding configured
csidriver.storage.k8s.io/blob.csi.azure.com configured
deployment.apps/csi-blob-controller created
set enable-blobfuse-proxy as true ...
daemonset.apps/csi-blob-node configured
Azure Blob Storage CSI driver installed successfully.
```

```
# To retrieve related pods:
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below. Each node has a csi-blob-node pod. There are also controller pods.
# csi-blob-controller-fdf6d487c-tcxd7   4/4     Running   0          7m8s   10.224.0.5    aks-nodepool1-37173752-vmss000002   <none>           <none>
# csi-blob-controller-fdf6d487c-wfn2n   4/4     Running   0          7m8s   10.224.0.6    aks-nodepool1-37173752-vmss000001   <none>           <none>
# csi-blob-node-gnqtd                   3/3     Running   0          7m8s   10.224.0.4    aks-nodepool1-37173752-vmss000000   <none>           <none>
# csi-blob-node-rnvpt                   3/3     Running   0          7m8s   10.224.0.6    aks-nodepool1-37173752-vmss000001   <none>           <none>
# csi-blob-node-t4nmf                   3/3     Running   0          7m8s   10.224.0.5    aks-nodepool1-37173752-vmss000002   <none>           <none>

# To retrieve the image, use the following command:
kubectl get po -n kube-system csi-blob-node-gnqtd -oyaml | grep image: | grep blob

# Here is a sample output below.
#    image: mcr.microsoft.com/k8s/csi/blob-csi:latest
```

## blobfuse.app.k8s.csi.azureblob.mount.secret

A kubernetes secret object is automatically created for a dynamically created azureblob-fuse PVC. This object has a naming convention `azure-storage-account-<storageAccountName>-secret`. Such an object must be manually created for a static PVC. Regardless of the creation method, this object contains the storage account name and the key.

```
# kubectl get secret
NAME                                                   TYPE     DATA   AGE
azure-storage-account-fusea5e2a60b1f5b42c08bb-secret   Opaque   2      41s

# kubectl get secret -oyaml azure-storage-account-fusea5e2a60b1f5b42c08bb-secret
apiVersion: v1
data:
  azurestorageaccountkey: redacted==
  azurestorageaccountname: ZnVzZWE1ZTJhNjBiMWY1YjQyYzA4YmI=
kind: Secret
metadata:
  creationTimestamp: "2023-08-01T17:39:35Z"
  name: azure-storage-account-fusea5e2a60b1f5b42c08bb-secret
  namespace: default
  resourceVersion: "3641957"
  uid: 65ea9e9d-0dd3-4aea-a2a4-2d0a86cfaa63
type: Opaque
```

The values of both the azurestorageaccountkey and the azurestorageaccountname can be verified with a base64 conversion.

```
# echo -n 'ZnVzZWE1ZTJhNjBiMWY1YjQyYzA4YmI=' | base64 --decode ;echo
fusea5e2a60b1f5b42c08bb
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/mounting-azure-blob-storage-container-fail#cause1-for-blobfuse-error2

## blobfuse.app.k8s.csi.azureblob.storageclass.custom

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#storage-class-using-blobfuse
- https://github.com/Azure/azure-storage-fuse#cli-parameters

## blobfuse.app.k8s.csi.azureblob.version

```
rg=rgblob
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-blob-driver
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no

kubectl describe ds csi-blob-node -n kube-system
  Init Containers:
   install-blobfuse-proxy:
    Image:      mcr.microsoft.com/oss/kubernetes-csi/blob-csi:v1.21.4
    Port:       <none>
    Host Port:  <none>
    Command:
      /blobfuse-proxy/init.sh
    Environment:
      DEBIAN_FRONTEND:        noninteractive
      INSTALL_BLOBFUSE:       false
      BLOBFUSE_VERSION:       1.4.4

root@aks-nodepool1-40777476-vmss000000:/# blobfuse2 -v
blobfuse2 version 2.0.5
root@aks-nodepool1-40777476-vmss000000:/# blobfuse
blobfuse: command not found
```

- https://github.com/kubernetes-sigs/blob-csi-driver/tree/master#install-driver-on-a-kubernetes-cluster: kubectl patch daemonset csi-blob-node -n kube-system -p '{"spec":{"template":{"spec":{"initContainers":[{"env":[{"name":"INSTALL_BLOBFUSE2","value":"true"},{"name":"BLOBFUSE2_VERSION","value":"2.0.5"}],"name":"install-blobfuse-proxy"}]}}}}' (Pods get terminated and replaced by new ones)
- https://github.com/Azure/AKS/blob/master/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202308.16.0.txt: blobfuse2/jammy,now 2.0.5 amd64 [installed]
