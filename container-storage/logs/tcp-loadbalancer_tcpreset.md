```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb outbound-rule show -g $noderg --lb-name kubernetes -n aksOutboundRule --query enableTcpReset
true
```

```
az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Enable TCP Reset (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-cli
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard: AKS enables TCP Reset on idle by default. We recommend you keep this configuration and leverage it for more predictable application behavior on your scenarios. TCP RST is only sent during TCP connection in ESTABLISHED state.
