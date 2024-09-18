```
rgname=rg-webapp # repro-webapp, testshack
loc=swedencentral
plan=MyPlan
app="MyWebApp$RANDOM"

az group create -g $rgname -l $loc

az appservice plan create -g $rgname -n $plan # --sku FREE # F1 / FREE, D1 (Shared), B1-B3, P1V3
planId=$(az appservice plan show -g $rgname -n $plan --query id -o tsv)

az webapp create -g $rgname -n $app -p $plan
# az webapp create -g $rgname -n $app -p $plan -i nginx
```

```
appId=$(az webapp show -g $rgname -n $app --query id)

/subscriptions/8d99b0de-7ea1-4a2b-8fd0-c2ef9f25c5dc/resourceGroups/testshack/providers/Microsoft.Web/sites/MyWebApp24167

hostNames0=$(az webapp show -g $rgname -n $app --query hostNames[0] -otsv)
echo $hostNames0
curl $hostNames0 -I

mywebapp24167.azurewebsites.net
HTTP/1.1 200 OK
```

- https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore?tabs=net70&pivots=development-environment-cli
- https://techcommunity.microsoft.com/t5/nonprofit-techies/understanding-azure-web-apps-and-azure-app-service/ba-p/3812572: Azure App Service offers several features and benefits: Web Apps
