```
rg=rgultra
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-ultra-ssd --zones 1 2 -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query agentPoolProfiles[0].enableUltraSsd
true

az aks nodepool add -g $rg --cluster-name aks -n nodepool --enable-ultra-ssd --zones 1 2 -s $vmsize -c 1
```

- https://learn.microsoft.com/en-us/azure/aks/use-ultra-disks
