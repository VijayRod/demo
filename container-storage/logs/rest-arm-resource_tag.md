
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources

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
