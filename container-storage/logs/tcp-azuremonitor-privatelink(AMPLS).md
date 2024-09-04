Azure Monitor Private Link Scope (AMPLS)

```
az resource create -g $rg -n "my-scope" -l global --api-version "2021-07-01-preview" --resource-type Microsoft.Insights/privateLinkScopes --properties "{\"accessModeSettings\":{\"queryAccessMode\":\"Open\", \"ingestionAccessMode\":\"Open\"}}"
az resource show -g $rg -n "my-scope" --resource-type Microsoft.Insights/privateLinkScopes
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-configure
- https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security
- https://learn.microsoft.com/en-us/samples/azure-samples/azure-monitor-private-link-scope/azure-monitor-private-link-scope/
