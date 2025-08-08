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
- https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs#how-do-azure-boost-and-nvme-improve-the-performance-of-the-vms-that-azure-offers-
- https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-interface
- https://learn.microsoft.com/en-us/azure/virtual-machines/lsv2-series
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes-storage
- https://techcommunity.microsoft.com/t5/azure-compute-blog/announcing-the-new-ebsv5-vm-sizes-offering-2x-remote-storage/ba-p/3652000

```
# NVMe vs SCSI (disk controllers)
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-overview#scsi-to-nvme: scsi
- https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-linux#scsi-vs-nvme: Azure VMs support two types of storage interfaces: Small Computer System Interface (SCSI) and NVMe. The SCSI interface is a legacy standard that provides physical connectivity and data transfer between computers and peripheral devices. NVMe is similar to SCSI in that it provides connectivity and data transfer, but NVMe is a faster and more efficient interface for data transfer between servers and storage systems.

```
# nvme.disks
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-linux#what-is-changing-for-your-vm
  - OS disk - SCSI /dev/sda, NVMe /dev/nvme0n1
  - Temp Disk - SCSI /dev/sdb, NVMe /dev/sda
  - First Data Disk - SCSI /dev/sdc, NVMe /dev/nvme0n2
- https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-remote-faqs#how-can-i-identify-remote-nvme-disks-on-a-linux-vm-
  
```
# nvme.disks.temp
```
- ** https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-temp-faqs: the new v6 VMs come with raw, unformatted NVMe disks. Customers should initialize and format the disks into a file system of their preference after the VM starts up.

## NVMe.app.k8s.csi

```
# NVMe.app.k8s.csi
# vm.sku.nvme.aks with an NVMe VM SKU and without --enable-azure-container-storage

tbd not nvme (/dev/sdc on /var/lib/kubelet/pods/f3cd2977-ae84-44fd-870a-dfee41e65197/volumes/kubernetes.io~csi/pvc-c8382116-4b1a-41bb-8121-790d14091135/mount type ext4 (rw,relatime))

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnvme -s Standard_E8bds_v5 -c 2
az aks get-credentials -g $rg -n aksnvme --overwrite-existing
kubectl get no; kubectl get po -A

kubectl delete po nginx-azuredisk
kubectl delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: default
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
        - name: azuredisk01
          mountPath: /mnt/azuredisk
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
kubectl get po -owide -w
kubectl get po,pv,pvc
```

```
# NVMe.app.k8s.csi.acstor
```
 
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk: Use Azure Container Storage with local NVMe. two types of Ephemeral Disk available: local NVMe and temp SSD.
- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-nvme-replication

## NVMe.app.vm

```
# vm.sku.nvme
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/expand-disks?tabs=ubuntu: NVMe controllers for Ultra Disks or Premium SSD v2 disks
- https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-overview#vm-sizes: The newer generations (Ebsv5, Da/Ea/Fav6 and newer) typically support only the NVMe storage interface (or some offering supports SCSI and NVMe
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dasv6-series?tabs=sizebasic#sizes-in-series: This VM series will only work on OS images that support NVMe. If your current OS image doesn't have NVMe support, you’ll see an error message. NVMe support is available on the most popular OS images
- https://learn.microsoft.com/en-us/azure/virtual-machines/ebdsv5-ebsv5-series: NVMe interface for higher remote disk storage IOPS and throughput performance
  - NVMe Interface: Supported only on Generation 2 VMs
  - The E112i size is offered as NVMe only to provide the highest IOPS and throughput performance. See the NVMe VM spec table to see the improved performance details.

## NVMe.cli

```
# cli

nvme list
ls -l /dev/disk/azure/data/by-lun/
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-linux#41-check-devices

```
# cli.nvme-cli
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
