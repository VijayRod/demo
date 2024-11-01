```
az aks create -g $rg -n aksapivnet --network-plugin azure --enable-apiserver-vnet-integration -s $vmsize -c 2
az aks get-credentials -g $rg -n aksapivnet --overwrite-existing
kubectl get po -A | grep konn # no rows


az aks show -g $rg -n aksapivnet --query apiServerAccessProfile
{
  "authorizedIpRanges": null,
  "disableRunCommand": null,
  "enablePrivateCluster": false,
  "enablePrivateClusterPublicFqdn": null,
  "enableVnetIntegration": true,
  "privateDnsZone": null,
  "subnetId": ""
}

noderg=$(az aks show -g $rg -n aksapivnet --query nodeResourceGroup -o tsv)   
az network vnet subnet show -g $noderg --vnet-name aks-vnet-68386414 -n aks-apiserver-subnet
{
  "addressPrefix": "10.226.0.0/28",
  "delegations": [
    {
      "actions": [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ],
      "etag": "W/\"47cca715-4e7e-4999-951d-042d8794fcde\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aksapivnet_swedencentral/providers/Microsoft.Network/virtualNetworks/aks-vnet-68386414/subnets/aks-apiserver-subnet/delegations/aks-delegation",
      "name": "aks-delegation",
      "provisioningState": "Succeeded",
      "resourceGroup": "MC_rg_aksapivnet_swedencentral",
      "serviceName": "Microsoft.ContainerService/managedClusters",
      "type": "Microsoft.Network/virtualNetworks/subnets/delegations"
    }
  ],
  "etag": "W/\"47cca715-4e7e-4999-951d-042d8794fcde\"",
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aksapivnet_swedencentral/providers/Microsoft.Network/virtualNetworks/aks-vnet-68386414/subnets/aks-apiserver-subnet",
  "ipConfigurations": [
    {
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_RG_AKSAPIVNET_SWEDENCENTRAL/providers/Microsoft.Network/loadBalancers/KUBE-APISERVER/frontendIPConfigurations/KUBE-APISERVER-FRONTEND",
      "resourceGroup": "MC_RG_AKSAPIVNET_SWEDENCENTRAL"
    }
  ],
  "name": "aks-apiserver-subnet",
  "networkSecurityGroup": {
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aksapivnet_swedencentral/providers/Microsoft.Network/networkSecurityGroups/aks-agentpool-68386414-nsg",
    "resourceGroup": "MC_rg_aksapivnet_swedencentral"
  },
  "privateEndpointNetworkPolicies": "Disabled",
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "resourceGroup": "MC_rg_aksapivnet_swedencentral",
  "serviceAssociationLinks": [
    {
      "allowDelete": false,
      "etag": "W/\"47cca715-4e7e-4999-951d-042d8794fcde\"",
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aksapivnet_swedencentral/providers/Microsoft.Network/virtualNetworks/aks-vnet-68386414/subnets/aks-apiserver-subnet/serviceAssociationLinks/AzureKubernetesService",
      "linkedResourceType": "Microsoft.ContainerService/managedClusters",
      "locations": [
        "swedencentral"
      ],
      "name": "AzureKubernetesService",
      "provisioningState": "Succeeded",
      "resourceGroup": "MC_rg_aksapivnet_swedencentral",
      "type": "Microsoft.Network/virtualNetworks/subnets/serviceAssociationLinks"
    }
  ],
  "type": "Microsoft.Network/virtualNetworks/subnets"
}
```

https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration: enables network communication between the API server and the cluster nodes without requiring a private link or tunnel. agent nodes always communicate directly with the private IP address of the API server internal load balancer (ILB) IP without using DNS. no tunnel is required for API server to node connectivity
