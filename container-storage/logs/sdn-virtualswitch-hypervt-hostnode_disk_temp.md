## temp

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
