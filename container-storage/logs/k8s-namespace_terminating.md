```
kubectl delete namespace namespace_to_delete –force ## TBD does not work with finalizers
kubectl patch ns namespace_to_delete -p '{"metadata":{"finalizers":null}}'
```
