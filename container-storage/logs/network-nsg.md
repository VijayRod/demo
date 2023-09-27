```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network nsg list -g $noderg -otable
az network nsg show -g $noderg -n aks-agentpool-37790187-nsg
```
