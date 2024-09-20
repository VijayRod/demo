## webapp

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
appId=$(az webapp show -g $rg -n $app --query id -otsv)
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/testshack/providers/Microsoft.Web/sites/MyWebApp24167

appUrl=$(az webapp show -g $rg -n $app --query defaultHostName -otsv)
echo $appUrl
curl $appUrl -I
# mywebapp27540.azurewebsites.net # HTTP/1.1 200 OK

hostNames0=$(az webapp show -g $rg -n $app --query hostNames[0] -otsv)
echo $hostNames0
curl $hostNames0 -I
# mywebapp27540.azurewebsites.net # HTTP/1.1 200 OK

nslookup mywebapp27540.azurewebsites.net
mywebapp27540.azurewebsites.net canonical name = mywebapp27540.privatelink.azurewebsites.net.
mywebapp27540.privatelink.azurewebsites.net     canonical name = waws-prod-sec-015.sip.azurewebsites.windows.net.
waws-prod-sec-015.sip.azurewebsites.windows.net canonical name = waws-prod-sec-015-b71e.swedencentral.cloudapp.azure.com.
Name:   waws-prod-sec-015-b71e.swedencentral.cloudapp.azure.com
Address: 51.12.31.7
```

- https://learn.microsoft.com/en-us/azure/app-service/quickstart-dotnetcore?tabs=net70&pivots=development-environment-cli
- https://techcommunity.microsoft.com/t5/nonprofit-techies/understanding-azure-web-apps-and-azure-app-service/ba-p/3812572: Azure App Service offers several features and benefits: Web Apps
