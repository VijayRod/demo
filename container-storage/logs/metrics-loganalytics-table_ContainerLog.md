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
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/containerlog
