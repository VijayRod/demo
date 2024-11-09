## storage.SCSI.device.type.disk.filesystem

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
- https://wiki.archlinux.org/title/Category:File_systems
- https://www.baeldung.com/linux/filesystem-guide
- https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-file_and_print_servers
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/lessons/os-filesystems/exercises/introduction-to-filesystems (click on the Syllabus link for more pages)
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-filesystems/cheatsheet

## storage.SCSI.device.type.disk.filesystem.error.space

```
df / -h # Disk free space
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       124G   21G  104G  17% /

sudo du -shx --exclude='/proc' --exclude='/sys' /* | sort -hr # Disk usage breakdown for directories
17G     /var
2.5G    /usr
...
```

```
kubectl logs # Delete the pod to remove its associated log

logrotate # Remove log files

crictl rmi -prune # Remove unused container images
Deleted: mcr.microsoft.com/azure-policy/policy-kubernetes-addon-prod:1.0.1
Deleted: mcr.microsoft.com/oss/kubernetes/azure-cloud-node-manager:v1.25.12
...
```

- https://stackoverflow.com/questions/257844/quickly-create-a-large-file-on-a-linux-system

## storage.SCSI.device.type.disk.filesystem.type.ext4

```
mkfs.ext4

# shows the metadata contained in the superblock, as well as data about each of the first two cylinder groups in the filesystem
# man dumpe2fs: dump ext2/ext3/ext4 file system information
dumpe2fs /dev/sda1

# Be sure to use the -n parameter, because it prevents fsck from taking any action on the scanned filesystem
# man fsck: check and repair a Linux filesystem
root@aks-nodepool1-57299033-vmss000000:/# fsck -fn
fsck from util-linux 2.37.2
e2fsck 1.46.5 (30-Dec-2021)
Warning!  /dev/sda1 is mounted.
Warning: skipping journal recovery because doing a read-only filesystem check.
Pass 1: Checking inodes, blocks, and sizes
...
```

- https://opensource.com/article/18/4/ext4-filesystem: brings large filesystem support, improved resistance to fragmentation, higher performance, and improved timestamps. Ext4 vs ext3
- https://docs.kernel.org/filesystems/ext4/overview.html
- https://www.baeldung.com/linux/usb-drive-format#1-ext4: ext4 (Extended File System) using the mkfs.ext4 utility
- https://en.m.wikipedia.org/wiki/Ext4: ext4 (fourth extended filesystem)
- https://opensource.com/article/17/5/introduction-ext4-filesystem: dumpe2fs /dev/sda1. fsck -fn.

## storage.SCSI.device.type.disk.filesystem.type.ext4.Inode 

- https://opensource.com/article/17/5/introduction-ext4-filesystem: The inode contains the metadata about the file, including its type and permissions as well as its size...

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

## storage.SCSI.device.type.disk.filesystem.type.k8s.overlayfs

```
root@aks-nodepool1-33178142-vmss000000:/# df -h
overlay         124G   24G  101G  20% /run/containerd/io.containerd.runtime.v2.task/k8s.io/2a1be93f6966eb4a720ccadb38c09d4d773302f6d153faf92b131803e41989e0/rootfs
overlay         124G   24G  101G  20% /run/containerd/io.containerd.runtime.v2.task/k8s.io/e502f81b1969bc797831e897c8b7e6f19d3d26383fef50eabfe4bc87c04bbb28/rootfs
```

- https://www.martinheinz.dev/blog/44: Deep Dive into Docker Internals - Union Filesystem
- https://jvns.ca/blog/2019/11/18/how-containers-work--overlayfs/
- https://blog.codefarm.me/2021/11/26/linux-overlayfs-and-container/
- https://docs.docker.com/engine/storage/containerd/: overlay2 driver (alternative is containerd snapshotters)
- https://github.com/containerd/fuse-overlayfs-snapshotter
