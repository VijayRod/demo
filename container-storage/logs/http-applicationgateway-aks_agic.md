```
rg=rgagic
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure -a ingress-appgw --appgw-name myApplicationGateway --appgw-subnet-cidr 10.225.0.0/16

appGatewayId=$(az aks show -g $rg -n aks -o tsv --query addonProfiles.ingressApplicationGateway.config.effectiveApplicationGatewayId)
appGatewaySubnetId=$(az network application-gateway show --ids $appGatewayId -o tsv --query gatewayIPConfigurations[0].subnet.id)
agicAddonIdentity=$(az aks show -g $rg -n aks -o tsv --query addonProfiles.ingressApplicationGateway.identity.clientId)
az role assignment create --assignee $agicAddonIdentity --scope $appGatewaySubnetId --role "Network Contributor"
```

- https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new
