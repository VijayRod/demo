```
AzureDiagnostics
| where TimeGenerated>ago(1d)
| summarize count() by Category,_ResourceId
| order by count_ desc

AzureDiagnostics
| where Category=="kube-audit"
| summarize count() by bin(TimeGenerated,1d)
| order by count_ desc
```

- https://learn.microsoft.com/en-us/azure/aks/monitor-aks: Azure diagnostics mode sends all data to the AzureDiagnostics table, while resource-specific mode sends data to AKS Audit, AKS Audit Admin, and AKS Control Plane as shown in the table at Resource logs. There can be substantial cost when collecting resource logs for AKS, particularly for kube-audit logs.
- https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/azurediagnostics
