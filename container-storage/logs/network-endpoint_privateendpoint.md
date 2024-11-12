## privateendpoint

```
# See the section on privateendpoint.app.webapp
```

- https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-cli

## privateendpoint.app.storage

https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints: When you create a private endpoint, the DNS CNAME resource record for the storage account is updated to an alias in a subdomain with the prefix privatelink

## privateendpoint.app.webapp

```
rg=rgvnet
az group create -n $rg -l $loc

plan=plan
app="app$RANDOM"
az appservice plan create -g $rg -n $plan --sku P2V2 # PremiumV2-tier or higher app service plan
planId=$(az appservice plan show -g $rg -n $plan --query id -o tsv)
az webapp create -g $rg -n $app -p $plan
appId=$(az webapp show -g $rg -n $app --query id -otsv)
appUrl=$(az webapp show -g $rg -n $app --query defaultHostName -otsv)
echo $appUrl
curl $appUrl -I

az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n appsubnet --address-prefixes 10.240.0.0/16 -o none
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n appsubnet --query id -otsv)

az network private-endpoint create -g $rg -n pe --connection-name appcon --vnet-name vnet --subnet appsubnet --private-connection-resource-id $appId --group-id sites
az network private-dns zone create -g $rg -n "privatelink.azurewebsites.net"
az network private-dns link vnet create -g $rg --zone-name "privatelink.azurewebsites.net" -n dnslink --virtual-network vnet --registration-enabled false
az network private-endpoint dns-zone-group create -g $rg --endpoint-name pe -n zonegroup --private-dns-zone "privatelink.azurewebsites.net" --zone-name webapp

subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n appsubnet --query id -otsv)
az vm create -g $rg -n vm --image Ubuntu2204 --admin-username azureuser --public-ip-sku Standard --subnet $subnetId

# nslookup shows the private IP address
ssh azureuser@ip
azureuser@vm:~$ nslookup mywebapp27540.azurewebsites.net
mywebapp27540.azurewebsites.net canonical name = mywebapp27540.privatelink.azurewebsites.net.
Name:   mywebapp27540.privatelink.azurewebsites.net
Address: 10.240.0.4
```
  
- https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-cli?tabs=dynamic-ip

## privateendpoint.debug

```
# Our test, which involved editing the host file on a cluster node to include the correct DNS record, allowed docker login to succeed, confirming our theory about the need for correct DNS record.
```
