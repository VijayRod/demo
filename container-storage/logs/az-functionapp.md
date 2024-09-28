```
rg=rg
az group create -g $rg -l $loc

storage="storage$RANDOM"
az storage account create -g $rg -n $storage

plan=plan
appserviceplan="appserviceplan$RANDOM"
az appservice plan create -g $rg -n $appserviceplan --sku FREE

functionapp="functionapp$RANDOM"
az functionapp create -g $rg -n $functionapp -p $plan -s $storage
```

```
az functionapp list -g $rg

az functionapp show -g $rg -n $functionapp --query id -otsv
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Web/sites/functionapp19689

```
