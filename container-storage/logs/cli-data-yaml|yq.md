> ## yaml..yq

```
# yaml.yq.k8s
kubectl get deploy webapp -n default -o yaml | yq '.metadata.uid'
```
