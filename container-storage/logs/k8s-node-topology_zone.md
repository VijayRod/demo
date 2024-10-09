## k8s-node-topology_zone

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

## k8s-node-topology_zone.controlplane

- https://learn.microsoft.com/en-us/azure/aks/availability-zones: The availability zones that the managed control plane components are deployed into are not controlled by this parameter (az aks create --zones). They are automatically spread across all availability zones (if present) in the region during cluster deployment.
- https://github.com/Azure/AKS/issues/3493: [Feature] Convert all clusters with non-AZ enabled control planes to be AZ enabled

## k8s-node-topology_zone.azure

- https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview
  - https://learn.microsoft.com/en-us/azure/reliability/availability-zones-service-support#azure-regions-with-availability-zone-support

## k8s-node-topology_zone.azure.vm

- https://learn.microsoft.com/en-us/azure/virtual-machines/availability

## k8s-node-topology_zone.azure.vm.vmss

- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-use-availability-zones

