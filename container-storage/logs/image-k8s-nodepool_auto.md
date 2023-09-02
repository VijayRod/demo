```
az aks update -g $rgname -n $clustername --node-os-upgrade-channel SecurityPatch
```

```
# az aks show -g $rgname -n $clustername --query autoUpgradeProfile
{
  "nodeOsUpgradeChannel": "SecurityPatch",
  "upgradeChannel": null
}

# To cleanup
az aks update -g $rgname -n $clustername --node-os-upgrade-channel none
```

- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-image
