## storage.SCSI.device.type.disk.filesystem

```
# See the section on disk space

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

- https://lwn.net/Kernel/Index/#Filesystems
- https://tldp.org/LDP/tlk/fs/filesystem.html
- https://docs.kernel.org/filesystems/index.html
- https://www.kernel.org/doc/html/latest/filesystems/index.html
- https://wiki.archlinux.org/title/Category:File_systems
- https://www.baeldung.com/linux/filesystem-guide
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-file_and_print_servers
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/lessons/os-filesystems/exercises/introduction-to-filesystems (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-filesystems/cheatsheet

> ## storage.SCSI.device.type.disk.filesystem.error.ReadonlyFilesystem

```
# node: ReadonlyFilesystem
# aka FilesystemIsReadOnly
# Check out the node syslog
# If the issue persists and there is no syslog, or if you need to find the volume mapping (e.g., for sdc, which is the data disk), obtain the output of the mount command on the node.

kubectl describe no 
Conditions:
  Type                          Status  LastHeartbeatTime                 LastTransitionTime                Reason                          Message
  ----                          ------  -----------------                 ------------------                ------                          -------
  ReadonlyFilesystem            False   Thu, 23 Nov 2023 19:02:02 +0000   Thu, 23 Nov 2023 18:11:19 +0000   FilesystemIsNotReadOnly         Filesystem is not read-only

# https://bbs.archlinux.org/viewtopic.php?id=175948
[  283.365317] JBD2: Error -5 detected when updating journal superblock for sdb1-8. # error when updating journal
[  313.114350] end_request: I/O error, dev sdb, sector 352389680 # I/O error
[  313.123970] EXT4-fs (sdb1): Remounting filesystem read-only # sdb1
```

```
# pod: volume is readonly from within the pod even though the node shows the mount as read-write
# logs: syslog from node and pod, "cat /proc/mounts" from node and pod, storage class driver pod logs from the node

# sample output showing rw:
# pod: cat /proc/mounts | grep nfs
f71c2467512884c5aad0080.file.core.windows.net:/f71c2467512884c5aad0080/pvcn-231aebc3-a72a-41de-8529-59f21153e83a /volume nfs4 rw,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,acregmin=30,acregmax=30,acdirmax=30,hard,noresvport,proto=tcp,nconnect=4,timeo=600,retrans=2,sec=sys,clientaddr=10.224.0.4,local_lock=none,addr=20.60.79.8 0 0
# node: cat /proc/mounts | grep nfs
cat /proc/mounts | grep nfs | grep pvcn-231aebc3-a72a-41de-8529-59f21153e83a
f71c2467512884c5aad0080.file.core.windows.net:/f71c2467512884c5aad0080/pvcn-231aebc3-a72a-41de-8529-59f21153e83a /var/lib/kubelet/plugins/kubernetes.io/csi/file.csi.azure.com/e15a0e289ca1ad200c5fb5956e31a0b4feead98001c8de4d40c3467427fac035/globalmount nfs4 rw,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,acregmin=30,acregmax=30,acdirmax=30,hard,noresvport,proto=tcp,nconnect=4,timeo=600,retrans=2,sec=sys,clientaddr=10.224.0.4,local_lock=none,addr=20.60.79.8 0 0
f71c2467512884c5aad0080.file.core.windows.net:/f71c2467512884c5aad0080/pvcn-231aebc3-a72a-41de-8529-59f21153e83a /var/lib/kubelet/pods/b074c326-38ed-47c9-90f6-173856c466e9/volumes/kubernetes.io~csi/pvc-231aebc3-a72a-41de-8529-59f21153e83a/mount nfs4 rw,relatime,vers=4.1,rsize=1048576,wsize=1048576,namlen=255,acregmin=30,acregmax=30,acdirmax=30,hard,noresvport,proto=tcp,nconnect=4,timeo=600,retrans=2,sec=sys,clientaddr=10.224.0.4,local_lock=none,addr=20.60.79.8 0 0
```

## storage.SCSI.device.type.disk.filesystem.type.fat

```
mkfs.fat
mkfs.vfat
```

- https://www.baeldung.com/linux/usb-drive-format#3-fat-fat16-vfat-and-fat32: FAT16 is an upgrade over the original FAT that provides larger partitions and file sizes. In addition, VFAT is an extension to the original FAT that allows for longer filenames. On the other hand, FAT32 overcomes the limitations of both FAT and FAT16. It supports larger partition sizes, file sizes, and long filenames.

## storage.SCSI.device.type.disk.filesystem.type.ntfs

- https://www.baeldung.com/linux/usb-drive-format#2-ntfs: NTFS (New Technology File System)

## storage.SCSI.device.type.disk.filesystem.type.k8s.containerd.snapshotter

- https://docs.docker.com/engine/storage/containerd/: containerd, the industry-standard container runtime, uses snapshotters instead of the classic storage drivers for storing image and container data. While the overlay2 driver still remains the default driver for Docker Engine, you can opt in to using containerd snapshotters as an experimental feature.
- https://docs.docker.com/desktop/features/containerd/: containerd snapshotters with unique characteristics, such as stargz for lazy-pulling images on container startup, or nydus and dragonfly for peer-to-peer image distribution.
- - https://docs.docker.com/storage/containerd/: containerd, the industry-standard container runtime, uses snapshotters instead of the classic storage drivers for storing image and container data.
- https://github.com/containerd/stargz-snapshotter
- https://github.com/microsoft/Windows-Containers/issues/358: C:\\ProgramData\\containerd\\root\\io.containerd.snapshotter.v1.windows\\snapshots\\
- https://medium.com/nttlabs/startup-containers-in-lightning-speed-with-lazy-image-distribution-on-containerd-243d94522361

