```
# Replace the below with appropriate values.
rg=rgzone
clustername=aks
```

```
# To create a cluster
az aks create -g $rg -n $clustername --zones 1 2
```

```
# az aks show -g $r -n $clustername --query agentPoolProfiles[0].availabilityZones
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
- https://kubernetes.io/docs/setup/best-practices/multiple-zones/
<br>
- https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview
  - https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support
<br>
- https://learn.microsoft.com/en-us/azure/virtual-machines/availability
<br>	
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones

