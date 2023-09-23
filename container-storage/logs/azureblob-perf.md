```
az monitor metrics list-definitions --resource $storageUri -otable
az monitor metrics list --resource $storageUri --metric Transactions --start-time $starttime --end-time $endtime -otable # Default --interval is PT1M (1 minute)
```

- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-performance-checklist
- https://learn.microsoft.com/en-us/azure/storage/blobs/monitor-blob-storage
- https://learn.microsoft.com/EN-us/azure/storage/blobs/monitor-blob-storage-reference: ResponseType
