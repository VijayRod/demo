## az-appservice

```
rg=rg
az group create -g $rg -l $loc

plan=plan
appserviceplan="appserviceplan$RANDOM"
az appservice plan create -g $rg -n $appserviceplan # --sku FREE # F1 / FREE, D1 (Shared), B1-B3, P1V3

planId=$(az appservice plan show -g $rg -n $plan --query id -o tsv)
```
