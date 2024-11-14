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
