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

## azureblob.debug

```
nslookup fusea5c4594b880c4cc6bf1.blob.core.windows.net
Name:   blob.dsm10prdstf02a.store.core.windows.net

nc -v -w 2 fusea5c4594b880c4cc6bf1.blob.core.windows.net 443
Connection to fusea5c4594b880c4cc6bf1.blob.core.windows.net 443 port [tcp/https] succeeded!

telnet fusea5c4594b880c4cc6bf1.blob.core.windows.net 443
Connected to blob.dsm10prdstf02a.store.core.windows.net.
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/mounting-azure-blob-storage-container-fail: Azure Blob BlobFuse relies on port 443. Make sure that port 443 and/or the IP address of the storage account aren't blocked.

```
# update the version as shown below
kubectl patch daemonset csi-blob-node -n kube-system -p '{"spec":{"template":{"spec":{"initContainers":[{"env":[{"name":"INSTALL_BLOBFUSE2","value":"true"},{"name":"BLOBFUSE2_VERSION","value":"2.3.0 --allow-downgrades"}],"name":"install-blobfuse-proxy"}]}}}}'
```
- https://deepwiki.com/kubernetes-sigs/blob-csi-driver/2-installation-and-configuration#blobfuse-version-management: To downgrade to a lower version of blobfuse2..
    
## azureblob.debug.perf

```
az monitor metrics list-definitions --resource $storageUri -otable
az monitor metrics list --resource $storageUri --metric Transactions --start-time $starttime --end-time $endtime -otable # Default --interval is PT1M (1 minute)
```

- https://learn.microsoft.com/en-us/azure/storage/blobs/storage-performance-checklist
- https://learn.microsoft.com/en-us/azure/storage/blobs/monitor-blob-storage
- https://learn.microsoft.com/EN-us/azure/storage/blobs/monitor-blob-storage-reference: ResponseType


