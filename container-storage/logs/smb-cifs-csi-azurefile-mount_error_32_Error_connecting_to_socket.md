The mount failure with exit status 32 is due to connectivity issues while connecting to the socket. To resolve this, check the outbound traffic to the appropriate port from the node or pod. For pods created with Azure Files, the default protocol is SMB, so the port to be checked is 445.

```
# Create the resources
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
    kubernetes.io/hostname: aks-nodepool1-16524978-vmss000005
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
# kubectl get po
NAME             READY   STATUS              RESTARTS   AGE
mypod            0/1     ContainerCreating   0          9m35s

# kubectl describe pod for outbound traffic is blocked on SMB port 445. The pod has been created with an Azure File ReadWriteMany mount using the default SMB protocol.
  Warning  FailedMount       5s                 kubelet            MountVolume.MountDevice failed for volume "pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2" : rpc error: code = Internal desc = volume(mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default) mount //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount failed with mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o mfsymlinks,actimeo=30,nosharesock,file_mode=0777,dir_mode=0777,<masked> //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount
Output: mount error(115): Operation now in progress
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)

# /var/log/syslog
Jul  5 09:33:52 aks-nodepool1-51397738-vmss000007 kubelet[1623]: I0705 09:33:52.450098    1623 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default\") pod \"mypod\" (UID: \"c0818f8e-1171-4b8d-a74a-daa7608d5536\") " pod="default/mypod"
Jul  5 09:33:52 aks-nodepool1-51397738-vmss000007 kubelet[1623]: I0705 09:33:52.551641    1623 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2\" (UniqueName: \"kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default\") pod \"mypod\" (UID: \"c0818f8e-1171-4b8d-a74a-daa7608d5536\") " pod="default/mypod"
Jul  5 09:33:53 aks-nodepool1-51397738-vmss000007 kernel: [ 1183.470774] CIFS: No dialect specified on mount. Default has changed to a more secure dialect, SMB2.1 or later (e.g. SMB3.1.1), from CIFS (SMB1). To use the less secure SMB1 dialect to access old servers which do not support SMB3.1.1 (or even SMB3 or SMB2.1) specify vers=1.0 on mount.
Jul  5 09:33:53 aks-nodepool1-51397738-vmss000007 kernel: [ 1183.470777] CIFS: Attempting to mount \\fe009272cfd2b4a3d8340d5.file.core.windows.net\pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2
Jul  5 09:34:03 aks-nodepool1-51397738-vmss000007 kernel: [ 1193.623715] CIFS: VFS: Error connecting to socket. Aborting operation.
Jul  5 09:34:03 aks-nodepool1-51397738-vmss000007 kernel: [ 1193.628133] CIFS: VFS: cifs_mount failed w/return code = -115
Jul  5 09:34:03 aks-nodepool1-51397738-vmss000007 kubelet[1623]: E0705 09:34:03.493519    1623 csi_attacher.go:345] kubernetes.io/csi: attacher.MountDevice failed: rpc error: code = Internal desc = volume(mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default) mount //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount failed with mount failed: exit status 32
Jul  5 09:34:03 aks-nodepool1-51397738-vmss000007 kubelet[1623]: E0705 09:34:03.493775    1623 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default podName: nodeName:}" failed. No retries permitted until 2023-07-05 09:34:03.993746082 +0000 UTC m=+1166.556354969 (durationBeforeRetry 500ms). Error: MountVolume.MountDevice failed for volume "pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2" (UniqueName: "kubernetes.io/csi/file.csi.azure.com^mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default") pod "mypod" (UID: "c0818f8e-1171-4b8d-a74a-daa7608d5536") : rpc error: code = Internal desc = volume(mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default) mount //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount failed with mount failed: exit status 32

# kubectl logs -n kube-system csi-azurefile-node-5ncjb -c azurefile
I0705 09:33:52.557098       1 utils.go:76] GRPC call: /csi.v1.Node/NodeStageVolume
I0705 09:33:52.557114       1 utils.go:77] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["mfsymlinks","actimeo=30","nosharesock"]}},"access_mode":{"mode":5}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2","csi.storage.k8s.io/pvc/name":"my-azurefile","csi.storage.k8s.io/pvc/namespace":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1688548448541-8081-file.csi.azure.com"},"volume_id":"mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default"}
I0705 09:33:52.620902       1 nodeserver.go:302] cifsMountPath(/var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount) fstype() volumeID(mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default) context(map[csi.storage.k8s.io/pv/name:pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 csi.storage.k8s.io/pvc/name:my-azurefile csi.storage.k8s.io/pvc/namespace:default secretnamespace:default skuName:Premium_LRS storage.kubernetes.io/csiProvisionerIdentity:1688548448541-8081-file.csi.azure.com]) mountflags([mfsymlinks actimeo=30 nosharesock]) mountOptions([mfsymlinks actimeo=30 nosharesock file_mode=0777 dir_mode=0777]) volumeMountGroup()
E0705 09:34:03.492906       1 mount_linux.go:195] Mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o mfsymlinks,actimeo=30,nosharesock,file_mode=0777,dir_mode=0777,<masked> //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount
Output: mount error(115): Operation now in progress
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
E0705 09:34:03.492961       1 utils.go:81] GRPC error: rpc error: code = Internal desc = volume(mc_secureshack2_aks_swedencentral#fe009272cfd2b4a3d8340d5#pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2###default) mount //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount failed with mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o mfsymlinks,actimeo=30,nosharesock,file_mode=0777,dir_mode=0777,<masked> //fe009272cfd2b4a3d8340d5.file.core.windows.net/pvc-ed4ca7d1-4e7d-4047-8d98-925e94fc32f2 /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/1570d020929c850cbc0fe0a669931eca40991f0b426061ed9eedc50c998d925b/globalmount
Output: mount error(115): Operation now in progress
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)

# telnet fe009272cfd2b4a3d8340d5.file.core.windows.net 445. This is from the node or pod.
Trying 20.60.79.8...
telnet: Unable to connect to remote host: Connection timed out
```

```
# kubectl describe po in cluster version 1.26
  Warning  FailedMount  3s    kubelet            MountVolume.MountDevice failed for volume "pvc-cec99d1b-a098-4785-8574-2e30a3acf254" : rpc error: code = Internal desc = volume(mc_rg_aks_swedencentral#mystorageacct21395#pvc-cec99d1b-a098-4785-8574-2e30a3acf254###default) mount //mystorageacct21395.file.core.windows.net/pvc-cec99d1b-a098-4785-8574-2e30a3acf254 on /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/321f4ab61a5b3c8f1d8249412d8d6d1d76000ff56a412914af3c5b7710f2baf7/globalmount failed with mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t cifs -o mfsymlinks,actimeo=30,nosharesock,file_mode=0777,dir_mode=0777,<masked> //mystorageacct21395.file.core.windows.net/pvc-cec99d1b-a098-4785-8574-2e30a3acf254 /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/321f4ab61a5b3c8f1d8249412d8d6d1d76000ff56a412914af3c5b7710f2baf7/globalmount
Output: mount error(115): Operation in progress
Refer to the mount.cifs(8) manual page (e.g. man mount.cifs) and kernel log messages (dmesg)
Please refer to http://aka.ms/filemounterror for possible causes and solutions for mount errors.
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/pull/1179/files
