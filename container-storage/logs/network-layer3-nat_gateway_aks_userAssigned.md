```
# Replace the below with appropriate values.
rgname=secureshack2
clustername=aksnat2
vnet=myvnet
```

```
# To create a managed identity for network permissions and store the ID to $IDENTITY_ID for later use
IDENTITY_ID=$(az identity create -g $rgname -n myNatClusterId --query id --output tsv)

# To create a public IP for the NAT gateway
az network public-ip create -g $rgname -n myNatGatewayPip --sku standard

# To create a NAT gateway
az network nat gateway create -g $rgname -n myNatGateway --public-ip-addresses myNatGatewayPip

# To create a virtual network
az network vnet create -g $rgname -n $vnet --address-prefixes 10.0.0.0/8

# To create a subnet in the virtual network using the NAT gateway and store the ID to $SUBNET_ID for later use.
SUBNET_ID=$(az network vnet subnet create -g $rgname --vnet-name $vnet -n myNatCluster \
    --address-prefixes 10.240.0.0/16 \
    --nat-gateway myNatGateway \
    --query id --output tsv)

# To create an AKS cluster
az aks create -g $rgname -n $clustername \
    --vnet-subnet-id $SUBNET_ID \
    --outbound-type userAssignedNATGateway \
    --enable-managed-identity \
    --assign-identity $IDENTITY_ID
```    

```
# az aks show -g $rgname -n $clustername --query networkProfile.outboundType
"userAssignedNATGateway"

# az aks show -g $rgname -n $clustername --query agentPoolProfiles[0].vnetSubnetId. The subnet is associated with the NAT gateway.
"/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/resourceGroupName/providers/Microsoft.Network/virtualNetworks/myVnet/subnets/myNatCluster"
```

```    
# az aks show -g $rgname -n $clustername --query networkProfile.natGatewayProfile
(null)

# az aks show -g $rgname -n $clustername --query identity
{
  "principalId": null,
  "tenantId": null,
  "type": "UserAssigned",
  "userAssignedIdentities": {
    "/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/resourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/myNatClusterId": {
      "clientId": "dummyc-1111-1111-1111-111111111111",
      "principalId": "dummyp-1111-1111-1111-111111111111"
    }
  }
}
```

```
# To cleanup
az aks delete -g $rgname -n $clustername -y
az network vnet delete -g $rgname -n $vnet
az network nat gateway delete -g $rgname -n myNatGateway
az network public-ip delete -g $rgname -n myNatGatewayPip --no-wait
az identity delete -g $rgname -n myNatClusterId
```

- https://learn.microsoft.com/en-us/azure/aks/nat-gateway#create-an-aks-cluster-with-a-user-assigned-nat-gateway
