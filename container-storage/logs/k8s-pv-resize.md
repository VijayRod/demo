```
kubectl patch pvc pvc-azuredisk -p '{"spec":{"resources":{"requests":{"storage":"300Gi"}}}}' --type=merge
```

```
kubectl describe pvc
  Normal   ExternalProvisioning        45m   persistentvolume-controller
                            waiting for a volume to be created, either by external provisioner "disk.csi.azure.com" or manually created by system administrator
  Normal   Provisioning                45m   disk.csi.azure.com_csi-azuredisk-controller-7cc6b44f59-mwdwj_2a2e453e-506c-40fa-abe8-6d9879c44964  External provisioner is provisioning volume for claim "default/pvc-azuredisk"
  Normal   ProvisioningSucceeded       45m   disk.csi.azure.com_csi-azuredisk-controller-7cc6b44f59-mwdwj_2a2e453e-506c-40fa-abe8-6d9879c44964  Successfully provisioned volume pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee
  Warning  ExternalExpanding           40m   volume_expand
                            Ignoring the PVC: didn't find a plugin capable of expanding the volume; waiting for an external controller to process this PVC.
  Normal   Resizing                    40m   external-resizer disk.csi.azure.com
                            External resizer is resizing volume pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee
  Normal   FileSystemResizeRequired    34m   external-resizer disk.csi.azure.com
                            Require file system resize of volume on node
  Normal   FileSystemResizeSuccessful  34m   kubelet
                            MountVolume.NodeExpandVolume succeeded for volume "pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee" aks-nodepool1-14195140-vmss000002
                            
kubectl logs -n kube-system csi-azuredisk-node-8cvq8 -c azuredisk
I0908 09:23:22.307473       1 utils.go:77] GRPC call: /csi.v1.Node/NodeExpandVolume
I0908 09:23:22.307489       1 utils.go:78] GRPC request: {"capacity_range":{"required_bytes":322122547200},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/bbea9c19ac87099aa37861717c12ff9f356a45e12b31f97511dc5fd1eb200014/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_id":"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee","volume_path":"/var/lib/kubelet/pods/50a119c7-c4b5-49d1-b695-efb346eb7248/volumes/kubernetes.io~csi/pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee/mount"}
I0908 09:23:22.401403       1 nodeserver.go:478] NodeExpandVolume begin to rescan device %s on volume(%s)/dev/sdc/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee
I0908 09:23:22.419107       1 mount_linux.go:567] Attempting to determine if disk "/dev/sdc" is formatted using blkid with args: ([-p -s TYPE -s PTTYPE -o export /dev/sdc])
I0908 09:23:22.420661       1 mount_linux.go:570] Output: "DEVNAME=/dev/sdc\nTYPE=ext4\n"
I0908 09:23:22.420683       1 resizefs_linux.go:60] ResizeFS.Resize - Expanding mounted volume /dev/sdc
I0908 09:23:24.508069       1 resizefs_linux.go:75] Device /dev/sdc resized successfully
I0908 09:23:24.508620       1 nodeserver.go:503] NodeExpandVolume succeeded on resizing volume /subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee to 322122547200
I0908 09:23:24.508647       1 utils.go:84] GRPC response: {"capacity_bytes":322122547200}
```

```
root@aks-nodepool1-14195140-vmss000002:/# cat /var/log/syslog | grep pvc-
Sep  8 09:23:22 aks-nodepool1-14195140-vmss000002 kernel: [ 1443.964700] EXT4-fs (sdc): resizing filesystem from 65536000 to 78643200 blocks
Sep  8 09:23:24 aks-nodepool1-14195140-vmss000002 kernel: [ 1446.002055] EXT4-fs (sdc): resized filesystem to 78643200
Sep  8 09:23:24 aks-nodepool1-14195140-vmss000002 kubelet[2522]: I0908 09:23:24.509055    2522 operation_generator.go:2227] "MountVolume.NodeExpandVolume succeeded for volume \"pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee\" (UniqueName: \"kubernetes.io/csi/disk.csi.azure.com^/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-eeeadfac-4eaf-4929-8e86-a8663e48dcee\") pod \"fiopod\" (UID: \"50a119c7-c4b5-49d1-b695-efb346eb7248\") aks-nodepool1-14195140-vmss000002" pod="default/fiopod"

kubectl describe sc managed-csi-premium | grep Exp
AllowVolumeExpansion:  True
```

- https://kubernetes.io/blog/2022/05/05/volume-expansion-ga/
- https://kubernetes.io/docs/concepts/storage/volumes/: node-initiated storage resize operations
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#built-in-storage-classes: It's not supported to reduce the size of a PVC (to prevent data loss)...
- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#resize-a-persistent-volume-without-downtime
- https://learn.microsoft.com/en-us/azure/azure-arc/data/resize-persistent-volume-claim
- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/downsize-data-disk-without-losing-data
- https://learn.microsoft.com/en-us/azure/virtual-machines/faq-for-disks: Can I shrink or downsize my managed disks? No.
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recovering-from-failure-when-expanding-volumes
- https://github.com/kubernetes/kubernetes/issues/68427: ~ earlier could only resize azure disk when it's in "unattached" state i.e. before dynamic resize
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/issues/273: ~ (earlier) could only resize azure disk when it's in "unattached" state i.e. before dynamic resize
- https://azure.microsoft.com/en-us/updates/live-resize-of-azure-disk-storage-in-public-preview/
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/known-issues/sizegrow.md
