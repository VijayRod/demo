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

## k8s-pv.mount.debug.SCSI

- https://docs.kernel.org/driver-api/scsi.html: Small Computer Systems Interface. SCSI commands can be transported over just about any kind of bus, and are the default protocol for storage devices attached to USB, SATA, SAS, Fibre Channel, FireWire, and ATAPI devices. SCSI packets are also commonly exchanged over Infiniband, TCP/IP (iSCSI), even Parallel ports.
- https://www.kernel.org/doc/html/v4.13/driver-api/scsi.html

## k8s-pv.mount.debug.SCSI.device

```
# SCSI subsystem: smart-bus.devices(/dev)(max 15).type.character/block
#   block-device.type.harddisk/USB/nvme.filesystem
#     harddisk(/dev/sd[a-z])(major-number 8).partition(/dev/sda1)(max 15)
#     nvme(major-number 259)
#    filesystem.ext4/fat/ntfs
```

- https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/devices.txt
  - (major number 8) 8 block. SCSI disk devices (0-15).
  - (major number 259) 259 block. Block Extended Major
- https://git.kernel.org/pub/scm/utils/util-linux/util-linux.git/tree/disk-utils/fdisk.8.adoc: _/dev/sd*_ (SCSI)
- https://unix.stackexchange.com/questions/392701/drive-name-what-is-the-correct-term-for-the-sda-part-of-dev-sda: /dev/sd* (SCSI).
  - /dev/sda1 is the first partition on the first hard disk in the system
- https://www.baeldung.com/linux/dev-sda
  - When we list the content of /dev (i.e., with the ls command), we realize that most of the files listed are either block or character devices. However, apart from these two, other types of device files also exist in the /dev directory.
  - disk devices have a major number of 8, which assigns them as SCSI block devices
  - sd[a-z] is the most used way to refer to hard disks.
  - SCSI is a microprocessor-controlled smart bus. It allows us to add up to 15 peripheral devices to the computer. These devices include hard drives, scanners, USB, printers, and many other devices. It stands for small computer system interface. 
  - /dev/sda, which is a block device in the /dev directory. 
  - If we have multiple partitions in the hard disk, the system consecutively appended a number starting from sda1 to sda15. In a single hard disk, we can only have a maximum of 15 partitions.
- https://www.baeldung.com/linux/dev-directory
  - a driver accesses data from block devices through a cache. Moreover, a driver communicates with a block device by sending an entire block of data.
  - For example, character devices are sound cards or serial ports, whereas block devices are hard disks or USBs
    
## k8s-pv.mount.debug.SCSI.device.type.disk

```
root@aks-nodepool1-57299033-vmss000000:/# ls -l /dev | grep sda
brw-rw---- 1 root disk      8,   0 Nov  7 10:28 sda
brw-rw---- 1 root disk      8,   1 Nov  7 10:28 sda1
brw-rw---- 1 root disk      8,  14 Nov  7 10:28 sda14
brw-rw---- 1 root disk      8,  15 Nov  7 10:28 sda15
# b=block (device), disk (major-number 8)

root@aks-nodepool1-57299033-vmss000000:/# lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda       8:0    0   128G  0 disk
|-sda1    8:1    0 127.9G  0 part /var/lib/kubelet
|                                 /
|-sda14   8:14   0     4M  0 part
`-sda15   8:15   0   106M  0 part /boot/efi
sdb       8:16   0    80G  0 disk
`-sdb1    8:17   0    80G  0 part /mnt
sr0      11:0    1   774K  0 rom
nvme0n1 259:0    0   1.7T  0 disk
# major-number 8 (disk)

root@aks-nodepool1-57299033-vmss000000:/# lsblk --output NAME,FSTYPE,LABEL,UUID,MODE
NAME    FSTYPE LABEL           UUID                                 MODE
sda                                                                 brw-rw----
|-sda1  ext4   cloudimg-rootfs 0b58668a-ba2e-4a00-b89a-3354b7a547d4 brw-rw----
|-sda14                                                             brw-rw----
`-sda15 vfat   UEFI            C83D-C1E5                            brw-rw----
sdb                                                                 brw-rw----
`-sdb1  ext4                   6e123474-a306-4386-8c1a-911ab8754171 brw-rw----
sr0                                                                 brw-rw----
nvme0n1                                                             brw-rw----
# b=block

root@aks-nodepool1-57299033-vmss000000:/# lsblk -i # ascii
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda       8:0    0   128G  0 disk
|-sda1    8:1    0 127.9G  0 part /var/lib/kubelet
|                                 /
|-sda14   8:14   0     4M  0 part
`-sda15   8:15   0   106M  0 part /boot/efi
sdb       8:16   0    80G  0 disk
`-sdb1    8:17   0    80G  0 part /mnt
sr0      11:0    1   774K  0 rom
nvme0n1 259:0    0   1.7T  0 disk

root@aks-nodepool1-57299033-vmss000000:/# lsblk -p # path
NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
/dev/sda       8:0    0   128G  0 disk
|-/dev/sda1    8:1    0 127.9G  0 part /var/lib/kubelet
|                                      /
|-/dev/sda14   8:14   0     4M  0 part
`-/dev/sda15   8:15   0   106M  0 part /boot/efi
/dev/sdb       8:16   0    80G  0 disk
`-/dev/sdb1    8:17   0    80G  0 part /mnt
/dev/sr0      11:0    1   774K  0 rom
/dev/nvme0n1 259:0    0   1.7T  0 disk

root@aks-nodepool1-57299033-vmss000000:/# df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       124G   24G  101G  20% /
tmpfs            32G     0   32G   0% /dev/shm
tmpfs            13G  4.8M   13G   1% /run
tmpfs           5.0M     0  5.0M   0% /run/lock
/dev/sda15      105M  6.1M   99M   6% /boot/efi
/dev/sdb1        79G   28K   75G   1% /mnt
tmpfs           250M  4.0K  250M   1% /var/lib/kubelet/pods/b9430ccf-8644-4fcc-92ea-4949bb0a2178/volumes/kubernetes.io~projected/azure-ip-masq-agent-config-volume
tmpfs            61G   12K   61G   1% /var/lib/kubelet/pods/75e8808a-bb68-4776-80d5-ab41d773e88a/volumes/kubernetes.io~projected/kube-api-access-tbmgt
...
```

- https://linuxconfig.org/introduction-to-the-lsblk-command

## k8s-pv.mount.debug.SCSI.device.type.disk.filesystem

```
root@aks-nodepool1-57299033-vmss000000:/# lsblk --output NAME,FSTYPE
NAME    FSTYPE
sda
|-sda1  ext4
|-sda14
`-sda15 vfat
sdb
`-sdb1  ext4
sr0
nvme0n1
```

- https://docs.kernel.org/filesystems/index.html

```
mkfs.ext4
```

## k8s-pv.mount.debug.SCSI.device.type.disk.filesystem.type.ext4

```
mkfs.fat
mkfs.vfat
```

- https://opensource.com/article/18/4/ext4-filesystem: brings large filesystem support, improved resistance to fragmentation, higher performance, and improved timestamps. Ext4 vs ext3
- https://docs.kernel.org/filesystems/ext4/overview.html
- https://www.baeldung.com/linux/usb-drive-format#1-ext4: ext4 (Extended File System) using the mkfs.ext4 utility
- https://en.m.wikipedia.org/wiki/Ext4: ext4 (fourth extended filesystem)

## k8s-pv.mount.debug.SCSI.device.type.disk.filesystem.type.fat
- https://www.baeldung.com/linux/usb-drive-format#3-fat-fat16-vfat-and-fat32: FAT16 is an upgrade over the original FAT that provides larger partitions and file sizes. In addition, VFAT is an extension to the original FAT that allows for longer filenames. On the other hand, FAT32 overcomes the limitations of both FAT and FAT16. It supports larger partition sizes, file sizes, and long filenames.

## k8s-pv.mount.debug.SCSI.device.type.disk.filesystem.type.ntfs

- https://www.baeldung.com/linux/usb-drive-format#2-ntfs: NTFS (New Technology File System)

## k8s-pv.mount.debug.SCSI.device.type.NVMe

```
# Ensure you select a VM size with NVMe, like the standard_l8s_v3

root@aks-nodepool1-57299033-vmss000000:/# lsmod|grep nvme # list the kernel modules
nvme_fabrics           24576  0

root@aks-nodepool1-57299033-vmss000000:/# lsblk
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
...
nvme0n1 259:0    0   1.7T  0 disk

root@aks-nodepool1-57299033-vmss000000:/# ls /sys/block/|grep nvme
nvme0n1

root@aks-nodepool1-57299033-vmss000000:/# cat /proc/partitions |grep -e nvme -e major
major minor  #blocks  name
 259        0 1875374424 nvme0n1
```

- https://askubuntu.com/questions/1367342/major-number-259-on-ubuntu-20-04-3-lts: 259 means the device type is 'Block Extended Major'. NVMe device
- https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-overview
  
## k8s-pv.mount.debug.SCSI.device.type.NVMe.nvme-cli

```
# https://github.com/Azure/AKS/blob/master/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202409.30.0.txt: nvme-cli/jammy-updates,now 1.16-3ubuntu0.3 amd64 [installed]
# else apt install nvme-cli

root@aks-nodepool1-57299033-vmss000000:/# nvme list
Node                  SN                   Model                                    Namespace Usage
     Format           FW Rev
--------------------- -------------------- ---------------------------------------- --------- -------------------------- ---------------- --------
/dev/nvme0n1          c513e8dd1a6100000001 Microsoft NVMe Direct Disk               1           0.00   B /   1.92  TB    512   B +  0 B   NVMDV001
root@aks-nodepool1-57299033-vmss000000:/# nvme list-subsys
nvme-subsys0 - NQN=nqn.2024-04.com.skhynix:nvme:nvm-subsystem-sn-1824ASD4N5214I270V0D
\
 +- nvme0 pcie 0bb0:00:00.0 live

root@aks-nodepool1-57299033-vmss000000:/# nvme version
nvme version 1.16
```

- https://www.linuxjournal.com/content/data-flash-part-ii-using-nvme-drives-and-creating-nvme-over-fabrics-network: (NVMe) drive management utility called nvme-cli. This utility is defined and maintained by the very same NVM Express committee that defined the NVMe specification. The nvme-cli source code is hosted on GitHub
- https://github.com/linux-nvme/nvme-cli
  
## k8s-pv.mount.debug.file.mode

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

```
Log: output from the mount command on the node, along with the syslog and messages files with events during the issue time.
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/issues/2141: AKS Azure Fileshare CSI PV/PVC Suddenly producing "Read-Only" errors. the data path does not go through csi driver(, it's the issue between cifs driver and azure file server, pls file a support ticket to azure file team)
- tbd https://www.addictivetips.com/ubuntu-linux-tips/mount-file-systems-as-read-only-on-linux/
