```
# load-balancer-managed-outbound-ip-count

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akslb -s $vmsize -c 1 --load-balancer-managed-outbound-ip-count 2 # --load-balancer-outbound-ports 1000
# az aks update -g $rg -n akslb --load-balancer-managed-outbound-ip-count 2 # --load-balancer-outbound-ports 1000

az aks show -g $rg -n akslb --query networkProfile.loadBalancerProfile
The behavior of this command has been altered by the following extension: aks-preview
{
  "allocatedOutboundPorts": 1000,
  "backendPoolType": "nodeIPConfiguration",
  "clusterServiceLoadBalancerHealthProbeMode": "ServiceNodePort",
  "effectiveOutboundIPs": [
    {
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_akslb_swedencentral/providers/Microsoft.Network/publicIPAddresses/5ba3fda8-4e25-4f30-b8f1-e7d27c87cd02",
      "resourceGroup": "MC_rg_akslb_swedencentral"
    },
    {
      "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_akslb_swedencentral/providers/Microsoft.Network/publicIPAddresses/3380a3bc-3829-449e-b45f-4dfab9888548",
      "resourceGroup": "MC_rg_akslb_swedencentral"
    }
  ],
  "enableMultipleStandardLoadBalancers": null,
  "idleTimeoutInMinutes": 30,
  "managedOutboundIPs": {
    "count": 2,
    "countIpv6": null
  },
  "outboundIPs": null,
  "outboundIpPrefixes": null
}

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az network lb outbound-rule list -g $noderg --lb-name kubernetes -o table
AllocatedOutboundPorts    EnableTcpReset    IdleTimeoutInMinutes    Name             Protocol    ProvisioningState    ResourceGroup
------------------------  ----------------  ----------------------  ---------------  ----------  -------------------  -----------------------
0                         True              30                      aksOutboundRule  All         Succeeded  MC_rg_aks_swedencentral

az network public-ip list -g $noderg -otable
Name                                  ResourceGroup            Location       Zones    Address       IdleTimeoutInMinutes    ProvisioningState
------------------------------------  -----------------------  -------------  -------  ------------  ----------------------  -------------------
68c14628-122f-4676-9122-02fa4dddd897  MC_rg_aks_swedencentral  swedencentral  312      4.225.192.46  4         Succeeded
```

- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#scale-the-number-of-managed-outbound-public-ips
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#troubleshooting-snat
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections: Use Source Network Address Translation (SNAT) for outbound connections
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#scale-the-number-of-managed-outbound-public-ips: --load-balancer-managed-outbound-ip-count
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard#configure-the-allocated-outbound-ports:  use load-balancer-outbound-ports and either load-balancer-managed-outbound-ip-count, load-balancer-outbound-ips, or load-balancer-outbound-ip-prefixes
- https://learn.microsoft.com/en-us/azure/load-balancer/outbound-rules: Outbound rules allow you to explicitly define SNAT(source network address translation) for a public standard load balancer.
