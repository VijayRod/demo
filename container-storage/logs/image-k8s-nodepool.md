```
az aks nodepool upgrade -g $rg --cluster-name aks -n np2019
```

- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster: node-image
- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-image
- https://learn.microsoft.com/en-us/azure/aks/planned-maintenance: default, aksManagedNodeOSUpgradeSchedule
- https://github.com/Azure/AKS/blob/master/CHANGELOG.md: option None in the node OS upgrade
