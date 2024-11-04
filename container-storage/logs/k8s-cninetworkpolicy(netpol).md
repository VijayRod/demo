## k8s-cninetworkpolicy

- https://kubernetes.io/docs/concepts/services-networking/network-policies/

## k8s-cninetworkpolicy.disable

```
az aks update -g $rg -n akscal --network-policy none # disable an existing network policy
```

- https://github.com/Azure/AKS/issues/3845: [Feature] Disable network policy on the existing AKS Cluster (to allow migration to overlay): --network-policy none
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest: "none" when no Network Policy Engine is installed (default value).
- tbd https://github.com/Azure/AKS/releases/tag/2024-02-07
- https://github.com/Azure/AKS/releases/tag/2024-05-13: Default network policy is "networkPolicy=none" when network policy is not set on new clusters starting from API version 2024-05-01. Allow disabling NPM for existing clusters with "networkPolicy=none" for stable api version 2024-05-01.
