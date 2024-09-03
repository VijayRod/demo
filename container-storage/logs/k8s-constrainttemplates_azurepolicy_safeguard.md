```
az aks create -g $rg -n akssafeguard --enable-addons azure-policy --safeguards-level Warning
az aks get-credentials -g $rg -n akssafeguard --overwrite-existing

az aks show -g $rg -n akssafeguard --query addonProfiles.azurepolicy
az aks show -g $rg -n akssafeguard --query safeguardsProfile
{
  "config": null,
  "enabled": true,
  "identity": {
    "clientId": "redacts-2bfd-4a7a-b8ef-111111111111",
    "objectId": "redacts-bd7e-4707-8982-111111111111",
    "resourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/MC_rg_akssafeguard_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurepolicy-akssafeguard"
  }
}
{
  "excludedNamespaces": null,
  "level": "Warning",
  "systemExcludedNamespaces": [
    "kube-system",
    "calico-system",
    "tigera-system",
    "gatekeeper-system"
  ],
  "version": "v1.0.0"
}
```

- https://learn.microsoft.com/en-us/azure/aks/deployment-safeguards
