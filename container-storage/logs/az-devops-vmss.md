- https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops
  
```
az vmss create -g $rg -n devops --image Ubuntu2204

az vmss show -g $rg -n devops --query sku.capacity -otsv # 2
az resource show --id /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Compute/virtualMachineScaleSets/devops --query sku.capacity
az resource list -g $rg --resource-type "Microsoft.Compute/virtualmachinescalesets" --query [].sku.capacity
date

az aks update -g $rg -n devops # reconcile

az vmss delete --force-deletion --no-wait -g $rg -n devops
az vmss delete-instances -g $rg -n devops --instance-ids 0 # instance-ids as seen in the output of az vmss list-instances (these have different values for flex orchestration mode)
```

```
# vmss.instance

az vmss list-instances -g $rg -n devops -otable

az vmss get-instance-view -g MC_rg_aks_swedencentral -n aks-nodepool1-29985679-vmss --query statuses
az vmss get-instance-view -g MC_rg_aks_swedencentral -n aks-nodepool1-29985679-vmss --instance-id "*" --query [].vmAgent.statuses -otable
az vmss get-instance-view -g MC_rg_aks_swedencentral -n aks-nodepool1-29985679-vmss --instance-id 0 --query vmAgent.statuses
```

```
# vmss.scale

az vmss scale -g $rg -n devops --new-capacity 5
```
