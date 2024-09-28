## k8s-role

```
kubectl delete rolebinding roleb
kubectl delete role role
kubectl create role role --verb=get,list --resource=namespaces
kubectl create rolebinding roleb --role=role
kubectl auth can-i get ns --as=system:serviceaccount:default:default # yes
kubectl auth can-i get po --as=system:serviceaccount:default:default # no
```

```
cat << EOF | kubectl create -f -
# Define a Role that allows for the management of pods within a specific namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-manager
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/exec"]
  verbs: ["get", "list", "watch", "create", "delete", "patch"]
---
# Bind the Role to the namespaces's default service account
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: default
  name: pod-manager-rolebinding
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role
  name: pod-manager
  apiGroup: rbac.authorization.k8s.io
EOF
kubectl get role
kubectl get rolebinding

NAME          CREATED AT
pod-manager   2024-09-28T20:19:42Z
NAME                      ROLE               AGE
pod-manager-rolebinding   Role/pod-manager   65s
```

- https://kubernetes.io/docs/reference/access-authn-authz/rbac/
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/#kubectl-create-role

## k8s-role.aks

- https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac
- https://github.com/Azure/AKS/issues/2283: Add RBAC actions for cluster start stop
