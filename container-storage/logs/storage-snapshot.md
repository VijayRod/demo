## storage.snapshot.disk

```
# https://learn.microsoft.com/en-us/azure/virtual-machines/disks-incremental-snapshots?tabs=azure-cli#create-incremental-snapshots
az snapshot create 
```

- https://aka.ms/snapshot-status
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-incremental-snapshots?tabs=azure-cli#check-status-of-snapshots-or-disks

## storage.snapshot.k8s.volumesnapshot

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing

k api-resources | grep snap
volumesnapshotclasses               vsclass,vsclasses   snapshot.storage.k8s.io/v1             false        VolumeSnapshotClass
volumesnapshotcontents              vsc,vscs            snapshot.storage.k8s.io/v1             false        VolumeSnapshotContent
volumesnapshots                     vs                  snapshot.storage.k8s.io/v1             true         VolumeSnapshot

k get crd | grep snap
volumesnapshotclasses.snapshot.storage.k8s.io    2024-11-08T20:43:10Z
volumesnapshotcontents.snapshot.storage.k8s.io   2024-11-08T20:43:10Z
volumesnapshots.snapshot.storage.k8s.io          2024-11-08T20:43:10Z
k describe crd volumesnapshotclasses.snapshot.storage.k8s.io
k describe crd volumesnapshotcontents.snapshot.storage.k8s.io
k describe crd volumesnapshots.snapshot.storage.k8s.io

k get vsclass # no results
```

- https://kubernetes.io/docs/concepts/storage/volume-snapshots/: A VolumeSnapshot is a request for snapshot of a volume by a user. It is similar to a PersistentVolumeClaim.
- https://www.alibabacloud.com/help/en/ack/ack-managed-and-ack-dedicated/user-guide/use-volume-snapshots-created-from-disks
- https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/volume-snapshots

## storage.snapshot.k8s.volumesnapshot.debug.error.SnapshotContentCreationFailed.cannot get claim from snapshot

```
# Creating a volume snapshot without a prior claim (PVC) results in an error. You can confirm this by executing `kubectl get pvc`. 
# Once the claim is created, the process automatically progresses to the CreatingSnapshot phase in volume snapshot events.
k describe vs azuredisk-volume-snapshot
Name:         azuredisk-volume-snapshot
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  snapshot.storage.k8s.io/v1
Kind:         VolumeSnapshot
Metadata:
  Creation Timestamp:  2024-11-08T20:36:00Z
  Finalizers:
    snapshot.storage.kubernetes.io/volumesnapshot-as-source-protection
  Generation:        1
  Resource Version:  133919
  UID:               155be88d-feea-48c3-8cb2-2581e5fdeec2
Spec:
  Source:
    Persistent Volume Claim Name:  pvc-azuredisk
  Volume Snapshot Class Name:      csi-azuredisk-vsc
Status:
  Error:
    Message:     Failed to create snapshot content with error snapshot controller failed to update azuredisk-volume-snapshot on API server: cannot get claim from snapshot
    Time:        2024-11-08T20:36:00Z
  Ready To Use:  false
Events:
  Type     Reason                         Age   From                 Message
  ----     ------                         ----  ----                 -------
  Warning  SnapshotContentCreationFailed  45s   snapshot-controller  Failed to create snapshot content with error snapshot controller failed to update azuredisk-volume-snapshot on API server: cannot get claim from snapshot
```

## storage.snapshot.k8s.volumesnapshot.volumesnapshotclass

- https://kubernetes.io/docs/concepts/storage/volume-snapshot-classes/

## storage.snapshot.k8s.volumesnapshot.volumesnapshotclass.driver.azuredisk

```
# https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#create-a-volume-snapshot
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/storageclass-azuredisk-snapshot.yaml
k delete vsclass csi-azuredisk-vsc
cat << EOF | kubectl create -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: csi-azuredisk-vsc
driver: disk.csi.azure.com
deletionPolicy: Delete
parameters:
  incremental: "true"  # available values: "true", "false" ("true" by default for Azure Public Cloud, and "false" by default for Azure Stack Cloud)
EOF
k get vsclass

NAME                DRIVER               DELETIONPOLICY   AGE
csi-azuredisk-vsc   disk.csi.azure.com   Delete           0s

# https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#dynamically-create-azure-disks-pvs-by-using-the-built-in-storage-classes
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/pvc-azuredisk-csi.yaml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/nginx-pod-azuredisk.yaml
k delete po nginx-azuredisk
k delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  storageClassName: managed-csi
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: nginx
      name: nginx-azuredisk
      command:
        - "/bin/sh"
        - "-c"
        - while true; do echo $(date) >> /mnt/azuredisk/outfile; sleep 1; done
      volumeMounts:
        - name: azuredisk01
          mountPath: "/mnt/azuredisk"
          readOnly: false
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 20
k get po,pvc
kubectl exec nginx-azuredisk -- touch /mnt/azuredisk/test.txt
kubectl exec nginx-azuredisk -- ls /mnt/azuredisk

# A VolumeSnapshot create transitions it to CreatingSnapshot as indicates by its events
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/azuredisk-volume-snapshot.yaml
k delete vs azuredisk-volume-snapshot
cat << EOF | kubectl create -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: azuredisk-volume-snapshot
spec:
  volumeSnapshotClassName: csi-azuredisk-vsc
  source:
    persistentVolumeClaimName: pvc-azuredisk
EOF
k get vs
k describe vs azuredisk-volume-snapshot # Ready To Use (readyToUse)

NAME                        READYTOUSE   SOURCEPVC       SOURCESNAPSHOTCONTENT   RESTORESIZE   SNAPSHOTCLASS       SNAPSHOTCONTENT   CREATIONTIME   AGE
azuredisk-volume-snapshot   false        pvc-azuredisk                                         csi-azuredisk-vsc                                    0s

Name:         azuredisk-volume-snapshot
Namespace:    default
Labels:       <none>
Annotations:  <none>
API Version:  snapshot.storage.k8s.io/v1
Kind:         VolumeSnapshot
Metadata:
  Creation Timestamp:  2024-11-08T20:36:00Z
  Finalizers:
    snapshot.storage.kubernetes.io/volumesnapshot-as-source-protection
    snapshot.storage.kubernetes.io/volumesnapshot-bound-protection
  Generation:        1
  Resource Version:  134915
  UID:               155be88d-feea-48c3-8cb2-2581e5fdeec2
Spec:
  Source:
    Persistent Volume Claim Name:  pvc-azuredisk
  Volume Snapshot Class Name:      csi-azuredisk-vsc
Status:
  Bound Volume Snapshot Content Name:  snapcontent-155be88d-feea-48c3-8cb2-2581e5fdeec2
  Creation Time:                       2024-11-08T20:40:10Z
  Ready To Use:                        true
  Restore Size:                        10Gi
Events:
  Type     Reason                         Age    From                 Message
  ----     ------                         ----   ----                 -------
  Normal   CreatingSnapshot               20s    snapshot-controller  Waiting for a snapshot default/azuredisk-volume-snapshot to be created by the CSI driver.
  Normal   SnapshotCreated                16s    snapshot-controller  Snapshot default/azuredisk-volume-snapshot was successfully created by the CSI driver.
  Normal   SnapshotReady                  16s    snapshot-controller  Snapshot default/azuredisk-volume-snapshot is ready to use.

k get vsc
NAME                                               READYTOUSE   RESTORESIZE   DELETIONPOLICY   DRIVER		VOLUMESNAPSHOTCLASS   VOLUMESNAPSHOT              VOLUMESNAPSHOTNAMESPACE   AGE
snapcontent-155be88d-feea-48c3-8cb2-2581e5fdeec2   true         10737418240   Delete           disk.csi.azure.com   csi-azuredisk-vsc     azuredisk-volume-snapshot   default                   2m35s

k describe vsc
Name:         snapcontent-155be88d-feea-48c3-8cb2-2581e5fdeec2
Namespace:
Labels:       <none>
Annotations:  <none>
API Version:  snapshot.storage.k8s.io/v1
Kind:         VolumeSnapshotContent
Metadata:
  Creation Timestamp:  2024-11-08T20:40:09Z
  Finalizers:
    snapshot.storage.kubernetes.io/volumesnapshotcontent-bound-protection
  Generation:        1
  Resource Version:  134913
  UID:               f0de56a9-3e14-4c16-a81f-f21cee0696fe
Spec:
  Deletion Policy:  Delete
  Driver:           disk.csi.azure.com
  Source:
    Volume Handle:             /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-75f5188a-643f-4832-a4de-2259ca2e278a
  Volume Snapshot Class Name:  csi-azuredisk-vsc
  Volume Snapshot Ref:
    API Version:       snapshot.storage.k8s.io/v1
    Kind:              VolumeSnapshot
    Name:              azuredisk-volume-snapshot
    Namespace:         default
    Resource Version:  133919
    UID:               155be88d-feea-48c3-8cb2-2581e5fdeec2
Status:
  Creation Time:    1731098410363884700
  Ready To Use:     true
  Restore Size:     10737418240
  Snapshot Handle:  /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/snapshots/snapshot-155be88d-feea-48c3-8cb2-2581e5fdeec2
Events:             <none>

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az resource list -g $noderg -otable
Name                                           ResourceGroup            Location       Type                     Status
---------------------------------------------  -----------------------  -------------  ------------------------------------------------  --------
pvc-75f5188a-643f-4832-a4de-2259ca2e278a       mc_rg_aks_swedencentral  swedencentral  Microsoft.Compute/disks
snapshot-155be88d-feea-48c3-8cb2-2581e5fdeec2  mc_rg_aks_swedencentral  swedencentral  Microsoft.Compute/snapshots

az snapshot list -g $noderg
[
  {
    "creationData": {
      "createOption": "Copy",
      "sourceResourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-75f5188a-643f-4832-a4de-2259ca2e278a",
      "sourceUniqueId": "5c7c7c72-4676-4b61-80c4-f7c1869a1188"
    },
    "diskSizeBytes": 10737418240,
    "diskSizeGB": 10,
    "diskState": "Unattached",
    "encryption": {
      "type": "EncryptionAtRestWithPlatformKey"
    },
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/snapshots/snapshot-155be88d-feea-48c3-8cb2-2581e5fdeec2",
    "incremental": true,
    "location": "swedencentral",
    "name": "snapshot-155be88d-feea-48c3-8cb2-2581e5fdeec2",
    "networkAccessPolicy": "AllowAll",
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Enabled",
    "resourceGroup": "MC_rg_aks_swedencentral",
    "sku": {
      "name": "Standard_ZRS",
      "tier": "Standard"
    },
    "tags": {},
    "timeCreated": "2024-11-08T20:40:10.3638847+00:00",
    "type": "Microsoft.Compute/snapshots",
    "uniqueId": "2e482c56-d142-4ede-a721-7eead9d6ce85"
  }
]

# https://github.com/Azure/AKS/issues/4555#issuecomment-2363727248
# csi-azuredisk-controller # ready_to_use, completionPercent
I0920 13:02:19.920424       1 azure_metrics.go:115] "Observed Request Latency" latency_seconds=477.629872031 request="azuredisk_csi_driver_controller_create_snapshot" resource_group="prod-us1-nodepool" subscription_id="<SUBSCRIPTION-ID>" source="disk.csi.azure.com" source_resource_id="/subscriptions/<SUBSCRIPTION-ID>/resourceGroups/prod-us1-nodepool/providers/Microsoft.Compute/disks/pvc-6b10115b-4b15-4ec7-b44f-a1522e72947b" snapshot_name="snapshot-70caa786-efed-4f49-8737-95620c584619" result_code="succeeded"
I0920 13:02:19.920471       1 utils.go:84] GRPC response: {"snapshot":{"creation_time":{"nanos":573020200,"seconds":1726836862},"ready_to_use":true,"size_bytes":1073741824,"snapshot_id":"/subscriptions/<SUBSCRIPTION-ID>/resourceGroups/prod-us1-nodepool/providers/Microsoft.Compute/snapshots/snapshot-70caa786-efed-4f49-8737-95620c584619","source_volume_id":"/subscriptions/<SUBSCRIPTION-ID>/resourceGroups/prod-us1-nodepool/providers/Microsoft.Compute/disks/pvc-6b10115b-4b15-4ec7-b44f-a1522e72947b"}}
I0920 13:02:14.937073       1 azuredisk.go:496] snapshot(snapshot-70caa786-efed-4f49-8737-95620c584619) under rg(prod-us1-nodepool) completionPercent: 0.000000
I0920 13:02:19.865503       1 azuredisk.go:493] snapshot(snapshot-70caa786-efed-4f49-8737-95620c584619) under rg(prod-us1-nodepool) complete
I0920 13:02:19.865534       1 controllerserver.go:1003] create snapshot(snapshot-70caa786-efed-4f49-8737-95620c584619) under rg(prod-us1-nodepool) region(eastus) successfully
...
```

- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#volume-snapshots
- https://github.com/Azure/AKS/issues/4555#issuecomment-2407400415: we should always waiting for snapshot creation ready, otherwise though the snapshot is in state readToUse, it's actually not usable.
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/tree/master/deploy/example/snapshot
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/driver-parameters.md#volumesnapshotclass

## storage.snapshot.k8s.volumesnapshot.volumesnapshotclass.driver.azuredisk.restore

```
# https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#create-a-new-pvc-based-on-a-volume-snapshot
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/pvc-azuredisk-snapshot-restored.yaml
# kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/snapshot/nginx-pod-restored-snapshot.yaml
kubectl delete pvc pvc-azuredisk-snapshot-restored
kubectl delete po nginx-restored
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk-snapshot-restored
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-csi
  resources:
    requests:
      storage: 10Gi
  dataSource:
    name: azuredisk-volume-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-restored
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: nginx
      name: nginx-restored
      args:
        - sleep
        - "3600"
      volumeMounts:
        - name: azuredisk01
          mountPath: "/mnt/azuredisk"
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk-snapshot-restored
EOF
sleep 20
kubectl exec nginx-restored -- ls /mnt/azuredisk

lost+found
outfile
test.txt
```

## storage.snapshot.k8s.volumesnapshot.volumesnapshotclass.driver.azuredisk.app.azurebackup

- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-backup-overview: The Backup Extension installed in the AKS cluster first takes the backup by taking Volume snapshots via CSI Driver
- https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-cluster-backup-support-matrix#limitations (snapshot)

## storage.snapshot.k8s.volumesnapshot.volumesnapshotclass.driver.containerstorage(acstor)

- https://learn.microsoft.com/en-us/azure/storage/container-storage/volume-snapshot-restore
