## azureblob

```
az storage blob list --account-name $storage --container-name backups --output table --auth-mode login
az storage blob list --account-name $storage --container-name backups --output table --account-key $key
```

- https://learn.microsoft.com/en-us/rest/api/storageservices/blob-service-rest-api
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/data-protection-backup-recovery
- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-performance-checklist
- https://learn.microsoft.com/en-us/azure/storage/blobs/monitor-blob-storage
- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli
- https://learn.microsoft.com/en-us/azure/storage/blobs/security-recommendations#networking

## azureblob.perf

```
az monitor metrics list-definitions --resource $storageUri -otable
az monitor metrics list --resource $storageUri --metric Transactions --start-time $starttime --end-time $endtime -otable # Default --interval is PT1M (1 minute)
```

- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-performance-checklist
- https://learn.microsoft.com/en-us/azure/storage/blobs/monitor-blob-storage
- https://learn.microsoft.com/EN-us/azure/storage/blobs/monitor-blob-storage-reference: ResponseType

## azureblob.blobfuse

- https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-how-to-deploy
- https://learn.microsoft.com/en-us/azure/storage/blobs/blobfuse2-troubleshooting
- https://github.com/Azure/azure-storage-fuse/blob/main/TSG.md
