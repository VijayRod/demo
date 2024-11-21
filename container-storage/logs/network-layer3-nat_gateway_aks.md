## natgateway

```
# Replace the below with appropriate values.
rgname=rg
clustername=aksnat
```

```
# To create a cluster with a NAT gateway, the ip-count and idle-timeout values are optional.
az aks create -g $rgname -n $clustername --outbound-type managedNATGateway \
    --nat-gateway-managed-outbound-ip-count 2 --nat-gateway-idle-timeout 4 -s $vmsize -c 2
    
# To update an existing cluster
az aks update -g $rgname -n $clustername --outbound-type managedNATGateway \
    --nat-gateway-managed-outbound-ip-count 2 --nat-gateway-idle-timeout 4
```

```
# To query the values
az aks show -g $rgname -n $clustername --query networkProfile.natGatewayProfile
az aks show -g $rgname -n $clustername --query networkProfile.outboundType

# Here is a sample output below.
{
  "effectiveOutboundIPs": [
    {
      "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/nodeResourceGroup/providers/Microsoft.Network/publicIPAddresses/ef622b1e-91cd-418b-88bc-5d85ceb8d3e9",
      "resourceGroup": "nodeResourceGroup"
    },
    {
      "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/nodeResourceGroup/providers/Microsoft.Network/publicIPAddresses/6877ebe0-593f-4da5-aef0-9f7143a4578a",
      "resourceGroup": "nodeResourceGroup"
    }
  ],
  "idleTimeoutInMinutes": 4,
  "managedOutboundIpProfile": {
    "count": 2
  }
}
"managedNATGateway"
```

```
# To cleanup
az aks delete -g $rgname -n $clustername -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/aks/nat-gateway
