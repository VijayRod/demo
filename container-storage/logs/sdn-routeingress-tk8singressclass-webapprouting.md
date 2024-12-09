```
az aks show -g $rg -n aks --query ingressProfile.webAppRouting
{
  "dnsZoneResourceIds": null,
  "enabled": true,
  "identity": {
    "clientId": "redactc-1111-1111-1111-111111111111",
    "objectId": "redacto-1111-1111-1111-111111111111",
    "resourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/MC_rgapprouting_aks_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/webapprouting-aks"
  }
}

kubectl get ingressclass
NAME                                 CONTROLLER                                 PARAMETERS   AGE
webapprouting.kubernetes.azure.com   webapprouting.kubernetes.azure.com/nginx   <none>       79s
```

- https://learn.microsoft.com/en-us/azure/aks/app-routing?tabs=without-osm
