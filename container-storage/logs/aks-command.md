```
az aks command invoke -g rg -n aks -c "kubectl get no"
NAME                                STATUS   ROLES   AGE    VERSION
aks-nodepool1-16524978-vmss000000   Ready    agent   4d4h   v1.26.6
aks-nodepool1-16524978-vmss000001   Ready    agent   20h    v1.26.6
```

```
az aks command result -g rg -n aks -i 0e5b8dda5bd1429397524345fca40119
command started at 2023-09-19 22:09:19+00:00, finished at 2023-09-19 22:09:19+00:00 with exitcode=0
NAME                                STATUS   ROLES   AGE    VERSION
aks-nodepool1-16524978-vmss000000   Ready    agent   4d4h   v1.26.6
aks-nodepool1-16524978-vmss000001   Ready    agent   20h    v1.26.6

kubectl get po -n aks-command --show-labels
NAME                                       READY   STATUS      RESTARTS   AGE     LABELS
command-0e5b8dda5bd1429397524345fca40119   0/1     Completed   0          2m26s   createdBy=userredacted_domainredacted.com

kubectl logs -n aks-command command-0e5b8dda5bd1429397524345fca40119
kubectl logs -n aks-command -l createdBy=userredacted_domainredacted.com
NAME                                STATUS   ROLES   AGE    VERSION
aks-nodepool1-16524978-vmss000000   Ready    agent   4d4h   v1.26.6
aks-nodepool1-16524978-vmss000001   Ready    agent   20h    v1.26.6

kubectl describe po -n aks-command command-0e5b8dda5bd1429397524345fca40119
Name:             command-0e5b8dda5bd1429397524345fca40119
Namespace:        aks-command
Priority:         0
Service Account:  sa-0e5b8dda5bd1429397524345fca40119
Labels:           createdBy=userredacted_domainredacted.com
Annotations:      aks.azure.com/runCommand: true
Status:           Succeeded
Containers:
  user-command:
    Container ID:  containerd://5489ba17727e55f8cd5ce8e60ff27e9b5a540831e6ac0f2d24fd5439e52c0f47
    Image:         mcr.microsoft.com/aks/command/runtime:master.230109.1
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/resolve-az-aks-command-invoke-failures: When you run the az aks command invoke command, Azure CLI automatically creates a command-<ID> pod in the aks-command namespace to access the AKS cluster and retrieve the required information.
- https://learn.microsoft.com/en-us/azure/aks/access-private-cluster#run-commands-on-your-aks-cluster
- https://learn.microsoft.com/en-us/cli/azure/aks/command
