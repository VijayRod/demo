## pdb

```
kubectl delete deploy nginx
kubectl create deploy nginx --image=nginx
kubectl scale deploy nginx --replicas 10
kubectl get deploy -w
kubectl get po -l app=nginx

kubectl create pdb nginx-pdb --selector=app=nginx --min-available=50%
kubectl get pdb

NAME        MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
nginx-pdb   50%             N/A               5                     4s

kubectl describe pdb
Name:           nginx-pdb
Namespace:      default
Min available:  50%
Selector:       app=nginx
Status:
    Allowed disruptions:  5
    Current:              10
    Desired:              5
    Total:                10
Events:                   <none>
```

- https://kubernetes.io/docs/concepts/workloads/pods/disruptions/
- https://kubernetes.io/docs/tasks/run-application/configure-pdb/
- https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_poddisruptionbudget/
- https://learn.microsoft.com/en-us/azure/aks/best-practices-app-cluster-reliability#pod-disruption-budgets-pdbs
