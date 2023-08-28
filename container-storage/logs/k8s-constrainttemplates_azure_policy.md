```
rgname=testshack4
loc=swedencentral
clustername=akspolicy

az group create -n $rgname -l $loc
az aks create -g $rgname -n $clustername -a azure-policy
# az aks enable-addons -a azure-policy -g $rgname -n $clustername
az aks get-credentials -g $rgname -n $clustername --overwrite-existing
```

```
az aks show -g $rgname -n $clustername --query addonProfiles.azurepolicy

{
  "config": null,
  "enabled": true,
  "identity": {
    "clientId": "dummyc-71ea-443b-a82f-e42358b43492",
    "objectId": "dummyo-118c-477d-9a4a-6f5bdaa95402",
    "resourceId": "/subscriptions/dummys-1111-1111-1111-111111111111/resourcegroups/MC_testshack4_akspolicy_swedencentral/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurepolicy-akspolicy"
  }
}

kubectl get pods -n kube-system | grep pol

azure-policy-7c9cf6bcb6-nsq42          1/1     Running   0          2m40s
azure-policy-webhook-bfd8f6c95-prqdb   1/1     Running   0          2m40s

kubectl get all -n gatekeeper-system

NAME                                         READY   STATUS    RESTARTS   AGE
pod/gatekeeper-audit-7f4f64b7b-8g26t         1/1     Running   0          2m56s
pod/gatekeeper-controller-85fb94bd96-5k697   1/1     Running   0          2m56s
pod/gatekeeper-controller-85fb94bd96-9h9gv   1/1     Running   0          2m56s
NAME                                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/gatekeeper-webhook-service   ClusterIP   10.0.35.249   <none>        443/TCP   3m15s
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gatekeeper-audit        1/1     1            1           3m15s
deployment.apps/gatekeeper-controller   2/2     2            2           3m14s
NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/gatekeeper-audit-7f4f64b7b         1         1         1       2m57s
replicaset.apps/gatekeeper-controller-85fb94bd96   2         2         2       2m57s

kubectl logs -n kube-system -l app=azure-policy | tail

kubectl logs -n gatekeeper-system -l gatekeeper.sh/operation=audit | tail

kubectl logs -n gatekeeper-system -l gatekeeper.sh/operation=webhook | tail
```

```
kubectl get constrainttemplates | grep k8sazure

kubectl describe constrainttemplates k8sazurev1blockdefault | grep azure-policy-definition-id

Annotations:  azure-policy-definition-id-1: /providers/Microsoft.Authorization/policyDefinitions/9f061a12-e40d-4183-a00e-171812443373

kubectl get constraints | grep k8sazurev3hostnetworkingports

NAME         ENFORCEMENT-ACTION   TOTAL-VIOLATIONS
k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-4c4e07cda01a7867529e   dryrun               1
k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-b5bc9122579d45b0c57b   dryrun               1

kubectl describe k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-4c4e07cda01a7867529e
# kubectl describe constraints > /tmp/constraints.out

Metadata:
  Creation Timestamp:  2023-08-27T22:18:23Z
  Generation:          1
  Resource Version:    28886
  UID:                 b762cc70-d6ae-4bc9-9e20-3d491e375f0a
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

```
az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/aks/policy-reference
- https://learn.microsoft.com/en-us/azure/aks/use-azure-policy
- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
- https://github.com/Azure/azure-policy/tree/master/built-in-policies/policyDefinitions/Azure%20Government/Kubernetes
