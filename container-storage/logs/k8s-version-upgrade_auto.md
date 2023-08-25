```
az aks update -g $rgname -n $clustername --auto-upgrade-channel stable
```

```
# az aks show -g $rgname -n $clustername --query autoUpgradeProfile
{
  "nodeOsUpgradeChannel": null,
  "upgradeChannel": "stable"
}

# To cleanup
az aks update -g $rgname -n $clustername --auto-upgrade-channel none
```

- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster
