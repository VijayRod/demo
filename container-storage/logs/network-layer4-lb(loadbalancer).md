## lb (load balancer)
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-overview: Azure Load Balancer operates at layer 4 of the Open Systems Interconnection (OSI) model.
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-troubleshoot
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-standard-diagnostics

## lb.spec.floatingip

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Enable Floating IP (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-floating-ip

## lb.spec.health

- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16: Enables health probes from Azure Load Balancer to determine the health state of VMs.
- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-troubleshoot-health-probe-status

## lb.spec.idletimeout

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az network lb outbound-rule show -g $noderg --lb-name kubernetes -n aksOutboundRule --query idleTimeoutInMinutes
30

az network lb rule show -g $noderg --lb-name kubernetes -n a3d654cb447704508bc7b1db1dacaec0-TCP-443 # TBD Idle timeout (minutes) (portal)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-tcp-idle-timeout?tabs=tcp-reset-idle-cli
- https://learn.microsoft.com/en-us/azure/aks/load-balancer-standard: IdleTimeoutInMinutes

## lb.spec.tcpreset

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
