```
# Replace the below with appropriate values.
location=swedencentral
```

```
# To list compute SKUs for the subscription
# Get-AzComputeResourceSku | where {$_.Locations.Contains("japaneast") -and $_.ResourceType.Contains("hostGroups/hosts")};
az vm list-skus -l $location -r hostGroups/hosts -o table
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/dedicated-host-general-purpose-skus
