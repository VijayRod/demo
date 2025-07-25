```
# routetable.aks

rg=rgroute
az group create -n $rg -l $loc

az network route-table create -g $rg --name myRouteTable
az network route-table route create -g $rg --route-table-name myRouteTable \
  -n routeToInternetViaFirewall --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address 10.0.0.4

vnetAddressPrefix="10.0.0.0/8"; echo $vnetAddressPrefix
subnetPrefix="10.240.0.0/16"; echo $subnetPrefix
az network vnet create -g $rg -n vnet --address-prefix $vnetAddressPrefix \
  --subnet-name akssubnet --subnet-prefix $subnetPrefix
subnetId=$(az network vnet subnet show -g $rg -n akssubnet --vnet-name vnet --query id -o tsv); echo $subnetId
az network vnet subnet update -g $rg -n akssubnet --vnet-name vnet --route-table myRouteTable

az aks create -g $rg -n aksroute --vnet-subnet-id $subnetId --outbound-type userDefinedRouting 
```
