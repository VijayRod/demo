## k8s-networkpolicy

```
# See the sections on calico, cilium and npm (Azure Network Policy Manager).

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
