```
az aks get-upgrades -g $rg -n aks -otable
az aks upgrade -y -g $rg -n aks --kubernetes-version 1.27.1
# az aks upgrade --control-plane-only -y -g $rg -n aks --kubernetes-version 1.27.1
# az aks nodepool upgrade -y -g $rg --cluster-name aks -n nodepool1 --kubernetes-version 1.27.1
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster
