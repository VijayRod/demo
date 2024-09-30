```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get crd
NAME                                             CREATED AT
volumesnapshotclasses.snapshot.storage.k8s.io    2024-09-29T19:59:22Z
volumesnapshotcontents.snapshot.storage.k8s.io   2024-09-29T19:59:22Z
volumesnapshots.snapshot.storage.k8s.io          2024-09-29T19:59:22Z

kubectl api-resources | grep snapshot
volumesnapshotclasses               vsclass,vsclasses   snapshot.storage.k8s.io/v1             false        VolumeSnapshotClass
volumesnapshotcontents              vsc,vscs            snapshot.storage.k8s.io/v1             false        VolumeSnapshotContent
volumesnapshots                     vs                  snapshot.storage.k8s.io/v1             true         VolumeSnapshot

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/storageclass-azuredisk-snapshot.yaml
kubectl get volumesnapshotclass
NAME                DRIVER               DELETIONPOLICY   AGE
csi-azuredisk-vsc   disk.csi.azure.com   Delete           11s
```

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml
sleep 20
kubectl exec nginx-azuredisk -- touch /mnt/azuredisk/test.txt
kubectl exec nginx-azuredisk -- ls /mnt/azuredisk

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/azuredisk-volume-snapshot.yaml
kubectl describe volumesnapshot
Name:         azuredisk-volume-snapshot
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  snapshot.storage.k8s.io/v1
Kind:         VolumeSnapshot
Metadata:
  Creation Timestamp:  2023-09-01T19:42:13Z
  Finalizers:
    snapshot.storage.kubernetes.io/volumesnapshot-as-source-protection
    snapshot.storage.kubernetes.io/volumesnapshot-bound-protection
  Generation:        1
  Resource Version:  4107
  UID:               2718ec2c-1ce4-48a3-8bb3-48240e38f9f8
Spec:
  Source:
    Persistent Volume Claim Name:  pvc-azuredisk
  Volume Snapshot Class Name:      csi-azuredisk-vsc
Status:
  Bound Volume Snapshot Content Name:  snapcontent-2718ec2c-1ce4-48a3-8bb3-48240e38f9f8
  Creation Time:                       2023-09-01T19:42:14Z
  Ready To Use:                        true
  Restore Size:                        10Gi

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/pvc-azuredisk-snapshot-restored.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/nginx-pod-restored-snapshot.yaml
sleep 20
kubectl exec nginx-restored -- ls /mnt/azuredisk

lost+found
outfile
test.txt
```

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/driver-parameters.md#volumesnapshotclass
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/tree/master/deploy/example/snapshot
- https://kubernetes.io/docs/concepts/storage/volume-snapshots/
- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#volume-snapshots
