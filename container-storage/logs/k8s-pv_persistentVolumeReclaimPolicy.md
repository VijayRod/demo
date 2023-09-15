```
kubectl patch pv pvName -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistent-volumes: persistentVolumeReclaimPolicy
- https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/
