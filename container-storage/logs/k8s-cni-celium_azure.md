```
rg=rgcni
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-plugin-mode overlay --pod-cidr 192.168.0.0/16 --network-dataplane cilium -s $vmsize -c 1 
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query networkProfile.networkDataplane # cilium
az aks show -g $rg -n aks --query networkProfile.networkPlugin # azure
az aks show -g $rg -n aks --query networkProfile.networkPluginMode # overlay
az aks show -g $rg -n aks --query networkProfile.networkPolicy # cilium
```

- https://techcommunity.microsoft.com/t5/azure-networking-blog/azure-cni-powered-by-cilium-for-azure-kubernetes-service-aks/ba-p/3662341: Cilium eBPF
- https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium
- https://azure.microsoft.com/en-us/updates/azure-cni-powered-by-cilium/
- https://kubernetes.io/docs/tasks/administer-cluster/network-policy-provider/cilium-network-policy/
- https://cilium.io/industries/cloud-providers/
- https://docs.cilium.io/en/stable/#getting-started
- https://docs.cilium.io/en/stable/operations/troubleshooting/
- https://docs.cilium.io/en/v1.9/gettingstarted/k8s-install-aks/
