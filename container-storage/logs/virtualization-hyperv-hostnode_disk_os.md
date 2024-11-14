## storage.SCSI.device.type.disk

```
# See the section on storage device

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
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks: The OS disk is labeled /dev/sda by default.
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks: Temporary disks are labeled /dev/sdb and have a mountpoint of /mnt.
- https://learn.microsoft.com/en-us/azure/virtual-machines/azure-vms-no-temp-disk
