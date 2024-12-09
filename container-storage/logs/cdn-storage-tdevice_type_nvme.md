## NVMe

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
- https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs
- https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-interface
- https://learn.microsoft.com/en-us/azure/virtual-machines/lsv2-series
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-storage
- https://techcommunity.microsoft.com/t5/azure-compute-blog/announcing-the-new-ebsv5-vm-sizes-offering-2x-remote-storage/ba-p/3652000

## NVMe.nvme-cli

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
