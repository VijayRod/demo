## hyper.hostnode.cache.blobcache (Azure Blob Cache) (host caching)

```
az vm create -h
    --data-disk-caching                                 : Storage caching type for data disk(s),
                                                          including 'None', 'ReadOnly', 'ReadWrite',
                                                          etc. Use a singular value to apply on all
                                                          disks, or use `<lun>=<vaule1>
                                                          <lun>=<value2>` to configure individual
                                                          disk.
    --os-disk-caching                                   : Storage caching type for the VM OS disk.
                                                          Default: ReadWrite.  Allowed values: None,
                                                          ReadOnly, ReadWrite.
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/faq-for-disks: Host Caching (ReadOnly and Read/Write) is supported on disk sizes less than 4 TiB.
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-performance
- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-manage-disks: The disk caching configuration of the OS disk is optimized for OS performance. Because of this configuration, the OS disk should not be used for applications or data.
- TBD https://stackoverflow.com/questions/61137702/how-disk-caching-in-azure-vm-works
- https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-storage?view=azuresql#caching: VMs that support premium storage caching can take advantage of an additional feature called the Azure BlobCache or host caching to extend the IOPS and throughput capabilities of a VM. 
  - VMs enabled for both premium storage and premium storage caching have these two different storage bandwidth limits that can be used together to improve storage performance.
  - Reads and writes to the Azure BlobCache (cached IOPS and throughput) don't count against the uncached IOPS and throughput limits of the VM.
  - Disk Caching is not supported for disks 4 TiB and larger (P50 and larger).
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv6-series?tabs=sizestorageremote: Premium Storage caching: Supported. The 'Remote Storage' section mentions Uncached*
- https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-storage?view=azuresql#cached-and-temp-storage-throughput: The Azure BlobCache consists of a combination of the VM host's random-access memory and locally attached SSD. The temp drive (D:\ drive) within the VM is also hosted on this local SSD.
  - The max cached and temp storage throughput limit governs the I/O against the local temp drive (D:\ drive) and the Azure BlobCache only if host caching is enabled.
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-performance#virtual-machine-uncached-vs-cached-limits: You can also turn on and off host caching on your disks on an existing VM. By default, cache-capable data disks will have read-only caching enabled. Cache-capable OS disks will have read/write caching enabled.
  - If your workload doesn't follow either (only do read operations, balance of read and write operations) of these patterns, we don't recommend that you use host caching.
  - you can enable host caching on disks attached to a VM while not enabling host caching on other disks. This configuration allows your virtual machines to get a total storage IO of the cached limit plus the uncached limit.
- https://learn.microsoft.com/en-us/training/modules/caching-and-performance-azure-storage-and-disks/
- https://stackoverflow.com/questions/61137702/how-disk-caching-in-azure-vm-works: By default, this cache setting is set to Read/Write for OS disks and ReadOnly for data disks hosted on Premium Storage.
- https://learn.microsoft.com/en-us/answers/questions/1036313/issue-writing-to-an-azure-premium-disk-with-more-t: High Scale VMs that leverage Azure Premium Storage have a multi-tier caching technology called BlobCache
- https://learn.microsoft.com/en-us/azure/virtual-machines/premium-storage-performance
- https://azure.microsoft.com/en-us/blog/azure-premium-storage-now-generally-available-2/
- https://subscription.packtpub.com/book/cloud-and-networking/9781800204591/5/ch05lvl1sec32/azure-blobcache: None should be used for SQL Server log files. SQL Server log files write data sequentially to disk. There would be no benefit to using ReadOnly caching in that scenario.
- https://github.com/Azure/azure-storage-fuse: --disable-writeback-cache=true: Disallow libfuse to buffer write requests if you must strictly open files in O_WRONLY or O_APPEND mode (--disable-writeback-cache=true for improved file listing latency)
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#before-you-begin: About blobfuse cache: By default, the blobfuse cache is located in the /mnt directory. If the VM SKU provides a temporary disk, the /mnt directory is mounted on the temporary disk. However, if the VM SKU does not provide a temporary disk, the /mnt directory is mounted on the OS disk, you could set --tmp-path= mount option to specify a different cache directory
  
## hyper.hostnode.cache.StorageSpace

- https://learn.microsoft.com/en-us/azure-stack/hci/concepts/cache: Storage Spaces Direct, the foundational storage virtualization technology behind Azure Stack HCI and Windows Server

## hyper.hostnode.cache.uncached

- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/general-purpose/dsv6-series?tabs=sizestorageremote: The 'Remote Storage' section mentions Uncached*
- https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-storage?view=azuresql#uncached-throughput: The max uncached disk IOPS and throughput is the maximum remote storage limit that the VM can handle. This limit is defined at the VM and isn't a limit of the underlying disk storage. This limit applies only to I/O against data drives remotely attached to the VM, not the local I/O against the temp drive (D:\ drive) or the OS drive.
