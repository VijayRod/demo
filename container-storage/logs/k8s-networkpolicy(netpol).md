## k8s-networkpolicy

```
## See the section on CNI network policy

k api-resources
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
networkpolicies                     netpol              networking.k8s.io/v1                   true         NetworkPolicy
```

- https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/
- https://kubernetes.io/docs/concepts/services-networking/network-policies/
  
## k8s-networkpolicy.spec.provider

- https://kubernetes.io/docs/tasks/administer-cluster/declare-network-policy/#before-you-begin: Make sure you've configured a network provider with network policy support. There are a number of network providers that support NetworkPolicy, including...

### k8s-networkpolicy.spec.provider.policy

- https://kubernetes.io/docs/concepts/services-networking/network-policies/#prerequisites: Network policies are implemented by the network plugin. To use network policies, you must be using a networking solution which supports NetworkPolicy. Creating a NetworkPolicy resource without a controller that implements it will have no effect.

## k8s-networkpolicy.spec.provider.azure.policy.npm.disable

```
az aks update -g $rg -n akscal --network-policy none # disable an existing network policy
```

- https://github.com/Azure/AKS/issues/3845: [Feature] Disable network policy on the existing AKS Cluster (to allow migration to overlay): --network-policy none
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest: "none" when no Network Policy Engine is installed (default value).
- tbd https://github.com/Azure/AKS/releases/tag/2024-02-07
- https://github.com/Azure/AKS/releases/tag/2024-05-13: Default network policy is "networkPolicy=none" when network policy is not set on new clusters starting from API version 2024-05-01. Allow disabling NPM for existing clusters with "networkPolicy=none" for stable api version 2024-05-01.
