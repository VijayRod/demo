```
kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "linux"}}}' # Forbidden to update this field for an existing pod
```

- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
