```
rg=rgsec
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-private-cluster --disable-public-fqdn -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks update -g $rg -n aks --disable-public-fqdn
az aks update -g $rg -n aks --enable-public-fqdn

az aks show -g $rg -n aks --query apiServerAccessProfile.enablePrivateClusterPublicFqdn # false
az aks show -g $rg -n aks --query fqdn # null
```  

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal#disable-a-public-fqdn
