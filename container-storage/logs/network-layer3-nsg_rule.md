```
az network nsg rule create -g $rg --nsg-name aks-agentpools-nsg -n DenyAllOutBound-my --priority 100 --access Deny --direction Outbound --protocol "*" --destination-port-ranges "*" --no-wait

az network nsg rule list -g $noderg --nsg-name aks-agentpool-37790187-nsg -otable
```
