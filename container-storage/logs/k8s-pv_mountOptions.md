## k8s-pv.mount

```
# New node
root@aks-nodepool1-74128781-vmss000000:/# mount -a
root@aks-nodepool1-74128781-vmss000000:/# cat /etc/fstab
# CLOUD_IMG: This file was created/modified by the Cloud Image build process
UUID=0b58668a-ba2e-4a00-b89a-3354b7a547d4       /        ext4   discard,errors=remount-ro       0 1
UUID=C83D-C1E5  /boot/efi       vfat    umask=0077      0 1	/dev/disk/cloud/azure_resource-part1    /mnt    auto    defaults,nofail,x-systemd.after=cloud-init.service,_netdev,comment=cloudconfig      0       2
```

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#mount-options
- https://kubernetes.io/docs/concepts/storage/storage-classes/#mount-options

## k8s-pv.mount.debug

```
mount -a
mount -v
cat /etc/fstab
```
