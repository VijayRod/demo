These steps are to be followed after installing the Azure Blob CSI storage driver mentioned in https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi.

```
# To create the resources
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-blob-storage
  annotations:
        volume.beta.kubernetes.io/storage-class: azureblob-nfs-premium
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-nfs-premium
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
        claimName: azure-blob-storage
EOF
```

```
# kubectl get po,pv,pvc
NAME        READY   STATUS    RESTARTS   AGE
pod/mypod   1/1     Running   0          2m44s
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                        STORAGECLASS            REASON   AGE
persistentvolume/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183   5Gi        RWX            Delete           Bound    default/azure-blob-storage   azureblob-nfs-premium            106s
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS            AGE
persistentvolumeclaim/azure-blob-storage   Bound    pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183   5Gi        RWX            azureblob-nfs-premium   2m44s
```

```
# kubectl get po -owide
NAME    READY   STATUS    RESTARTS   AGE     IP           NODE                                NOMINATED NODE   READINESS GATES
mypod   1/1     Running   0          3m18s   10.244.2.2   aks-nodepool1-14487815-vmss00000p   <none>           <none>

# kubectl exec mypod -it -- df -h
Filesystem                Size      Used Available Use% Mounted on
nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183
                          5.0P         0      5.0P   0% /mnt/blob

# kubectl exec mypod -it -- mount | grep pvc
nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 on /mnt/blob type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,port=2048,timeo=600,retrans=2,sec=sys,mountaddr=20.60.79.4,mountvers=3,mountport=2048,mountproto=tcp,local_lock=all,addr=20.60.79.4)

# kubectl exec mypod -it -- mount -t nfs
nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 on /mnt/blob type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,port=2048,timeo=600,retrans=2,sec=sys,mountaddr=20.60.79.4,mountvers=3,mountport=2048,mountproto=tcp,local_lock=all,addr=20.60.79.4)

# root@aks-nodepool1-14487815-vmss00000P:/# mount | grep pvc-b99827c6
nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 on /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,port=2048,timeo=600,retrans=2,sec=sys,mountaddr=20.60.79.4,mountvers=3,mountport=2048,mountproto=tcp,local_lock=all,addr=20.60.79.4)
nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 on /var/lib/kubelet/pods/9702c0b1-570a-4f43-ad49-ad46b0a40acc/volumes/kubernetes.io~csi/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183/mount type nfs (rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nolock,proto=tcp,port=2048,timeo=600,retrans=2,sec=sys,mountaddr=20.60.79.4,mountvers=3,mountport=2048,mountproto=tcp,local_lock=all,addr=20.60.79.4)

# /var/log/syslog
Jul 25 10:40:42 aks-nodepool1-14487815-vmss00000P kubelet[1616]: I0725 10:40:42.122544    1616 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#\") pod \"mypod\" (UID: \"9702c0b1-570a-4f43-ad49-ad46b0a40acc\") " pod="default/mypod"
Jul 25 10:40:42 aks-nodepool1-14487815-vmss00000P kubelet[1616]: I0725 10:40:42.223205    1616 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#\") pod \"mypod\" (UID: \"9702c0b1-570a-4f43-ad49-ad46b0a40acc\") " pod="default/mypod"
Jul 25 10:40:45 aks-nodepool1-14487815-vmss00000P kernel: [  276.830366] FS-Cache: Loaded
Jul 25 10:40:45 aks-nodepool1-14487815-vmss00000P kernel: [  276.870718] FS-Cache: Netfs 'nfs' registered for caching
Jul 25 10:40:45 aks-nodepool1-14487815-vmss00000P kubelet[1616]: I0725 10:40:45.483054    1616 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#\") pod \"mypod\" (UID: \"9702c0b1-570a-4f43-ad49-ad46b0a40acc\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount\"" pod="default/mypod"
Jul 25 10:40:45 aks-nodepool1-14487815-vmss00000P kubelet[1616]: I0725 10:40:45.488926    1616 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183\" (UniqueName: \"kubernetes.io/csi/blob.csi.azure.com^mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#\") pod \"mypod\" (UID: \"9702c0b1-570a-4f43-ad49-ad46b0a40acc\") " pod="default/mypod"
```

```
# kubectl get po -n kube-system -owide | grep csi-blob | grep vmss00000p
csi-blob-node-k9qd2                   3/3     Running   0          26m   10.224.0.5   aks-nodepool1-14487815-vmss00000p   <none>           <none>

# kubectl logs -n kube-system csi-blob-node-k9qd2 -c blob
I0725 10:37:28.298207    4116 utils.go:82] GRPC response: {"node_id":"aks-nodepool1-14487815-vmss00000p"}
I0725 10:40:42.226621    4116 utils.go:75] GRPC call: /csi.v1.Node/NodeStageVolume
I0725 10:40:42.226636    4116 utils.go:76] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183","csi.storage.k8s.io/pv/name":"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183","csi.storage.k8s.io/pvc/name":"azure-blob-storage","csi.storage.k8s.io/pvc/namespace":"default","protocol":"nfs","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1690281329968-2651-blob.csi.azure.com"},"volume_id":"mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#"}
I0725 10:40:42.227008    4116 blob.go:416] volumeID(mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#) authEnv: []
I0725 10:40:42.227024    4116 nodeserver.go:315] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount
protocol nfs
volumeId mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#
context map[containername:pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 csi.storage.k8s.io/pv/name:pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 csi.storage.k8s.io/pvc/name:azure-blob-storage csi.storage.k8s.io/pvc/namespace:default protocol:nfs secretnamespace:default skuName:Premium_LRS storage.kubernetes.io/csiProvisionerIdentity:1690281329968-2651-blob.csi.azure.com]
mountflags []
serverAddress nfsd1e1b9f5405a439690cd.blob.core.windows.net
I0725 10:40:42.227103    4116 mount_linux.go:244] Detected OS without systemd
I0725 10:40:42.227108    4116 mount_linux.go:219] Mounting cmd (mount) with arguments (-t nfs -o sec=sys,vers=3,nolock nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount)
I0725 10:40:45.455733    4116 blob.go:851] chmod targetPath(/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount, mode:020000000750) with permissions(0777)
I0725 10:40:45.482639    4116 nodeserver.go:334] volume(mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#) mount nfsd1e1b9f5405a439690cd.blob.core.windows.net:/nfsd1e1b9f5405a439690cd/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183 on /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount succeeded
I0725 10:40:45.482676    4116 utils.go:82] GRPC response: {}
I0725 10:40:45.485410    4116 utils.go:75] GRPC call: /csi.v1.Node/NodePublishVolume
I0725 10:40:45.485423    4116 utils.go:76] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount","target_path":"/var/lib/kubelet/pods/9702c0b1-570a-4f43-ad49-ad46b0a40acc/volumes/kubernetes.io~csi/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183","csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"9702c0b1-570a-4f43-ad49-ad46b0a40acc","csi.storage.k8s.io/pv/name":"pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183","csi.storage.k8s.io/pvc/name":"azure-blob-storage","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","protocol":"nfs","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1690281329968-2651-blob.csi.azure.com"},"volume_id":"mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default#"}
I0725 10:40:45.485829    4116 nodeserver.go:127] NodePublishVolume: volume mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default# mounting /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount at /var/lib/kubelet/pods/9702c0b1-570a-4f43-ad49-ad46b0a40acc/volumes/kubernetes.io~csi/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183/mount with mountOptions: [bind]
I0725 10:40:45.485846    4116 mount_linux.go:219] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount /var/lib/kubelet/pods/9702c0b1-570a-4f43-ad49-ad46b0a40acc/volumes/kubernetes.io~csi/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183/mount)
I0725 10:40:45.487410    4116 mount_linux.go:219] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount /var/lib/kubelet/pods/9702c0b1-570a-4f43-ad49-ad46b0a40acc/volumes/kubernetes.io~csi/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183/mount)
I0725 10:40:45.488629    4116 nodeserver.go:143] NodePublishVolume: volume mc_secureshack2_aksblob_swedencentral#nfsd1e1b9f5405a439690cd#pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183##default# mount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/468bbce0eb7e82f6d2775d23ec1a5c6c8fd58d69a1fcc5bee2f15806101224f4/globalmount at /var/lib/kubelet/pods/9702c0b1-570a-4f43-ad49-ad46b0a40acc/volumes/kubernetes.io~csi/pvc-b99827c6-a0d6-4841-b085-bb66f8c3c183/mount successfully
I0725 10:40:45.488642    4116 utils.go:82] GRPC response: {}
```

```
# To cleanup
kubectl delete po mypod
kubectl delete pvc azure-blob-storage
```
