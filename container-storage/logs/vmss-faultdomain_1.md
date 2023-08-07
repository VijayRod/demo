```
# To create a Virtual Machine Scale Set
az vmss create -g $rgname -n vmssfd --image UbuntuLTS
az vmss create -g $rgname -n vmssfd1 --image UbuntuLTS --platform-fault-domain-count 1

# az vmss show -g $rgname -n vmssfd --query platformFaultDomainCount
(no rows)
# az vmss show -g $rgname -n vmssfd1 --query platformFaultDomainCount
1
```

```
# To create a cluster
clustername=aksfd
az aks create -g $rgname -n $clustername

nodeResourceGroupName=$(az aks show -g $rgname -n $clustername  --query nodeResourceGroup -o tsv)
az vmss show -g $nodeResourceGroupName -n aks-nodepool1-25097321-vmss --query platformFaultDomainCount ## 1
```

```
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones#availability-considerations: Max spreading (platformFaultDomainCount = 1)
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-manage-fault-domains
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-orchestration-modes#what-has-changed-with-flexible-orchestration-mode
