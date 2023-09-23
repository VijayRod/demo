```
az monitor metrics list-definitions --resource $storageUri -otable
az monitor metrics list --resource $storageUri --metric Transactions --start-time $starttime --end-time $endtime -otable # Default --interval is PT1M (1 minute)
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files-troubleshoot
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/storage-monitoring-diagnosing-troubleshooting: AverageE2ELatency. AverageServerLatency
- https://learn.microsoft.com/en-us/azure/storage/files/storage-files-monitoring
- https://learn.microsoft.com/en-us/answers/questions/1092684/azure-file-share-is-this-this-disk-latency-causing: PerfInsights
- https://learn.microsoft.com/en-us/azure/storage/files/storage-files-monitoring-reference: ResponseType
