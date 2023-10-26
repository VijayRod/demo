```
ContainerLog
| where TimeGenerated>ago(1d)
| summarize count() by ContainerID,_ResourceId
| order by count_ desc

let date_before_issue=datetime(2023-10-15);
let date_during_issue=datetime(2023-10-25);
let ids1=ContainerLog
| where TimeGenerated == date_before_issue
| distinct ContainerID;
let ids2=ContainerLog
| where TimeGenerated == date_during_issue
| distinct ContainerID
| where ContainerID in (ids1);
ContainerLog
| where ContainerID in (ids2)
| where TimeGenerated==date_before_issue or TimeGenerated==date_during_issue
| project TimeGenerated,ContainerID,_BilledSize
| order by ContainerID asc

KubePodInventory
| distinct ContainerID, Namespace
| join
(
    ContainerLog
)
on ContainerID
| summarize count() by bin(TimeGenerated, 2h), Namespace
| sort by  Namespace asc, TimeGenerated asc
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/containerlog
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-agent-config#data-collection-settings: [log_collection_settings.stdout] exclude_namespaces =
- https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-v2-migration
