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
```

```
# kubectl get po,pv,pvc
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
