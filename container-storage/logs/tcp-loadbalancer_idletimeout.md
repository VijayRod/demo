```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb outbound-rule show -g $noderg --lb-name kubernetes -n aksOutboundRule --query idleTimeoutInMinutes
30

az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Idle timeout (minutes) (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-cli
<br>

- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard: IdleTimeoutInMinutes
