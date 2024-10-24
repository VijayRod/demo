```
az tag list --resource-id /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral
{
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Resources/tags/default",
  "name": "default",
  "properties": {
    "tags": {
      "aks-managed-cluster-name": "aks",
      "aks-managed-cluster-rg": "rg"
    }
  },
  "resourceGroup": "MC_rg_aks_swedencentral",
  "type": "Microsoft.Resources/tags"
}

az resource show --ids /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral
{
  "extendedLocation": null,
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral",
  "identity": null,
  "kind": null,
  "location": "swedencentral",
  "managedBy": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/Microsoft.ContainerService/managedClusters/aks",
  "name": "MC_rg_aks_swedencentral",
  "plan": null,
  "properties": {
    "provisioningState": "Succeeded"
  },
  "sku": null,
  "tags": {
    "aks-managed-cluster-name": "aks",
    "aks-managed-cluster-rg": "rg"
  },
  "type": "Microsoft.Resources/resourceGroups"
}
 
az resource show --query tags --ids /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral
{
  "aks-managed-cluster-name": "aks",
  "aks-managed-cluster-rg": "rg"
}
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources-cli
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#tag-resource-groups

```
az aks create -g $rg -n aks --tags dept=IT costcenter=9999 -s $vmSize
# az aks update -g $rg -n aks --tags dept=IT team=alpha costcenter=12345 #  # The MC_ resource group and its network resources (NSG, route table, LB) now have these tags.
# az aks update -g repro-502 -n aks-repro-502 --tags ""
az aks show -g $rg -n aks --query '[tags]' # Default value is [ null ]

az aks nodepool add -g $rg --cluster-name aks -n nptag --tags abtest=a costcenter=5555 -s $vmSize -c 1 --no-wait
# az aks nodepool update -g $rg --cluster-name aks -n nptag --tags appversion=0.0.2 costcenter=4444 --no-wait
az aks show -g $rg -n aks --query 'agentPoolProfiles[].{nodepoolName:name,tags:tags}'
```

- https://azure.microsoft.com/en-us/updates/general-availability-azure-tags-support-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/use-tags
- https://learn.microsoft.com/en-us/azure/aks/faq#can-i-modify-tags-and-other-properties-of-the-aks-resources-in-the-node-resource-group
- https://learn.microsoft.com/en-us/azure/aks/faq#can-i-provide-my-own-name-for-the-aks-node-resource-group: tag
