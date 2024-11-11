```
az network nsg create -g $rg -n aks-agentpools-nsg
az network nsg rule create -g $rg --nsg-name aks-agentpools-nsg -n DenyAllOutBound-my --priority 100 --access Deny --direction Outbound --protocol "*" --destination-port-ranges "*" --no-wait
az network vnet subnet update -g $rg --vnet-name $vnet -n np2 --nsg aks-agentpools-nsg
```

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network nsg list -g $noderg -otable
az network nsg show -g $noderg -n aks-agentpool-37790187-nsg
```

- https://learn.microsoft.com/en-us/azure/security/fundamentals/network-overview#network-security-rules-nsgs
- https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview
- https://learn.microsoft.com/en-us/azure/well-architected/security/networking: Because network security groups work at layers 3 and 4 on the Open Systems Interconnection (OSI) stack
