```
rg=rg-webapp # repro-webapp, testshack
loc=swedencentral
plan=MyPlan
app="MyWebApp$RANDOM"

az group create -g $rg -l $loc

az appservice plan create -g $rg -n $plan # --sku FREE # F1 / FREE, D1 (Shared), B1-B3, P1V3
planId=$(az appservice plan show -g $rg -n $plan --query id -o tsv)

az webapp create -g $rg -n $app -p $plan
# az webapp create -g $rg -n $app -p $plan -i nginx
```

```
appId=$(az webapp show -g $rg -n $app --query id)
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/testshack/providers/Microsoft.Web/sites/MyWebApp24167

webappUrl=$(az webapp show -g $rg -n $app --query defaultHostName -otsv)
echo $webappUrl
curl $webappUrl -I
# mywebapp27540.azurewebsites.net # HTTP/1.1 200 OK

hostNames0=$(az webapp show -g $rg -n $app --query hostNames[0] -otsv)
echo $hostNames0
curl $hostNames0 -I
# mywebapp27540.azurewebsites.net # HTTP/1.1 200 OK
```

- https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore?tabs=net70&pivots=development-environment-cli
- https://techcommunity.microsoft.com/t5/nonprofit-techies/understanding-azure-web-apps-and-azure-app-service/ba-p/3812572: Azure App Service offers several features and benefits: Web Apps
