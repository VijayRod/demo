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

root@aks-nodepool1-12740373-vmss000000:/# du -h /tmp
4.0K    /tmp/systemd-private-59080e8b19d74b80bececea5545fe645-systemd-logind.service-vMXevi/tmp
...
4.0K    /tmp/.font-unix
4.0K    /tmp/.Test-unix
48K     /tmp
```

- https://linuxconfig.org/introduction-to-the-lsblk-command
- https://www.redhat.com/en/blog/du-command-options

## storage.SCSI.device.type.disk.os

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks: The OS disk is labeled /dev/sda by default.

## storage.SCSI.device.type.disk.ephemeraldisk-os

Here are the commands to create a cluster with an ephemeral OS disk.

```
# aks
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks --node-osdisk-type Ephemeral -s $vmsize -c 2
az aks get-credentials -g $rg -n $aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n np2 --node-osdisk-type Ephemeral # --node-osdisk-size 128

kubectl describe no
Capacity:
  ephemeral-storage:  129886128Ki
Allocatable:
  ephemeral-storage:  119703055367
Allocated resources:
  Resource           Requests     Limits
  --------           --------     ------
  ephemeral-storage  0 (0%)       0 (0%)
```

- [aks/cluster-configuration#ephemeral-os](https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#ephemeral-os)
- [azure-samples/aks-ephemeral-os-disk](https://learn.microsoft.com/en-us/samples/azure-samples/aks-ephemeral-os-disk/aks-ephemeral-os-disk/), also at [Azure-Samples/aks-ephemeral-os-disk](https://github.com/Azure-Samples/aks-ephemeral-os-disk)
  - [fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure/ba-p/3565605)
    
```
# vm
az vm create -g $rg -n vm --image Ubuntu2204 --ephemeral-os-disk # --admin-username azureuser --public-ip-sku Standard --ephemeral-placement CacheDisk or ResourceDisk

TBD (No ephemeral property in the below)
az vm show -g $rg -n vm --query storageProfile.osDisk.managedDisk.id -otsv
az disk show -id 
az vm get-instance-view -g $rg -n vm
```

- [virtual-machines/ephemeral-os-disks](https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks).

## storage.SCSI.device.type.disk.ephemeraldisk-os.iops

Here are the commands to benchmark the available IOPS.

```
# To benchmark the OS disk:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/tmp/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60

# To benchmark the temporary storage disk:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60

# To benchmark the attached volume:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/volume/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60
```

```
# Create the storage class and the pod.
cat << EOF | kubectl create -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: managed-premium-nocache
provisioner: kubernetes.io/azure-disk
reclaimPolicy: Delete
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
  cachingmode: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurediskpvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-premium-nocache
  resources:
    requests:
      storage: 250Gi # P15
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  #nodeSelector:
    #kubernetes.azure.com/agentpool: nodepool1
    #kubernetes.io/hostname: aks-nodepool1-85027187-vmss000002
  volumes:
    - name: azurediskpv
      persistentVolumeClaim:
        claimName: azurediskpvc
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: azurediskpv
EOF
```

## storage.SCSI.device.type.disk.temp

```
# See the section on host node cache
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks: Temporary disks are labeled /dev/sdb and have a mountpoint of /mnt.
- https://learn.microsoft.com/en-us/azure/virtual-machines/azure-vms-no-temp-disk
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv6-series?tabs=sizestoragelocal: Premium Storage caching: Supported. Ephemeral OS Disk: Not Supported.
  - 'Local Storage' - 'Local (temp) storage info for each size', 'No local storage present in this series'. 'For frequently asked questions, see Azure VM sizes with no local temp disk'.
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/ddsv6-series?tabs=sizestoragelocal: Premium Storage caching: Supported. Ephemeral OS Disk: Not Supported. 
  - 'Local Storage' - 'Local (temp) storage info for each size', IOPS / MB/s
- https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-storage?view=azuresql#cached-and-temp-storage-throughput: locally attached SSD. The temp drive (D:\ drive) within the VM is also hosted on this local SSD.
- https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-storage?view=azuresql#cached-and-temp-storage-throughput: The Azure BlobCache consists of a combination of the VM host's random-access memory and locally attached SSD. The temp drive (D:\ drive) within the VM is also hosted on this local SSD.
  - The max cached and temp storage throughput limit governs the I/O against the local temp drive (D:\ drive) and the Azure BlobCache only if host caching is enabled.

