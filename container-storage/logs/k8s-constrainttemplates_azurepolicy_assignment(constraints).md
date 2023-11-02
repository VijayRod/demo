```
kubectl get constraints | grep k8sazurev3hostnetworkingports
## OR kubectl get k8sazurev3hostnetworkingports

NAME         ENFORCEMENT-ACTION   TOTAL-VIOLATIONS
k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-4c4e07cda01a7867529e   dryrun               1
k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-b5bc9122579d45b0c57b   dryrun               1

kubectl describe k8sazurev3hostnetworkingports
## OR kubectl describe k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-4c4e07cda01a7867529e
## OR kubectl describe constraints > /tmp/constraints.out

Spec:
  Enforcement Action:  dryrun
  Match:
    Excluded Namespaces:
      kube-system
      gatekeeper-system
      azure-arc
      azure-extensions-usage-system
    Kinds:
      API Groups:

      Kinds:
        Pod
  Parameters:
    Allow Host Network:  false
    Excluded Containers:
    Excluded Images:
    Max Port:  0
    Min Port:  0
Status:
  Audit Timestamp:  2023-08-27T22:45:05Z
  ...
  Total Violations:  1
  Violations:
    Enforcement Action:  dryrun
    Group:
    Kind:                Pod
    Message:             The specified hostNetwork and hostPort are not allowed, pod: nginx2, container: nginx2. Allowed values: {"allowHostNetwork": false, "excludedContainers": [], "excludedImages": [], "maxPort": 0, "minPort": 0}
    Name:                nginx2
    Namespace:           default
    Version:             v1
Events:                  <none>
```
