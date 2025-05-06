## pv

```
# See the section on PV provision and device LUN

kubectl api-resources | grep pv
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
persistentvolumeclaims              pvc                 v1                                     true         PersistentVolumeClaim
persistentvolumes                   pv                  v1                                     false        PersistentVolume
```
  
- https://kubernetes.io/docs/concepts/storage/volumes/#persistentvolumeclaim
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#volume-v1-core
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#volumes
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#persistent-volumes
- https://github.com/container-storage-interface/spec/blob/master/spec.md#createvolume

## pv.op.create

```
# dynamic vs static PV
# For PV, you can usually tell the difference by looking at the Name (due to the pvc-GUID), Annotations, Finalizers and VolumeAttributes
# For PVC, the Volume (name) (again, due to not having the pvc-GUID) and Annotations are the key indicators

kubectl describe pv
# dynamic
Name:              pvc-c50aa0c5-53e6-4769-b992-b8777a22f85d
Labels:            <none>
Annotations:       pv.kubernetes.io/provisioned-by: disk.csi.azure.com
                   volume.kubernetes.io/provisioner-deletion-secret-name:
                   volume.kubernetes.io/provisioner-deletion-secret-namespace:
Finalizers:        [external-provisioner.volume.kubernetes.io/finalizer kubernetes.io/pv-protection external-attacher/disk-csi-azure-com]
(not reliable to identify) StorageClass:      default
(not reliable to identify) Claim:             default/pvc-azuredisk
Node Affinity:
  Required Terms:
    Term 0:        topology.disk.csi.azure.com/zone in []
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            disk.csi.azure.com
    FSType:
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-c50aa0c5-53e6-4769-b992-b8777a22f85d
    ReadOnly:          false
    VolumeAttributes:      csi.storage.k8s.io/pv/name=pvc-c50aa0c5-53e6-4769-b992-b8777a22f85d
                           csi.storage.k8s.io/pvc/name=pvc-azuredisk
                           csi.storage.k8s.io/pvc/namespace=default
                           requestedsizegib=10
                           skuname=StandardSSD_LRS
                           storage.kubernetes.io/csiProvisionerIdentity=1739442690824-8205-disk.csi.azure.com    
# static
Name:            pv-azuredisk2
Labels:          <none>
Annotations:     pv.kubernetes.io/bound-by-controller: yes
                 pv.kubernetes.io/provisioned-by: disk.csi.azure.com
Finalizers:      [kubernetes.io/pv-protection]
(not reliable to identify) StorageClass:    default
(not reliable to identify) Claim:             default/pvc-azuredisk
Node Affinity:   <none>
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            disk.csi.azure.com
    FSType:
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/disks/disk
    ReadOnly:          false
    VolumeAttributes:      fsType=ext4
    
kubectl describe pvc
# dynamic
(not reliable to identify) Name:          pvc-azuredisk
(not reliable to identify) Namespace:     default
(not reliable to identify) StorageClass:  default
(not reliable to identify) Status:        Bound
Volume:        pvc-c50aa0c5-53e6-4769-b992-b8777a22f85d
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: disk.csi.azure.com
               volume.kubernetes.io/selected-node: aks-nodepool1-24567707-vmss000001
               volume.kubernetes.io/storage-provisioner: disk.csi.azure.com
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      10Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       nginx-azuredisk
Events:
# static
(not reliable to identify) Name:          pvc-azuredisk2
(not reliable to identify) Namespace:     default
(not reliable to identify) StorageClass:  default
(not reliable to identify) Status:        Pending
Volume:        pv-azuredisk2
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      0
Access Modes:
VolumeMode:    Filesystem
Used By:       <none>
Events:        <none>
```

```
# dynamic

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
  storageClassName: default
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
        - name: azuredisk01
          mountPath: "/mnt/azuredisk"
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get po,pv,pvc
# kubectl delete po nginx-azuredisk; kubectl delete pvc pvc-azuredisk
```

```
# static.pv
# **Since the (static) PV is created by the user, the storage class settings won't apply to it. However, if it's a dynamically provisioned PV, then the settings in the storage class will take effect.

# az disk delete -g MC_rg_aks_swedencentral -n disk
az disk create -g MC_rg_aks_swedencentral -n disk --size-gb 20 --query id --output tsv
diskId=$(az disk show -g MC_rg_aks_swedencentral -n disk --query id -otsv)
kubectl delete pv pv-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: disk.csi.azure.com
  name: pv-azuredisk
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: managed-csi
  csi:
    driver: disk.csi.azure.com
    volumeHandle: $diskId
    volumeAttributes:
      fsType: ext4
EOF
kubectl get pv
kubectl delete pvc pvc-azuredisk
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
      storage: 20Gi
  volumeName: pv-azuredisk
  storageClassName: managed-csi
EOF
kubectl get pvc

kubectl get pv -w
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS    CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-azuredisk   20Gi       RWO            Retain           Pending               managed-csi    <unset>            0s
pv-azuredisk   20Gi       RWO            Retain           Available             managed-csi    <unset>            0s
pv-azuredisk   20Gi       RWO            Retain           Available     default/pvc-azuredisk   managed-csi    <unset>                          14s
pv-azuredisk   20Gi       RWO            Retain           Bound         default/pvc-azuredisk   managed-csi    <unset>                          14s
kubectl get pvc -w
NAME            STATUS    VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-azuredisk   Pending       pv-azuredisk   0                         managed-csi    <unset>                 0s
pvc-azuredisk   Bound         pv-azuredisk   20Gi       RWO            managed-csi    <unset>                 15s
```

```
# static pv without a defined storage class means that a storage class is not used, and the mount uses the driver from the node
# It is using the k8s NFS plugin instead of the Azure CSI driver.

Name:            pv-irsvxttn
Labels:          pv-name=pv-jrjmmtlo
                 pvc-namespace-name=cbueitcp
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    
Status:          Bound
Claim:           dyqxgmkg/gepabinu
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        1Ti
Node Affinity:   <none>
Message:         
Source:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    96.71.156.142
    Path:      /export/mlojprwe
    ReadOnly:  false
Events:        <none>
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#statically-provision-a-volume
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#static



## pv.op.delete

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection: If a user deletes a PVC in active use by a Pod, the PVC is not removed immediately. PVC removal is postponed until the PVC is no longer actively used by any Pods. Also, if an admin deletes a PV that is bound to a PVC, the PV is not removed immediately. PV removal is postponed until the PV is no longer bound to a PVC.
You can see that a PVC is protected when the PVC's status is Terminating and the Finalizers list includes kubernetes.io/pvc-protection
You can see that a PV is protected when the PV's status is Terminating and the Finalizers list includes kubernetes.io/pv-protection too

```
# pv.delete.bound_pv.delete_pv
# pv is stuck in a Terminating state, and the pod can continue writing to the volume
# delete the po and pvc to remove this PV.

kubectl get po,pv,pvc
NAME                  READY   STATUS    RESTARTS   AGE
pod/nginx-azuredisk   1/1     Running   0          30s
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS        VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-02f76403-276c-4c3b-afd4-eb5427153c3e   10Gi       RWO            Delete           Bound    default/pvc-azuredisk       managed-csi         <unset>                          28s
NAME                                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-azuredisk       Bound    pvc-02f76403-276c-4c3b-afd4-eb5427153c3e   10Gi       RWO            managed-csi         <unset>                 32s

k delete pv pvc-02f76403-276c-4c3b-afd4-eb5427153c3e
persistentvolume "pvc-02f76403-276c-4c3b-afd4-eb5427153c3e" deleted
^C

kubectl get po,pv,pvc
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS        CLAIM                       STORAGECLASS        VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-02f76403-276c-4c3b-afd4-eb5427153c3e   10Gi       RWO            Delete           Terminating   default/pvc-azuredisk       managed-csi         <unset>                          90s
NAME                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS        VOLUMEATTRIBUTESCLASS   AGE
pvc-azuredisk       Bound    pvc-02f76403-276c-4c3b-afd4-eb5427153c3e   10Gi       RWO            managed-csi         <unset>                 2m33s

k exec -it nginx-azuredisk -- touch /mnt/azuredisk/testfile
k exec -it nginx-azuredisk -- ls /mnt/azuredisk # lost+found  outfile  testfile
```

```
# pod is in a pending state with FailedAttachVolume PersistentVolume "is marked for deletion"
# This issue can occur after an earlier PV delete attempt where the pod remains in the Running state. However, after a cluster upgrade and the restore from etcd, or for static PVs or stateful pods, the PV stays the same in these cases
 Warning  FailedAttachVolume  204s (x11 over 25m)  attachdetach-controller  AttachVolume.Attach failed for volume "pvc-11111" : PersistentVolume "pvc-11111" is marked for deletion
```

```
# pv.delete.bound_pv.delete_pvc
# pvc is stuck in Terminating state
# delete the po to delete this PV.

kubectl get po,pv,pvc
NAME                  READY   STATUS    RESTARTS   AGE
pod/nginx-azuredisk   1/1     Running   0          30s
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-71859231-bc2f-4506-86aa-32c8241e7338   10Gi       RWO            Delete           Bound    default/pvc-azuredisk   managed-csi    <unset>                          27s
NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-azuredisk   Bound    pvc-71859231-bc2f-4506-86aa-32c8241e7338   10Gi       RWO            managed-csi    <unset>                 31s

k delete pvc pvc-azuredisk
persistentvolumeclaim "pvc-azuredisk" deleted
^C

k get po,pv,pvc
NAME                  READY   STATUS    RESTARTS   AGE
pod/nginx-azuredisk   1/1     Running   0          56s
NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-71859231-bc2f-4506-86aa-32c8241e7338   10Gi       RWO            Delete           Bound    default/pvc-azuredisk   managed-csi    <unset>                          53s
NAME                                  STATUS        VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-azuredisk   Terminating   pvc-71859231-bc2f-4506-86aa-32c8241e7338   10Gi       RWO            managed-csi    <unset>                 57s
```

## pv.reclaimPolicy (persistentVolumeReclaimPolicy)

```
kubectl describe pv task-pv-volume
Reclaim Policy:  Delete
```

```
kubectl patch pv pv-azuredisk -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}' # persistentvolume/pv-azuredisk patched
kubectl get pv pv-azuredisk -oyaml | grep Reclaim # Delete
```

- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection: volumes can either be Retained, Recycled, or Deleted.
```
# persistentVolumeReclaimPolicy.delete.pv-protection-controller
# user agent: pv-protection-controller

kubectl describe pv pv-azuredisk # same for both static and dynamic provisioned PVs
Finalizers:      [kubernetes.io/pv-protection external-provisioner.volume.kubernetes.io/finalizer]
```

- https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#storageobjectinuseprotection: adds the kubernetes.io/pvc-protection or kubernetes.io/pv-protection finalizers to newly created Persistent Volume Claims (PVCs) or Persistent Volumes (PV). In case a user deletes a PVC or PV the PVC or PV is not removed until the finalizer is removed from the PVC or PV by PVC or PV Protection Controller.
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/#storage-object-in-use-protection
- https://github.com/kubernetes/kubernetes/blob/master/pkg/controller/volume/pvprotection/pv_protection_controller.go
// Controller is controller that removes PVProtectionFinalizer
// from PVs that are not bound to PVCs.
	if protectionutil.IsDeletionCandidate(pv, volumeutil.PVProtectionFinalizer) {
		// PV should be deleted. Check if it's used and remove finalizer if
		// it's not.
		isUsed := c.isBeingUsed(pv)
		if !isUsed {
			return c.removeFinalizer(ctx, pv)
		}
		logger.V(4).Info("Keeping PV because it is being used", "PV", klog.KRef("", pvName))
	}

	if protectionutil.NeedToAddFinalizer(pv, volumeutil.PVProtectionFinalizer) {
		// PV is not being deleted -> it should have the finalizer. The
		// finalizer should be added by admission plugin, this is just to add
		// the finalizer to old PVs that were created before the admission
		// plugin was enabled.
		return c.addFinalizer(ctx, pv)

## pv.status

```
# pv.status.bound

storageclass.volumeBindingMode
```

## pv.volumeAttributes

- https://kubernetes.io/docs/concepts/storage/volumes/#csi: This map must correspond to the map returned in the volume.attributes field of the CreateVolumeResponse by the CSI driver. The map is passed to the CSI driver via the volume_context field in the ControllerPublishVolumeRequest, NodeStageVolumeRequest, and NodePublishVolumeRequest.
- https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.28/#volume-v1-core: volumeAttributes stores driver-specific properties that are passed to the CSI driver. Consult your driver's documentation for supported values.

## pv.volumeHandle

```
kubectl describe pv | grep VolumeHandle
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5

# volume_id in the GRPC request
kubectl get po -owide
kubectl get po -l app=csi-azuredisk-node -A -owide | grep vmss000000
kubectl logs -n kube-system csi-azuredisk-node-wf47f -c azuredisk | grep "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"
I0914 10:36:53.289446       1 utils.go:77] GRPC call: /csi.v1.Node/NodeStageVolume
I0914 10:36:53.289460       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/7b2dac0b72584296a1d72e2e430563c1633d58213579b6797adc1965848b646d/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-340084f0-9faa-41db-b09c-9e90f9165fd5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694687347267-1086-disk.csi.azure.com"},"volume_id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"}
I0914 10:36:55.796672       1 utils.go:77] GRPC call: /csi.v1.Node/NodePublishVolume
I0914 10:36:55.796684       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/7b2dac0b72584296a1d72e2e430563c1633d58213579b6797adc1965848b646d/globalmount","target_path":"/var/lib/kubelet/pods/8c896175-ee76-470c-bc0f-9dfe25a4cdd9/volumes/kubernetes.io~csi/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-340084f0-9faa-41db-b09c-9e90f9165fd5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694687347267-1086-disk.csi.azure.com"},"volume_id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"}
```

```
tbd

az disk delete -g MC_rg_aks_swedencentral -n disk
az disk delete -g MC_rg_aks_swedencentral -n disk2
az disk create -g MC_rg_aks_swedencentral -n disk --size-gb 20 --query id --output tsv
az disk create -g MC_rg_aks_swedencentral -n disk2 --size-gb 20 --query id --output tsv
diskId=$(az disk show -g MC_rg_aks_swedencentral -n disk --query id -otsv)
diskId2=$(az disk show -g MC_rg_aks_swedencentral -n disk2 --query id -otsv)
kubectl delete pvc pvc-azuredisk
kubectl delete pvc pvc-azuredisk2
kubectl delete pv pv-azuredisk
kubectl delete pv pv-azuredisk2
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: disk.csi.azure.com
  name: pv-azuredisk
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: managed-csi
  csi:
    driver: disk.csi.azure.com
    volumeHandle: pv-azuredisk # $diskId
    volumeAttributes:
      fsType: ext4
---
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: disk.csi.azure.com
  name: pv-azuredisk2
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: managed-csi
  csi:
    driver: disk.csi.azure.com
    volumeHandle: pv-azuredisk # $diskId2
    volumeAttributes:
      fsType: ext4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  volumeName: pv-azuredisk
  storageClassName: managed-csi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk2
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  volumeName: pv-azuredisk2
  storageClassName: managed-csi
EOF
kubectl get pvc
---
EOF

NAME             STATUS    VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-azuredisk    Bound     pv-azuredisk    20Gi       RWO            managed-csi    <unset>                 7s
pvc-azuredisk2   Bound    pv-azuredisk2   20Gi       RWO            managed-csi    <unset>                 44s
```

- https://kubernetes.io/docs/concepts/storage/volumes/: volumeHandle: A string value...
- https://kubernetes.io/docs/concepts/storage/persistent-volumes/: VolumeHandle:      44830fa8-79b4-406b-8b58-621ba25353fd
- https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/: volumeHandle: existingVolumeName
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/azurefile.go: get file share info according to volume id

## pv.volumeHandle.duplicate

Create two statically provisioned persistent volumes with the same volumeHandle disk resource URI, two persistent volume claims, and two pods in the same node, all with different names. Note that the volume handle must be unique; therefore, this configuration is unsupported.

```
kubectl patch pvc pvc-azuredisk4 -p '{"spec":{"resources":{"requests":{"storage":"21Gi"}}}}' --type=merge

kubectl get pv
NAME            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS        CLAIM                    STORAGECLASS   REASON   AGE
pv-azuredisk3   20Gi       RWO            Retain           Bound         default/pvc-azuredisk3   managed-csi             32m
pv-azuredisk4   22Gi       RWO            Retain           Bound         default/pvc-azuredisk4   managed-csi             32m

kubectl get po -A -owide | grep azuredisk | grep 000000
```

## pv.volumeHandle.error.volumeOperationAlreadyExists.azstorage

- https://github.com/Azure/azure-storage-fuse/blob/main/TSG.md#common-mount-problems: 3. failed to mount : failed to authenticate credentials for azstorage...
  
## pv.volumeHandle.volume_id

```
kubectl describe pv | grep VolumeHandle
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5

# volume_id in the GRPC request
kubectl get po -owide
kubectl get po -l app=csi-azuredisk-node -A -owide | grep vmss000000
kubectl logs -n kube-system csi-azuredisk-node-wf47f -c azuredisk | grep "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"
I0914 10:36:53.289446       1 utils.go:77] GRPC call: /csi.v1.Node/NodeStageVolume
I0914 10:36:53.289460       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/7b2dac0b72584296a1d72e2e430563c1633d58213579b6797adc1965848b646d/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-340084f0-9faa-41db-b09c-9e90f9165fd5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694687347267-1086-disk.csi.azure.com"},"volume_id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"}
I0914 10:36:55.796672       1 utils.go:77] GRPC call: /csi.v1.Node/NodePublishVolume
I0914 10:36:55.796684       1 utils.go:78] GRPC request: {"publish_context":{"LUN":"0"},"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/disk.csi.azure.com/7b2dac0b72584296a1d72e2e430563c1633d58213579b6797adc1965848b646d/globalmount","target_path":"/var/lib/kubelet/pods/8c896175-ee76-470c-bc0f-9dfe25a4cdd9/volumes/kubernetes.io~csi/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-340084f0-9faa-41db-b09c-9e90f9165fd5","csi.storage.k8s.io/pvc/name":"pvc-azuredisk","csi.storage.k8s.io/pvc/namespace":"default","requestedsizegib":"10","skuname":"StandardSSD_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1694687347267-1086-disk.csi.azure.com"},"volume_id":"/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-340084f0-9faa-41db-b09c-9e90f9165fd5"}
```

- https://kubernetes.io/docs/concepts/storage/volumes/: volumeHandle: A string value that uniquely identifies the volume. This value must correspond to the value returned in the volume.id field of the CreateVolumeResponse by the CSI driver. The value is passed as volume_id on all calls to the CSI volume driver

## pv.volumeHandle.volume_id.error.volumeOperationAlreadyExists

```
# The error "An operation with the given Volume ID already exists" indicates that a previous mount operation is stuck, and the CSI driver is currently preventing another mount of the same volume with a lock.
# The error is in CSI driver pod logs
# If you come across an error in the CSI logs right after the NodeStageVolume mount, consider performing a manual mount on that node using the specified protocol.
```

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/pkg/azuredisk/nodeserver.go: volumeOperationAlreadyExistsFmt = "An operation with the given Volume ID %s already exists"
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/volume_lock.go: volumeOperationAlreadyExistsFmt = "An operation with the given Volume ID %s already exists"
- https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/pkg/nfs/utils.go: volumeOperationAlreadyExistsFmt = "An operation with the given Volume ID %s already exists"
- https://github.com/kubernetes-csi/csi-driver-smb/issues/444: An operation with the given Volume ID test-csi-driver-smb already exists
- https://github.com/rook/rook/issues/4896: ~ The mitigation is to restart the CSI driver pod
  

