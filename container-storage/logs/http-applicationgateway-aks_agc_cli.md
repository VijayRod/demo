```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network alb list -g $noderg -otable
az network alb show -g $noderg -n alb-b4aa9f12
az network alb show -g $noderg -n alb-b4aa9f12 --query id -otsv # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgagc_aks_westus/providers/Microsoft.ServiceNetworking/trafficControllers/alb-b4aa9f12
```
