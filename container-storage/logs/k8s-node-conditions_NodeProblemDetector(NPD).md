## k8s-node-conditions_NodeProblemDetector

```
# See the section on k8s-node-cordon.drain.app.draino
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector
- https://github.com/kubernetes/node-problem-detector: node-problem-detector uses Event and NodeCondition to report problems to apiserver

## k8s-node-conditions_NodeProblemDetector.conditions

```
kubectl describe no # Conditions
```

- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#node-conditions
- https://learn.microsoft.com/en-us/azure/aks/node-problem-detector#check-the-node-conditions-and-events

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
