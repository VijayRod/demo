```
# Replace the below with appropriate values.
rgname=
clustername=akszone
```

```
# To create a cluster
az aks create -g $rgname -n $clustername --zones 1 2
```

```
# az aks show -g $rgname -n $clustername --query agentPoolProfiles[0].availabilityZones
[
  "1",
  "2"
]
```

```
# kubectl describe nodes | grep -e "Name:" -e "topology.kubernetes.io/zone"
Name:               aks-nodepool1-29870350-vmss000000
                    topology.kubernetes.io/zone=swedencentral-1
Name:               aks-nodepool1-29870350-vmss000001
                    topology.kubernetes.io/zone=swedencentral-2
Name:               aks-nodepool1-29870350-vmss000002
                    topology.kubernetes.io/zone=swedencentral-1
```                    
                    
- https://learn.microsoft.com/en-us/azure/aks/availability-zones
- https://learn.microsoft.com/en-us/azure/aks/free-standard-pricing-tiers#uptime-sla-terms-and-conditions

- https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview
  - https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support

- https://learn.microsoft.com/en-us/azure/virtual-machines/availability
	
	
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones

