## k8s-role

```
kubectl delete rolebinding roleb
kubectl delete role role
kubectl create role role --verb=get,list --resource=namespaces
kubectl create rolebinding roleb --role=role
kubectl auth can-i get ns --as=system:serviceaccount:default:default # yes
kubectl auth can-i get po --as=system:serviceaccount:default:default # no
```

- https://kubernetes.io/docs/reference/access-authn-authz/rbac/
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-role

## k8s-role.aks

- https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac
- https://github.com/Azure/AKS/issues/2283: Add RBAC actions for cluster start stop
