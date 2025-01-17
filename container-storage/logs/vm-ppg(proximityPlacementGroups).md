```
az ppg create -g $rg -n ppg --type standard
ppgId=$(az ppg show -g $rg -n ppg --query id -otsv); echo $ppgId # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Compute/proximityPlacementGroups/ppg
az ppg show -g $rg -n ppg --query proximityPlacementGroupType -otsv # Standard
```

## ppg.app.sap

- https://learn.microsoft.com/en-us/azure/sap/workloads/proximity-placement-scenarios

## ppg.spec.singlePlacementGroup

```
# vmss
az vmss create --ppg --single-placement-group
```

```
# vmss.aks
rg=rg100
az group create -n $rg -l $loc
az aks create -g $rg -n aks --load-balancer-sku basic # lb basic
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss show -g $noderg -n aks-nodepool1-25510246-vmss --query singlePlacementGroup # true
```

- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-placement-groups: When set to the default value of true (singlePlacementGroup), a scale set is composed of a single placement group, and has a range of 0-100 VMs.
- https://learn.microsoft.com/en-us/azure/virtual-machines/setup-infiniband#cluster-configuration-options: the maximum scale set size that can be spun up with singlePlacementGroup=true is capped at 100 VMs by default. If your HPC job scale needs are higher than 100 VMs in a single tenant, you may request an increase, open an online customer support request at no charge. The limit on the number of VMs in a single scale set can be increased to 300.
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-subscription-service-limits#virtual-machine-scale-sets-limits: Maximum number of nodes supported in VMSS for IB cluster 100 (IB infiniband)
- https://learn.microsoft.com/en-us/rest/api/compute/virtual-machine-scale-sets/convert-to-single-placement-group?view=rest-compute-2024-11-04&tabs=HTTP
- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-placement-groups: You can change a scale set from supporting a single placement group only (the default behavior) to a supporting multiple placement groups, but you cannot convert the other way around. Therefore make sure you understand the properties of large scale sets before converting.
- https://learn.microsoft.com/en-us/azure/load-balancer/skus: On September 30, 2025, Basic Load Balancer will be retired.

## ppg.vm

- https://azure.microsoft.com/en-us/blog/introducing-proximity-placement-groups/
- https://azure.microsoft.com/en-us/blog/announcing-the-general-availability-of-proximity-placement-groups/
- https://learn.microsoft.com/en-us/azure/virtual-machines/co-location

## ppg.vm.vmss

```
az vmss create --ppg --single-placement-group

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss show -g $noderg -n AKS-NODEPOOL1-23655947-VMSS --query proximityPlacementGroup.id -otsv # ppgId
az vmss show -g $noderg -n AKS-NODEPOOL1-23655947-VMSS --query singlePlacementGroup # false (Not enabled) / true
```

- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-placement-groups

## ppg.vm.vmss.aks

```
rg=rgppg
az group create -n $rg -l $loc
az ppg create -g $rg -n ppg --type standard
ppgId=$(az ppg show -g $rg -n ppg --query id -otsv); echo $ppgId
az aks create -g $rg -n aks --ppg $ppgId -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

az aks show -g $rg -n aks --query agentPoolProfiles[0].proximityPlacementGroupId -otsv # ppgId
az aks show -g $rg -n aks --query loadBalancerProfile.loadBalancerSku # standard
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss show -g $noderg -n AKS-NODEPOOL1-23655947-VMSS --query singlePlacementGroup # false

az aks nodepool add -g $rg --cluster-name aks -n np2
az aks nodepool show -g $rg --cluster-name aks -n np2 --query proximityPlacementGroupId # null
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss show -g $noderg -n aks-np2-35733075-vmss --query singlePlacementGroup # false
```

- https://learn.microsoft.com/en-us/azure/aks/reduce-latency-ppg
