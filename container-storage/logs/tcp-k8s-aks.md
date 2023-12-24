```
az aks show -g $rg -n aks --query networkProfile.networkPlugin -otsv
```

- https://learn.microsoft.com/en-us/azure/aks/configure-kubenet
- https://learn.microsoft.com/en-us/azure/aks/configure-azure-cni?tabs=configure-networking-portal

```
# Inbound 
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/connection-issues-application-hosted-aks-cluster. Additional articles in this sub-section
# Inbound to apiserver
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/troubleshoot-cluster-connection-issues-api-server. Additional articles in this sub-section
# Outbound
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/basic-troubleshooting-outbound-connections. Additional articles in this sub-section
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/welcome-azure-kubernetes
