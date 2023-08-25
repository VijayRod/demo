```
rgname=testshack
loc=swedencentral
plan=MyPlan

az group create -g $rgname -l $loc

az appservice plan create -g $rgname -n $plan
# az appservice plan create -g $rgname -n $plan --sku P1V3
```

```
planId=$(az appservice plan show -g $rgname -n $plan --query id -o tsv)

/subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/testshack/providers/Microsoft.Web/serverfarms/MyPlan
```
