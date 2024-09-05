Azure Monitor Private Link Scope (AMPLS)

```
# create
tbd az monitor private-link-scope create -g $rg -n mylinkscope
az monitor private-link-scope list #-otable
az monitor private-link-scope show -g $rg -n mylinkscope

# Alternatively
az resource create -g $rg -n mylinkscope -l global --api-version "2021-07-01-preview" --resource-type Microsoft.Insights/privateLinkScopes --properties "{\"accessModeSettings\":{\"queryAccessMode\":\"Open\", \"ingestionAccessMode\":\"Open\"}}"
az resource show -g $rg -n mylinkscope --resource-type Microsoft.Insights/privateLinkScopes
```

- https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-configure
- https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security
- https://learn.microsoft.com/en-us/cli/azure/monitor/private-link-scope
- https://learn.microsoft.com/en-us/samples/azure-samples/azure-monitor-private-link-scope/azure-monitor-private-link-scope/

```
# add scoped resource
workspaceId=$(az aks show -g $rg -n aksloganalytics --query addonProfiles.omsagent.config.logAnalyticsWorkspaceResourceID -otsv)
echo $workspaceId
# /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/defaultresourcegroup-sec/providers/Microsoft.OperationalInsights/workspaces/defaultworkspace-redacts-1111-1111-1111-111111111111-sec
# https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-configure#connect-azure-monitor-resources
# Portal: In your AMPLS, select Azure Monitor Resources in the menu on the left. Select Add. (add the log analytics workspace)
# tbd az monitor private-link-scope scoped-resource create -g $rg -n scopedworkspace --linked-resource $workspaceId --scope-name mylinkscope

az monitor private-link-scope scoped-resource list -g $rg --scope-name mylinkscope
az monitor private-link-scope scoped-resource show -g $rg --scope-name mylinkscope -n scoped-defaultworkspace-efec8e52-e1ad-4ae1-8598-f243e56e2b08-sec-b06df31b-5f4a-401b-a19c-087ace44600c
[
  {
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/microsoft.insights/privatelinkscopes/my-scope/scopedresources/scoped-defaultworkspace-redacts-1111-1111-1111-111111111111-sec-b06df31b-5f4a-401b-a19c-087ace44600c",
    "linkedResourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/defaultresourcegroup-sec/providers/microsoft.operationalinsights/workspaces/defaultworkspace-redacts-1111-1111-1111-111111111111-sec",
    "name": "scoped-defaultworkspace-redacts-1111-1111-1111-111111111111-sec-b06df31b-5f4a-401b-a19c-087ace44600c",
    "provisioningState": "Succeeded",
    "resourceGroup": "rg",
    "type": "microsoft.insights/privatelinkscopes/scopedresources"
  }
]

az monitor log-analytics workspace show --id $workspaceId --query privateLinkScopedResources
[
  {
    "resourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/microsoft.insights/privatelinkscopes/my-scope/scopedresources/scoped-defaultworkspace-redacts-1111-1111-1111-111111111111-sec-b06df31b-5f4a-401b-a19c-087ace44600c",
    "scopeId": "575ddf44-b12a-48cb-a334-ff6fdb7000f0"
  }
]

az monitor account list #-otable
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/defaultresourcegroup-sec/providers/microsoft.monitor/accounts/defaultazuremonitorworkspace-sec",
    "metrics": {
      "prometheusQueryEndpoint": "https://defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com"

aks-nodepool1-19134489-vmss000000:/# telnet defaultazuremonitorworkspace-sec-amfmcbbvhpdehkfn.swedencentral.prometheus.monitor.azure.com 443
Trying 13.107.246.53...
Connected to s-part-0025.t-0009.t-msedge.net.
Escape character is '^]'.
```

```
# https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-configure#connect-to-a-private-endpoint
tbd az monitor private-link-scope private-link-resource list -g $rg --scope-name mylinkscope #-otable
```
