```
rg=rgsec
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-private-cluster -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query apiServerAccessProfile # "apiServerAccessProfile": null for a non-private cluster
{
  "authorizedIpRanges": null,
  "disableRunCommand": null,
  "enablePrivateCluster": true,
  "enablePrivateClusterPublicFqdn": true,
  "enableVnetIntegration": null,
  "privateDnsZone": "system",
  "subnetId": null
}

az aks show -g $rg -n aks --query fqdn -otsv
aks-rgsec-8d99b0-zodmp4em.hcp.swedencentral.azmk8s.io

az aks show -g $rg -n aks --query privateFqdn -otsv
aks-rgsec-111111-3d9q3p7f.1d71c86b-50e6-40b5-9f84-111111111111.privatelink.swedencentral.azmk8s.io

az aks show -g $rg -n aks --query privateLinkResources
[
  {
    "groupId": "management",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rgsec/providers/Microsoft.ContainerService/managedClusters/aks/privateLinkResources/management",
    "name": "management",
    "privateLinkServiceId": null,
    "requiredMembers": [
      "management"
    ],
    "resourceGroup": "rgsec",
    "type": "Microsoft.ContainerService/managedClusters/privateLinkResources"
  }
]
```

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal
