```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/cloning/pvc-azuredisk-cloning.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/cloning/nginx-pod-restored-cloning.yaml

# Or

cat << EOF | kubectl apply -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk-cloning
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-csi
  resources:
    requests:
      storage: 300Gi
  dataSource:
    kind: PersistentVolumeClaim
    name: pvc-azuredisk
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-restored-cloning
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: mcr.microsoft.com/oss/nginx/nginx:1.17.3-alpine
      name: nginx-restored-cloning
      args:
        - sleep
        - "3600"
      volumeMounts:
        - name: azuredisk-cloning
          mountPath: "/mnt/azuredisk"
  volumes:
    - name: azuredisk-cloning
      persistentVolumeClaim:
        claimName: pvc-azuredisk-cloning
EOF
sleep 20
kubectl exec nginx-restored-cloning -- ls /mnt/azuredisk
# lost+found
```

```
kubectl logs -n kube-system csi-azuredisk-node-8cvq8 -cazuredisk
I0908 10:46:19.394992       1 utils.go:77] GRPC call: /csi.v1.Node/NodeStageVolume
I0908 10:46:19.395005       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"2"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk-cloning","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"300","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694163535674-4216-disk.csi.azure.com"},"volume_id":"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5"}
I0908 10:46:19.407065       1 azure_common_linux.go:164] model doesn't match VHD, got Virtual DVD-ROM
I0908 10:46:19.407172       1 azure_common_linux.go:185] azureDisk - found /dev/disk/azure/scsi1/lun2 by sde under /dev/disk/azure/scsi1/
I0908 10:46:19.407194       1 nodeserver.go:116] NodeStageVolume: perf optimization is disabled for /dev/disk/azure/scsi1/lun2. perfProfile none accountType StandardSSD_LRS
I0908 10:46:19.407432       1 nodeserver.go:157] NodeStageVolume: formatting /dev/disk/azure/scsi1/lun2 and mounting at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount with mount options([])
I0908 10:46:19.407444       1 mount_linux.go:567] Attempting to determine if disk "/dev/disk/azure/scsi1/lun2" is formatted using blkid with args: ([-p -s TYPE -s PTTYPE -o export /dev/disk/azure/scsi1/lun2])
I0908 10:46:19.416853       1 mount_linux.go:570] Output: "DEVNAME=/dev/disk/azure/scsi1/lun2\nTYPE=ext4\n"
I0908 10:46:19.416868       1 mount_linux.go:453] Checking for issues with fsck on disk: /dev/disk/azure/scsi1/lun2
I0908 10:46:19.547556       1 mount_linux.go:557] Attempting to mount disk /dev/disk/azure/scsi1/lun2 in ext4 format at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount
I0908 10:46:19.547584       1 mount_linux.go:220] Mounting cmd (mount) with arguments (-t ext4 -o defaults /dev/disk/azure/scsi1/lun2 /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount)
I0908 10:46:19.561476       1 nodeserver.go:161] NodeStageVolume: format /dev/disk/azure/scsi1/lun2 and mounting at /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount successfully.
I0908 10:46:19.566861       1 mount_linux.go:567] Attempting to determine if disk "/dev/disk/azure/scsi1/lun2" is formatted using blkid with args: ([-p -s TYPE -s PTTYPE -o export /dev/disk/azure/scsi1/lun2])
I0908 10:46:19.573071       1 mount_linux.go:570] Output: "DEVNAME=/dev/disk/azure/scsi1/lun2\nTYPE=ext4\n"
I0908 10:46:19.573084       1 resizefs_linux.go:139] ResizeFs.needResize - checking mounted volume /dev/disk/azure/scsi1/lun2
I0908 10:46:19.574211       1 resizefs_linux.go:143] Ext size: filesystem size=322122547200, block size=4096
I0908 10:46:19.574227       1 resizefs_linux.go:158] Volume /dev/disk/azure/scsi1/lun2: device size=322122547200, filesystem size=322122547200, block size=4096
I0908 10:46:19.574238       1 utils.go:84] GRPC response: {}
I0908 10:46:19.589333       1 utils.go:77] GRPC call: /csi.v1.Node/NodePublishVolume
I0908 10:46:19.589344       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"2"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount","target_path":"/var/lib/kubelet/pods/07171713-9abf-4b11-96cb-cfe6117dc858/volumes/kubernetes.io~csi/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk-cloning","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"300","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694163535674-4216-disk.csi.azure.com"},"volume_id":"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5"}
I0908 10:46:19.589705       1 nodeserver.go:279] NodePublishVolume: mounting /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount at /var/lib/kubelet/pods/07171713-9abf-4b11-96cb-cfe6117dc858/volumes/kubernetes.io~csi/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5/mount
I0908 10:46:19.589717       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount /var/lib/kubelet/pods/07171713-9abf-4b11-96cb-cfe6117dc858/volumes/kubernetes.io~csi/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5/mount)
I0908 10:46:19.594330       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount /var/lib/kubelet/pods/07171713-9abf-4b11-96cb-cfe6117dc858/volumes/kubernetes.io~csi/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5/mount)
I0908 10:46:19.595165       1 nodeserver.go:284] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount at /var/lib/kubelet/pods/07171713-9abf-4b11-96cb-cfe6117dc858/volumes/kubernetes.io~csi/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5/mount successfully
I0908 10:46:19.595177       1 utils.go:84] GRPC response: {}
```

```
root@aks-nodepool1-14195140-vmss000002:/# cat /var/log/syslog | grep pvc-
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.440867] scsi 1:0:0:2: Direct-Access     Msft     Virtual Disk     1.0  PQ: 0 ANSI: 5
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.449923] sd 1:0:0:2: Attached scsi generic sg5 type 0
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.453689] sd 1:0:0:2: [sde] 629145600 512-byte logical blocks: (322 GB/300 GiB)
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.453692] sd 1:0:0:2: [sde] 4096-byte physical blocks
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.453730] sd 1:0:0:2: [sde] Write Protect is off
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.453731] sd 1:0:0:2: [sde] Mode Sense: 0f 00 10 00
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.453927] sd 1:0:0:2: [sde] Write cache: disabled, read cache: enabled, supports DPO and FUA
Sep  8 10:46:14 aks-nodepool1-14195140-vmss000002 kernel: [ 6416.527648] sd 1:0:0:2: [sde] Attached SCSI disk
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.278605    2522 reconciler_common.go:253] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") " pod="default/nginx-restored-cloning"
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.289164    2522 operation_generator.go:1592] "Controller attach succeeded for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") device path: \"\"" pod="default/nginx-restored-cloning"
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.379657    2522 reconciler_common.go:228] "operationExecutor.MountVolume started for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") " pod="default/nginx-restored-cloning"
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.379854    2522 operation_generator.go:616] "MountVolume.WaitForAttach entering for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") DevicePath \"\"" pod="default/nginx-restored-cloning"
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.389008    2522 operation_generator.go:626] "MountVolume.WaitForAttach succeeded for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") DevicePath \"csi-2144832bdb625709012597adbd1ae11cf87236dcf290a79b902d1a34003057e3\"" pod="default/nginx-restored-cloning"
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kernel: [ 6421.094079] EXT4-fs (sde): mounted filesystem with ordered data mode. Opts: (null). Quota mode: none.
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.574539    2522 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/da00f703f82f92179b561fb0573730fb66b9a5fe2fa5be9a14bd21c5064062e5/globalmount\"" pod="default/nginx-restored-cloning"
Sep  8 10:46:19 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 10:46:19.595449    2522 operation_generator.go:740] "MountVolume.SetUp succeeded for volume \"pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-5d3e27b6-19a7-4d2c-9f0c-20a76c0348d5\") pod \"nginx-restored-cloning\" (UID: \"07171713-9abf-4b11-96cb-cfe6117dc858\") " pod="default/nginx-restored-cloning"
```

```
kubectl delete po nginx-restored-cloning
kubectl delete pvc pvc-azuredisk-cloning
```

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/cloning/nginx-pod-restored-cloning.yaml
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#volume-cloning
- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#clone-volumes
