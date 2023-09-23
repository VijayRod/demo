```
az monitor metrics list-definitions --resource $resourceUri -otable
```

```
az monitor metrics list --resource $storageUri --metric Transactions --start-time $starttime --end-time $endtime -otable # Default --interval is PT1M (1 minute)
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/metrics-aggregation-explained
- https://learn.microsoft.com/en-us/rest/api/monitor/metrics/list?tabs=CLI
