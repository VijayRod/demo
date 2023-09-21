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
