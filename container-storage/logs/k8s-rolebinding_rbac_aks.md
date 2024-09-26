```
kubectl api-resources # To identify valid values for the --resource flag when creating roles or cluster roles with kubectl create role or clusterrole
kubectl get role -A
kubectl get clusterrole -A
kubectl get sa -A
kubectl get rolebinding,clusterrolebinding -A
kubectl auth can-i list pod # yes
```

- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#command-line-utilities
