- https://learn.microsoft.com/en-us/azure/azure-monitor/logs/api/errors
- https://learn.microsoft.com/en-us/azure/azure-monitor/logs/api/response-format

```
az monitor log-analytics workspace create -g $rg -n laworkspace
az monitor log-analytics workspace show -g $rg -n laworkspace --query id -otsv
```
- https://learn.microsoft.com/en-us/cli/azure/monitor/log-analytics/workspace
