```
rgname=rgpolicy
clustername=aks

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

NAME                                         READY   STATUS    RESTARTS   AGE     LABELS
pod/gatekeeper-audit-7f4f64b7b-jw9qm         1/1     Running   0          2m36s   control-plane=audit-controller,gatekeeper.sh/operation=audit,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks,pod-template-hash=7f4f64b7b
pod/gatekeeper-controller-85fb94bd96-5ss5r   1/1     Running   0          2m36s   control-plane=controller-manager,gatekeeper.sh/operation=webhook,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks,pod-template-hash=85fb94bd96
pod/gatekeeper-controller-85fb94bd96-knr7h   1/1     Running   0          2m36s   control-plane=controller-manager,gatekeeper.sh/operation=webhook,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks,pod-template-hash=85fb94bd96
NAME                                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE     LABELS
service/gatekeeper-webhook-service   ClusterIP   10.0.215.162   <none>        443/TCP   2m36s   addonmanager.kubernetes.io/mode=Reconcile,gatekeeper.sh/system=yes
NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE     LABELS
deployment.apps/gatekeeper-audit        1/1     1            1           2m36s   addonmanager.kubernetes.io/mode=Reconcile,control-plane=controller-manager,gatekeeper.sh/operation=audit,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks
deployment.apps/gatekeeper-controller   2/2     2            2           2m36s   addonmanager.kubernetes.io/mode=Reconcile,control-plane=controller-manager,gatekeeper.sh/operation=webhook,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks
NAME                                               DESIRED   CURRENT   READY   AGE     LABELS
replicaset.apps/gatekeeper-audit-7f4f64b7b         1         1         1       2m36s   control-plane=audit-controller,gatekeeper.sh/operation=audit,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks,pod-template-hash=7f4f64b7b
replicaset.apps/gatekeeper-controller-85fb94bd96   2         2         2       2m36s   control-plane=controller-manager,gatekeeper.sh/operation=webhook,gatekeeper.sh/system=yes,kubernetes.azure.com/managedby=aks,pod-template-hash=85fb94bd96

kubectl logs -n kube-system -l app=azure-policy | tail
{"level":"info","ts":"2023-10-19T13:02:31.950652885Z","msg":"Schedule running","log-id":"5290a684-6-393","method":"github.com/Azure/azure-policy-kubernetes/pkg/scheduler.(*Scheduler).wrapFunction.func1","schedule-name":"sync-config-setup"}
{"level":"info","ts":"2023-10-19T13:02:32.209703597Z","msg":"Config file unchanged","log-id":"5290a684-6-394","method":"github.com/Azure/azure-policy-kubernetes/pkg/gatekeeper/confighandler.(*Client).update"}

kubectl logs -n gatekeeper-system -l gatekeeper.sh/operation=audit | tail
{"level":"info","ts":1697720537.369357,"logger":"controller","msg":"handling constraint update","process":"constraint_controller","instance":{"apiVersion":"constraints.gatekeeper.sh/v1beta1","kind":"K8sAzureV2ContainerAllowedImages","name":"azurepolicy-k8sazurev2containerallowedimag-e8257f540e4209db2eb6"}}
{"level":"info","ts":1697720537.420827,"logger":"controller","msg":"handling constraint update","process":"constraint_controller","instance":{"apiVersion":"constraints.gatekeeper.sh/v1beta1","kind":"K8sAzureV3AllowedUsersGroups","name":"azurepolicy-k8sazurev3allowedusersgroups-74e00d596c80b8d0aa19"}}
...

kubectl logs -n gatekeeper-system -l gatekeeper.sh/operation=webhook | tail
{"level":"info","ts":1697720241.6568787,"logger":"setup","msg":"setting up upgrade"}
{"level":"info","ts":1697720241.6573098,"logger":"setup","msg":"setting up metrics"}
{"level":"info","ts":1697720241.6573927,"logger":"controller","msg":"Starting Upgrade Manager","metaKind":"upgrade"}
{"level":"info","ts":1697720241.657528,"logger":"metrics","msg":"Starting metrics runner"}
{"level":"info","ts":1697720241.7332528,"msg":"Starting workers","controller":"config-controller","worker count":1}
{"level":"info","ts":1697720241.7344706,"msg":"Starting workers","controller":"constrainttemplate-controller","worker count":1}
{"level":"info","ts":1697720244.133506,"logger":"readiness-tracker","msg":"readiness satisfied, no further collection"}
{"level":"info","ts":1697720245.2798822,"logger":"controller","msg":"resource","metaKind":"upgrade","kind":"ConstraintTemplate","group":"templates.gatekeeper.sh","version":"v1alpha1"}
{"level":"info","ts":1697720245.3084674,"logger":"controller","msg":"resource count","metaKind":"upgrade","count":0}
{"level":"info","ts":1697720253.764551,"logger":"controller","msg":"disabling readiness stats","kind":"Config"}
```

```
kubectl get constrainttemplates | grep k8sazure

kubectl describe constrainttemplates k8sazurev1blockdefault | grep azure-policy-definition-id
# kubectl describe k8sazurev1blockdefault | grep azure-policy-definition-id

Annotations:  azure-policy-definition-id-1: /providers/Microsoft.Authorization/policyDefinitions/9f061a12-e40d-4183-a00e-171812443373

kubectl get constraints | grep k8sazurev3hostnetworkingports
## OR kubectl get k8sazurev3hostnetworkingports

NAME         ENFORCEMENT-ACTION   TOTAL-VIOLATIONS
k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-4c4e07cda01a7867529e   dryrun               1
k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-b5bc9122579d45b0c57b   dryrun               1

kubectl describe k8sazurev3hostnetworkingports.constraints.gatekeeper.sh/azurepolicy-k8sazurev3hostnetworkingports-4c4e07cda01a7867529e
## OR kubectl describe k8sazurev3hostnetworkingports
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

```
az group delete -n $rgname -y --no-wait
```

- https://github.com/Azure/azure-policy/tree/master/built-in-policies/policyDefinitions/Azure%20Government/Kubernetes
- https://learn.microsoft.com/en-us/azure/aks/policy-reference
- https://learn.microsoft.com/en-us/azure/aks/use-azure-policy
- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/effects
- https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes: store.policy.core.windows.net
- https://learn.microsoft.com/en-us/azure/governance/policy/how-to/get-compliance-data#on-demand-evaluation-scan---azure-cli: az policy state trigger-scan -g $rg
- https://learn.microsoft.com/en-us/azure/governance/policy/troubleshoot/general#scenario-evaluation-details-arent-up-to-date: ~The assignment takes 5-15 minutes to take effect.
