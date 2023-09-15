```
kubectl patch pv pvName -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

- https://learn.microsoft.com/en-us/azure/aks/csi-migrate-in-tree-volumes#create-a-static-volume
