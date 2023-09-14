```
nslookup fusea5c4594b880c4cc6bf1.blob.core.windows.net
Name:   blob.dsm10prdstf02a.store.core.windows.net

nc -v -w 2 fusea5c4594b880c4cc6bf1.blob.core.windows.net 443
Connection to fusea5c4594b880c4cc6bf1.blob.core.windows.net 443 port [tcp/https] succeeded!

telnet fusea5c4594b880c4cc6bf1.blob.core.windows.net 443
Connected to blob.dsm10prdstf02a.store.core.windows.net.
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/mounting-azure-blob-storage-container-fail: Azure Blob BlobFuse relies on port 443. Make sure that port 443 and/or the IP address of the storage account aren't blocked.
