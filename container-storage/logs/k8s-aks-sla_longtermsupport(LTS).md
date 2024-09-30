```
az aks create -g $rg -n akslts --tier premium --k8s-support-plan AKSLongTermSupport --kubernetes-version 1.27

az aks show -g $rg -n akslts
  "sku": {
    "tier": "Premium"
  "kubernetesVersion": "1.27",
  "supportPlan": "AKSLongTermSupport",
```

- https://github.com/aks-lts
- https://github.com/kubernetes/community/tree/master/archive/wg-lts
- https://techcommunity.microsoft.com/t5/apps-on-azure-blog/azure-kubernetes-upgrades-and-long-term-support/ba-p/3782789
- https://learn.microsoft.com/en-us/azure/aks/long-term-support
- https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli#long-term-support-lts
- https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/: Long Term Support
- https://azure.microsoft.com/en-us/updates/generally-available-long-term-support-version-in-aks/
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest: AKSLongTermSupport
