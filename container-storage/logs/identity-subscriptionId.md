```
# To display the subscription ID
subId=$(az account show --query id -otsv)
```

```
az account set -s $subId
az account list -otable
# /subscriptions/redacts-1111-1111-1111-111111111111
```
