```
kubectl edit pv # Increase the size mentioned in spec.capacity.storage (instead of in the PVC)
```

```
kubectl get pv,pvc # There is a mismatch between the PV size, which is now 11 Gi, and the PVC size, which is still 10Gi
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
persistentvolume/pvc-e7f2d8c0-38a8-454d-aabe-515b22ec9938   11Gi       RWO            Delete           Bound    default/pvc-azuredisk   default                 4m27s
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/pvc-azuredisk   Bound    pvc-e7f2d8c0-38a8-454d-aabe-515b22ec9938   10Gi       RWO
default        4m31s

kubectl describe po | tail
  Warning  VolumeResizeFailed      <invalid> (x8 over <invalid>)  kubelet                  NodeExpandVolume.NodeExpandVolume failed for volume "pvc-e7f2d8c0-38a8-454d-aabe-515b22ec9938" : Expander.NodeExpand failed to expand the volume : rpc error: code = Internal desc = resize requested for 11, but after resizing volume size was 10
```
  
- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#resize-a-persistent-volume-without-downtime: Edit the PVC (not PV) object, and specify a larger size.
