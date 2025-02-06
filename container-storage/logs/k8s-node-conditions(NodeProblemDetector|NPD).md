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

```
# See the section on IMDS

curl -m 5 -I https://packages.microsoft.com
HTTP/2 200
date: Tue, 04 Feb 2025 18:11:49 GMT
content-type: text/html
content-length: 2711
last-modified: Mon, 03 Feb 2025 01:23:59 GMT
etag: "67a01aaf-a97"
strict-transport-security: max-age=31536000; includeSubDomains
x-content-type-options: nosniff
x-azure-ref: 20250204T141149Z-r15774cf85dn94vbhC1LONxrx000000002d00000000017pf
x-cache: TCP_HIT
cache-control: public, max-age=15552000
x-fd-int-roxy-purgeid: 66950501
accept-ranges: bytes
```
