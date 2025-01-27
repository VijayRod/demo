```
# aka LUN

iostat -x 1 # sudo apt install sysstat. disk activity in 'Device - %util'
```

## device.bus

- https://tldp.org/HOWTO/SCSI-2.4-HOWTO/scsiaddr.html: SCSI Addressing. four level hierarchical addressing scheme for SCSI devices (Host:Bus:Target:LUN).
  - "Bus" is used in preference to "channel".
  - The SCSI adapter number is typically an arbitrary numbering of the adapter cards on the internal IO buses (e.g. PCI, PCMCIA, ISA etc) of the computer. Such adapters are sometimes termed as HBAs (host bus adapters). SCSI adapter numbers are issued by the kernel in ascending order starting with 0.
  - Each HBA may control one or more SCSI buses
  - Each SCSI bus can have multiple SCSI devices connected to it
  - SCSI devices (e.g. disks).
  - Each SCSI device can contain multiple Logical Unit Numbers (LUNs). These are typically used by sophisticated tape and cdrom units that support multiple media.

## device.bus.type

- https://tldp.org/HOWTO/SCSI-2.4-HOWTO/scsibus.html: Appendix A. Common bus types (SCSI and other)

## device.bus.type.SCSI

- https://tldp.org/HOWTO/SCSI-2.4-HOWTO/index.html
- https://tldp.org/HOWTO/SCSI-2.4-HOWTO/scsibus.html: Appendix A. Common bus types (SCSI and other)
  - SCSI. The original SCSI 1 standard (ANSI specification X3.131-1986) introduced an 8 bit parallel bus that was able to do asynchronous transfers at 1.5 MegaBytes/sec and synchronous transfers up to 5 MB/sec. SCSI commands are sent at the asynchronous rate. SCSI data is transferred either at the asynchronous rate (worst case) or a negotiated synchronous rate (with 5 MB/sec being the best case).
- https://tldp.org/HOWTO/SCSI-2.4-HOWTO/scsiaddr.html: SCSI Addressing. four level hierarchical addressing scheme for SCSI devices (Host:Bus:Target:LUN).
  - "Bus" is used in preference to "channel".
  - The SCSI adapter number is typically an arbitrary numbering of the adapter cards on the internal IO buses (e.g. PCI, PCMCIA, ISA etc) of the computer. Such adapters are sometimes termed as HBAs (host bus adapters). SCSI adapter numbers are issued by the kernel in ascending order starting with 0.
  - Each HBA may control one or more SCSI buses
  - Each SCSI bus can have multiple SCSI devices connected to it
  - SCSI devices (e.g. disks).
  - Each SCSI device can contain multiple Logical Unit Numbers (LUNs). These are typically used by sophisticated tape and cdrom units that support multiple media.
  
## storage.SCSI.device (/dev)

```
# See the section on SCSI

# SCSI subsystem: smart-bus(vmbus).devices(/dev)(max 15).type.lun.character/block
#   block-device.type.harddisk/USB/nvme.lun.filesystem
#     harddisk(/dev/sd[a-z])(major-number 8).partition(/dev/sda1)(max 15)
#     nvme(major-number 259)
#    filesystem.ext4/fat/ntfs

root@aks-nodepool1-20283200-vmss000000:/# ls /dev
autofs           initctl       port        sg2              tty19  tty38  tty57   ttyS18  ttyS9      vcsu
block            input         ppp         shm              tty2   tty39  tty58   ttyS19  ttyprintk  vcsu1
bsg              kmsg          psaux       snapshot         tty20  tty4   tty59   ttyS2   udmabuf    vcsu2
btrfs-control    log           ptmx        snd              tty21  tty40  tty6    ttyS20  uhid       vcsu3
cdrom            loop-control  ptp0        sr0              tty22  tty41  tty60   ttyS21  uinput     vcsu4
char             loop0         ptp1        stderr           tty23  tty42  tty61   ttyS22  urandom    vcsu5
console          loop1         ptp_hyperv  stdin            tty24  tty43  tty62   ttyS23  userio     vcsu6
core             loop2         pts         stdout           tty25  tty44  tty63   ttyS24  vcs        vfio
cpu_dma_latency  loop3         random      termination-log  tty26  tty45  tty7    ttyS25  vcs1       vga_arbiter
cuse             loop4         rfkill      tty              tty27  tty46  tty8    ttyS26  vcs2       vhost-net
disk             loop5         root        tty0             tty28  tty47  tty9    ttyS27  vcs3       vhost-vsock
dma_heap         loop6         rtc         tty1             tty29  tty48  ttyS0   ttyS28  vcs4       vmbus
ecryptfs         loop7         rtc0        tty10            tty3   tty49  ttyS1   ttyS29  vcs5       zero
fb0              mapper        sda         tty11            tty30  tty5   ttyS10  ttyS3   vcs6       zfs
fd               mcelog        sda1        tty12            tty31  tty50  ttyS11  ttyS30  vcsa
full             mem           sda14       tty13            tty32  tty51  ttyS12  ttyS31  vcsa1
fuse             mqueue        sda15       tty14            tty33  tty52  ttyS13  ttyS4   vcsa2
hpet             net           sdb         tty15            tty34  tty53  ttyS14  ttyS5   vcsa3
hugepages        null          sdb1        tty16            tty35  tty54  ttyS15  ttyS6   vcsa4
hwrng            nvme-fabrics  sg0         tty17            tty36  tty55  ttyS16  ttyS7   vcsa5
infiniband       nvram         sg1         tty18            tty37  tty56  ttyS17  ttyS8   vcsa6
root@aks-nodepool1-20283200-vmss000000:/# ls /dev/block
11:0  7:0  7:1  7:2  7:3  7:4  7:5  7:6  7:7  8:0  8:1  8:14  8:15  8:16  8:17
```

- https://lwn.net/Kernel/Index/#Block_layer
- https://lwn.net/Kernel/Index/#Device_drivers-Block_drivers
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
- https://www.codecademy.com/courses/fundamentals-of-operating-systems/articles/introduction-to-io-systems (click on the Syllabus link for more pages) 
- https://www.codecademy.com/learn/fundamentals-of-operating-systems/modules/os-io-systems/cheatsheet

## storage.SCSI.lun

```
# See the section on virtualization-hyperv-hostnode_disk

# lun
root@aks-nodepool1-24666711-vmss000000:/# cat /proc/scsi/scsi
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
  Vendor: Msft     Model: Virtual Disk     Rev: 1.0
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi0 Channel: 00 Id: 00 Lun: 01
  Vendor: Msft     Model: Virtual Disk     Rev: 1.0
  Type:   Direct-Access                    ANSI  SCSI revision: 05
Host: scsi0 Channel: 00 Id: 00 Lun: 02
  Vendor: Msft     Model: Virtual DVD-ROM  Rev: 1.0
  Type:   CD-ROM                           ANSI  SCSI revision: 00
  
root@aks-nodepool1-24666711-vmss000000:/# iscsiadm
Try `iscsiadm --help' for more information.

# lun
aks-nodepool1-24666711-vmss000000:/# ls /dev/disk/by-path/
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-0
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-0-part1
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-0-part14
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-0-part15
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-1
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-1-part1
acpi-VMBUS:00-vmbus-f8b3781a1e824818a1c363d806ec15bb-lun-2

# h:b:t:l = 0:0:0:0 i.e. (H:C:T:L – (Host:Bus:Target:LUN))
root@aks-nodepool1-24666711-vmss000000:# dmesg | grep -i "attached "
# root@aks-nodepool1-24666711-vmss000000:# cat /var/log/dmesg.0 | grep -i "attached "
[    1.051162] kernel: sd 0:0:0:0: [sda] Attached SCSI disk
[    1.064345] kernel: sd 0:0:0:1: [sdb] Attached SCSI disk

# (H:C:T:L – (Host:Bus:Target:LUN))
root@aks-nodepool1-24666711-vmss000001:/# multipath -v4 -ll
445.833356 | loading //lib/multipath/libchecktur.so checker
445.833456 | checker tur: message table size = 3
445.833468 | loading //lib/multipath/libprioconst.so prioritizer
445.833549 | _init_foreign: found libforeign-nvme.so
445.833560 | _init_foreign: foreign library "nvme" is not enabled
445.835454 | Discover device /sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0004:00/VMBUS:00/f8b3781a-1e82-4818-a1c3-63d806ec15bb/host0/target0:0:0/0:0:0:0/block/sda
445.835533 | 8:0: dev_t not found in pathvec
445.835569 | sda: mask = 0x27
445.835576 | sda: dev_t = 8:0
445.835584 | open '/sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0004:00/VMBUS:00/f8b3781a-1e82-4818-a1c3-63d806ec15bb/host0/target0:0:0/0:0:0:0/block/sda/size'
445.835601 | sda: size = 268435456
445.835726 | sda: vendor = Msft
445.835745 | sda: product = Virtual Disk
445.835763 | sda: rev = 1.0
445.836282 | find_hwe: found 0 hwtable matches for Msft:Virtual Disk:1.0
445.836291 | sda: h:b:t:l = 0:0:0:0

# tbd disk n = lun n
# scsi@0:0.0.0 i.e. (H:C:T:L – (Host:Bus:Target:LUN))
root@aks-nodepool1-24666711-vmss000001:/# lshw -class disk
  *-disk:0
       description: SCSI Disk
       product: Virtual Disk
       vendor: Msft
       physical id: 0.0.0
       bus info: scsi@0:0.0.0
       logical name: /dev/sda
       version: 1.0
       size: 128GiB (137GB)
       capabilities: gpt-1.00 partitioned partitioned:gpt
       configuration: ansiversion=5 guid=2f6f9f9a-b0e6-4fa5-91e4-296c9a37d69b logicalsectorsize=512 sectorsize=4096
  *-disk:1
       description: SCSI Disk
       product: Virtual Disk
       vendor: Msft
       physical id: 0.0.1
       bus info: scsi@0:0.0.1
       logical name: /dev/sdb
       version: 1.0
       size: 16GiB (17GB)
       capabilities: partitioned partitioned:dos
       configuration: ansiversion=5 logicalsectorsize=512 sectorsize=4096 signature=7cda5bd8
  *-cdrom
       description: SCSI CD-ROM
       product: Virtual DVD-ROM
       vendor: Msft
       physical id: 0.0.2
       bus info: scsi@0:0.0.2
       logical name: /dev/cdrom
       logical name: /dev/sr0
       version: 1.0
       capabilities: removable audio
       configuration: status=ready
     *-medium
          physical id: 0
          logical name: /dev/cdrom
          
# The first column. (H:C:T:L – (Host:Bus:Target:LUN))
root@aks-nodepool1-24666711-vmss000001:/# lsscsi # lsscsi --scsi # lsscsi --scsi --size
[0:0:0:0]    disk    Msft     Virtual Disk     1.0   /dev/sda   14d534654202020208476f53924e8c8448c6e657d30e54d55
[0:0:0:1]    disk    Msft     Virtual Disk     1.0   /dev/sdb   36002248094bfcf070909def97fd03eed
[0:0:0:2]    cd/dvd  Msft     Virtual DVD-ROM  1.0   /dev/sr0   14d534654202020207305e3437703544694957d7ced624a7d
...

apt install smartmontools
smartctl -a /dev/sdb
```

- https://linuxopsys.com/check-luns-in-linux
- https://unix.stackexchange.com/questions/4561/how-do-i-find-out-what-hard-disks-are-in-the-system: lshw -class disk
- https://www.fosstechi.com/find-san-disk-lun-number-linux/: lsscsi. The first column. (H:C:T:L – (Host:Bus:Target:LUN)). smartctl
- https://tldp.org/HOWTO/SCSI-2.4-HOWTO/scsiaddr.html: SCSI Addressing. "Lun" is the common SCSI abbreviation of Logical Unit Number. The terms in brackets are the name conventions used by device pseudo file system (devfs). "Bus" is used in preference to "channel" in the description below. arbitrary numbering of the adapter cards on the internal IO buses (e.g. PCI, PCMCIA, ISA etc) of the computer.
- https://en.wikipedia.org/wiki/Logical_unit_number: logical unit number, or LUN. device addressed by the SCSI protocol or by Storage Area Network protocols that encapsulate SCSI, such as Fibre Channel or iSCSI
- https://superuser.com/questions/901817/what-is-the-maximum-scsi-lun-size
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-to-guest-disk-mapping

```
# lun.windows
$GetDisks = Get-AzureRMVM | where {$_.name -eq "VM name"}
$GetDisks.StorageProfile.DataDisks
```
- https://learn.microsoft.com/en-us/azure/virtual-machines/windows/azure-to-guest-disk-mapping?tabs=azure-cli

```
# lun.error.k8s.FailedMount.findDiskByLun(0) failed with error

# This might be because of a disk attach failure, like if the VM and disk are in different zones.
kubectl describe pod mypod-test-2
# kubectl logs -n kube-system csi-azuredisk-node-xxxxx
  Warning  FailedMount             <invalid> (x3 over <invalid>)  kubelet                  MountVolume.MountDevice failed for volume "pvc-12345678-abce-4ab1-1234-123456789123" : rpc error: code = Internal desc = failed to find disk on lun 0. azureDisk - findDiskByLun(0) failed with error(failed to find disk by lun 0)

# Otherwise, it means the disk was attached to the node successfully but wasn't found in the LUN on the node. It's a VM issue, and usually, rescheduling the pod to another node fixes it.
kubectl describe pod mypod-test-2
# kubectl logs -n kube-system csi-azuredisk-node-xxxxx
  Warning  FailedMount             <invalid> (x3 over <invalid>)  kubelet                  MountVolume.MountDevice failed for volume "pvc-12345678-abce-4ab1-1234-123456789123" : rpc error: code = Internal desc = failed to find disk on lun 0. azureDisk - findDiskByLun(7) failed with error(failed to find disk by lun 7)
```

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/pkg/azuredisk/azure_common_linux.go: device, err := findDiskByLunWithConstraint(lun, io, azureDisks)
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/pkg/azuredisk/nodeserver.go: azureDisk - findDiskByLun(%v) failed with
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/issues/2777: nvme. kubectl apply -f https://raw.githubusercontent.com/andyzhangx/demo/refs/heads/master/aks/download-v6-disk-rules.yaml
- https://stackoverflow.com/questions/79356118/azure-aks-wont-mount-disk: Check if disk attached to correct node or not. do lsblk and see. Disk should appear in the list. Do a dmesg | grep SCSI.
