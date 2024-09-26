```
kubectl delete clusterrolebinding crb
kubectl delete clusterrole cr
kubectl create clusterrole cr --verb=get,list --resource=namespaces
kubectl create clusterrolebinding crb --clusterrole=cr --serviceaccount=default:default
kubectl auth can-i get ns --as=system:serviceaccount:default:default # yes
kubectl auth can-i list ns --as=system:serviceaccount:default:default # yes
```

- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-clusterrole
