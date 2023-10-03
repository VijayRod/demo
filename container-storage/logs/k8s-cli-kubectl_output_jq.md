```
kubectl run nginx --image=nginx
kubectl get pods -o json | jq -r '.items[] | select(.metadata.name | test("nginx")).metadata.name'
```
