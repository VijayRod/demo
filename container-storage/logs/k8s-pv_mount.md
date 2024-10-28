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
mount # list
# mount -a # mount all filesystems mentioned in fstab
mount -v

cat /etc/fstab
cat /proc/fs/cifs/Stats

cat /var/log/syslog | Or cat /var/log/messages | grep kernel
```

## k8s-pv.mount.debug.mode

```
kind: StorageClass
mountOptions:
 - dir_mode=0777
 - file_mode=0777

kind: PersistentVolume
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    
kind: Pod
  volumes:
  - name: azure
    csi:
      readOnly: false
      volumeAttributes:
        mountOptions: "dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock"  # optional

kubectl get pv # ACCESS MODES
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                        STORAGECLASS             REASON   AGE
persistentvolume/pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447   5Gi        RWX            Delete           Bound    default/pvc-azureblob-fuse   azureblob-fuse-premium            12s
kubectl get pvc # ACCESS MODES
NAME                                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS             AGE
persistentvolumeclaim/pvc-azureblob-fuse   Bound    pvc-19fb3f5e-af96-4f42-bc39-daf0d62d2447   5Gi        RWX            azureblob-fuse-premium   13s

mount | grep pvc
//smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5 on /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=USERNAME,uid=1001,noforceuid,gid=1001,noforcegid,addr=10.0.194.14,file_mode=0777,dir_mode=0777,soft,nounix,mapposix,mfsymlinks,noperm,rsize=4194304,wsize=4194304,bsize=1048576,echo_interval=60,actimeo=1,closetimeo=1)
```

- https://linux.die.net/Linux-CLI/x9543.htm: File Permissions. r = read, w = write, x = execute. r (read) = 4 w (write) = 2 x (execute) = 1. chmod 521 somefile. owner, group, everyone

## k8s-pv.mount.debug.mode.readonly

- https://github.com/kubernetes-sigs/azurefile-csi-driver/issues/2141: AKS Azure Fileshare CSI PV/PVC Suddenly producing "Read-Only" errors. the data path does not go through csi driver(, it's the issue between cifs driver and azure file server, pls file a support ticket to azure file team)
- tbd https://www.addictivetips.com/ubuntu-linux-tips/mount-file-systems-as-read-only-on-linux/
