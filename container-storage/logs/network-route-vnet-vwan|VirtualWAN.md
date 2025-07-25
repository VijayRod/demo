```
# vwan
# /subscriptions/$subId/resourceGroups/rg-vwan-aks/providers/Microsoft.Network/virtualWans/vwan-global

rg=rgvwan
az group create -n $rg -l $loc
az network vwan create -g $rg -n myvwan --type Standard
```

```
# vwan.aks
# Please note that cluster nodes will not be able to complete extension provisioning unless an egress path, such as an NVA or an outbound rule to the internet, is configured.
# For clusters in a VWAN environment, it is recommended to configure AKS network isolated clusters with the outbound type set to none, as egress paths are inherited from the VWAN.

rg=rg-vwan-aks
RG=$rg
LOCATION=$loc
VNET_NAME=vnet
SUBNET_NAME=akssubnet
AKS_NAME=aks
VWAN_NAME="vwan-global"
VHUB_NAME="vhub-central"
SUBNET_PREFIX="10.240.0.0/16"
VNET_PREFIX="10.0.0.0/8"

az group create --name $RG --location $LOCATION

az network vnet create \
  --resource-group $RG \
  --name $VNET_NAME \
  --address-prefix $VNET_PREFIX \
  --subnet-name $SUBNET_NAME \
  --subnet-prefix $SUBNET_PREFIX

az network vwan create \
  --name $VWAN_NAME \
  --resource-group $RG \
  --location $LOCATION

az network vhub create \
  --name $VHUB_NAME \
  --resource-group $RG \
  --vwan $VWAN_NAME \
  --address-prefix "10.200.0.0/24" \
  --location $LOCATION

# optional
az network vpn-gateway create \
  --name "vpn-gateway" \
  --resource-group $RG \
  --vhub-name $VHUB_NAME \
  --location $LOCATION \
  --asn 65515 \
  --gateway-scale-unit 1

az network route-table create \
  --name "udr-aks" \
  --resource-group $RG \
  --location $LOCATION
az network vnet subnet update \
  --name $SUBNET_NAME \
  --vnet-name $VNET_NAME \
  --resource-group $RG \
  --route-table "udr-aks"

SUBNET_ID=$(az network vnet subnet show \
  --resource-group $RG \
  --vnet-name $VNET_NAME \
  --name $SUBNET_NAME \
  --query id -o tsv)

az aks create \
  --resource-group $RG \
  --name $AKS_NAME \
  --enable-private-cluster \
  --network-plugin azure \
  --vnet-subnet-id $SUBNET_ID \
  --outbound-type userDefinedRouting


# optional
az network route-table route create \
  --resource-group $RG \
  --route-table-name "udr-aks" \
  --name "default-route" \
  --address-prefix "0.0.0.0/0" \
  --next-hop-type VirtualAppliance \
  --next-hop-ip-address 

az network vhub connection create \
  --name "vnet-aks-connection" \
  --resource-group $RG \
  --vhub-name $VHUB_NAME \
  --remote-vnet $VNET_NAME \
  --internet-security-enabled false \
  --enable-internet-security false


```
