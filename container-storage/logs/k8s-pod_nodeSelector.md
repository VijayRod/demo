```
kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "linux"}}}' # Forbidden to update this field for an existing pod

kubectl delete po nginx
kubectl run nginx --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-38494683-vmss000000"}}}'
kubectl expose po nginx
```

- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
