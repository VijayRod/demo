## k8s-node-conditions_NodeProblemDetector

```
# See the section on k8s-node-cordon.drain.app.draino
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector
- https://github.com/kubernetes/node-problem-detector: enabled by default in AKS as part of the AKS Linux Extension. node-problem-detector uses Event and NodeCondition to report problems to apiserver
  - https://docs.google.com/document/d/1cs1kqLziG-Ww145yN6vvlKguPbQQ0psrSBnEqpy0pzE/edit?tab=t.0#heading=h.ky5thzvo7t76: Motivation
  - https://github.com/kubernetes/node-problem-detector?#remedy-systems
    
## k8s-node-conditions_NodeProblemDetector.conditions

```
kubectl describe no # Conditions
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#node-conditions
- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#check-the-node-conditions-and-events
- https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#node-conditions
- https://kubernetes.io/docs/reference/node/node-status/#condition
- https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/#taint-nodes-by-condition

## k8s-node-conditions_NodeProblemDetector.events

```
kubectl describe no # Events
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#events
- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#check-the-node-conditions-and-events

## k8s-node-conditions_NodeProblemDetector.events.EgressBlocked

```
curl -m 5 -I https://mcr.microsoft.com
curl -m 5 -I https://management.azure.com
curl -m 5 -I https://login.microsoftonline.com
curl -m 5 -I https://packages.microsoft.com
curl -m 5 -I https://acs-mirror.azureedge.net
```

- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress#azure-global-required-fqdn--application-rules
