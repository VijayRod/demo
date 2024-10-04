## k8s-pvc

```
kubectl api-resources | grep pv
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
persistentvolumeclaims              pvc                 v1                                     true         PersistentVolumeClaim
persistentvolumes                   pv                  v1                                     false        PersistentVolume
```

## k8s-pvc.status.bound aka binding

```
storageclass.volumeBindingMode
```
