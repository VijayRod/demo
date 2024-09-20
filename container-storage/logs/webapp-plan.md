```
rg=testshack
loc=swedencentral
plan=plan

az group create -g $rg -l $loc

az appservice plan create -g $rg -n $plan
# az appservice plan create -g $rg -n $plan --sku P1V3
```

```
planId=$(az appservice plan show -g $rg -n $plan --query id -o tsv)

/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/testshack/providers/Microsoft.Web/serverfarms/MyPlan
```

- https://learn.microsoft.com/en-us/azure/app-service/overview-hosting-plans#should-i-put-an-app-in-a-new-plan-or-an-existing-plan
- https://azure.microsoft.com/en-us/pricing/calculator/: App Service
