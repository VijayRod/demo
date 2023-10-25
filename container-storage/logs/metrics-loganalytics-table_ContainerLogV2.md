```
let date_before_issue=datetime(2023-10-15);
let date_during_issue=datetime(2023-10-25);
let ids1=ContainerLogV2
| where TimeGenerated == date_before_issue
| distinct ContainerId;
let ids2=ContainerLogV2
| where TimeGenerated == date_during_issue
| distinct ContainerId
| where ContainerId in (ids1);
ContainerLogV2
| where ContainerId in (ids2)
| where TimeGenerated ==date_before_issue or TimeGenerated ==date_during_issue
| project TimeGenerated,ContainerId,_BilledSize
| order by ContainerId asc 
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/containerlogv2
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-logging-v2?tabs=configure-portal
