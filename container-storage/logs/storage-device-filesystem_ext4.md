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

- https://lwn.net/Kernel/Index/#Filesystems-ext4
- https://opensource.com/article/18/4/ext4-filesystem: brings large filesystem support, improved resistance to fragmentation, higher performance, and improved timestamps. Ext4 vs ext3
- https://docs.kernel.org/filesystems/ext4/overview.html
- https://www.baeldung.com/linux/usb-drive-format#1-ext4: ext4 (Extended File System) using the mkfs.ext4 utility
- https://en.m.wikipedia.org/wiki/Ext4: ext4 (fourth extended filesystem)
- https://opensource.com/article/17/5/introduction-ext4-filesystem: dumpe2fs /dev/sda1. fsck -fn.

## storage.SCSI.device.type.disk.filesystem.type.ext4.Inode 

- https://opensource.com/article/17/5/introduction-ext4-filesystem: The inode contains the metadata about the file, including its type and permissions as well as its size...
