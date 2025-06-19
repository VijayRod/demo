## k8s.csi.intree

```
# pod with in-tree volume has an "azureDisk:" type volume (and there's no associated pv since it's inline)

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
diskName="myAKSDisk"
diskUri=$(az disk create -g $noderg -n $diskName --size-gb 1 --query id --output tsv)
kubectl delete po nginx
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - name: azuredisk
      mountPath: /mnt/azuredisk
  volumes:
  - name: azuredisk
    azureDisk:
      diskURI: "$diskUri"
      diskName: "$diskName" # required value
      cachingMode: None
      fsType: ext4
      kind: Managed
EOF
kubectl get po -w

kubectl describe pv
No resources found in default namespace.

kubectl describe po
Name:             nginx
Containers:
  nginx:
    Mounts:
      /mnt/azuredisk from azuredisk (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-l4dpq (ro)
Volumes:
  azuredisk:
    Type:         AzureDisk (an Azure Data Disk mount on the host and bind mount to the pod)
    DiskName:     myAKSDisk
    DiskURI:      /subscriptions/efec8e52-e1ad-4ae1-8598-f243e56e2b08/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/disks/myAKSDisk
    Kind:         Managed
    FSType:       ext4
    CachingMode:  None
    ReadOnly:     false
```

- https://github.com/kubernetes/design-proposals-archive/blob/main/storage/csi-migration.md: An overall feature flag: CSIMigration is enabled for the Kubernetes Controller Manager and Kubelet.
  - CSIMigration feature flag is enabled for Kubernetes Controller Manager and the Kubelet where the pod with references to volumes got scheduled
- https://github.com/kubernetes/enhancements/blob/master/keps/sig-storage/625-csi-migration/README.md: In-tree Storage Plugin to CSI Migration Design Doc
- https://kubernetes.io/blog/2021/12/10/storage-in-tree-to-csi-migration-status-update/
- https://kubernetes.io/blog/2019/12/09/kubernetes-1-17-feature-csi-migration-beta/#what-is-csi-migration: Kubernetes hands control of all storage management operations (previously targeting in-tree drivers) to CSI drivers.
- https://kubernetes.io/search/?q=in-tree

```
# annotation pv.kubernetes.io/migrated-to
# Basically, this upstream annotation means the PV is being managed by the CSI driver instead of the in-tree plugin. However it is still an in-tree PV that isn't supported and needs to be migrated. 
# To migrate, the user needs to recreate the PV/PVC. The new PVC/PV made from the storage class will be a CSI volume, not the existing in-tree PV.
# The annotation doesn't matter. This shows that the PV is still using the in-tree driver, which does matter. No matter how the CX changes the storage class from in-tree to CSI, the PV is still using the in-tree driver. CX needs to recreate the PV/PVC:
  azureDisk:
    cachingMode: ReadOnly
    diskName: kubernetes-dynamic-pvc-abcdef123456
    diskURI: /subscriptions/12345678-90ab-cdef-1234-567890abcdef/resourceGroups/MC_myResourceGroup_myAKSCluster_eastus/providers/Microsoft.Compute/disks/kubernetes-dynamic-pvc-abcdef123456
 
# No matter how CX changes the storage class from in-tree to CSI, the PV still uses the in-tree driver. CX needs to recreate the PV/PVC.
 
# This annotation is applied to PersistentVolume (PV) objects to indicate that the PV, originally managed by an in-tree storage plugin, has been migrated to a corresponding CSI driver. The annotation acts as metadata for tracking and managing the migration process. It serves as metadata to indicate that the migration process has been enabled and the PV is now being managed by the CSI driver instead of the in-tree storage plugin.
# No, the annotation pv.kubernetes.io/migrated-to does not actually perform the migration of a PersistentVolume (PV).
# The pv.kubernetes.io/migrated-to annotation is shown starting from Kubernetes v1.17 (CSIMigration feature flag from AKS v1.23), which is when the CSI Migration feature was introduced as an alpha feature for specific storage providers. The annotation appears on PersistentVolumes (PVs) as part of the migration process when the CSI Migration feature gates are enabled for the corresponding in-tree plugin.
```

- https://kubernetes.io/docs/reference/labels-annotations-taints/#pv-kubernetesio-migratedto: It is added to a PersistentVolume(PV) and PersistentVolumeClaim(PVC) that is supposed to be dynamically provisioned/deleted by its corresponding CSI driver through the CSIMigration feature gate. When this annotation is set, the Kubernetes components will "stand-down" and the external-provisioner will act on the objects.
- https://github.com/kubernetes/enhancements/blob/master/keps/sig-storage/625-csi-migration/README.md: pv.kubernetes.io/migrated-to
- https://github.com/kubernetes-sigs/sig-storage-lib-external-provisioner/blob/master/controller/controller.go
// AnnMigratedTo annotation is added to a PVC that is supposed to be
// dynamically provisioned/deleted by by its corresponding CSI driver
// through the CSIMigration feature flags. It allows external provisioners
// to determine which PVs are considered migrated and safe to operate on for
// Deletion.
const annMigratedTo = "pv.kubernetes.io/migrated-to"
- https://github.com/kubewharf/godel-scheduler/blob/main/pkg/volume/persistentvolume/util/util.go
	// AnnMigratedTo annotation is added to a PVC and PV that is supposed to be
	// dynamically provisioned/deleted by by its corresponding CSI driver
	// through the CSIMigration feature flags. When this annotation is set the
	// Kubernetes components will "stand-down" and the external-provisioner will
	// act on the objects
	AnnMigratedTo = "pv.kubernetes.io/migrated-to"

```
# CSIMigration feature flag
# The CSIMigration* flags aren't in the new clusters, just the upgraded ones

# https://github.com/Azure/AKS/issues/3737
cat /etc/default/kubelet
KUBELET_FLAGS=--address=0.0.0.0 ...,pid.available<2000 --feature-gates=CSIMigration=true,CSIMigrationAzureDisk=true,CSIMigrationAzureFile=true...
```

- https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates-removed/: CSIMigration	true	GA	1.25	1.26
- * https://github.com/kubernetes/website/blob/main/content/en/docs/reference/command-line-tools-reference/feature-gates/CSIMigrationAzureDisk.md: Enables shims and translation logic to route volume operations from the Azure-Disk in-tree plugin to AzureDisk CSI plugin.
- https://github.com/kubernetes/enhancements/blob/master/keps/sig-storage/1490-csi-migration-azuredisk/README.md: As describe in CSI Migration, when this feature flag (CSIMigrationAzureDisk) && the CSIMigration is enabled at the same time, all operations related to the in-tree volume plugin kubernetes.io/azure-disk will be redirect to use the corresponding CSI driver. From a user perspective, nothing will be noticed.
- https://github.com/kubernetes/enhancements/blob/master/keps/sig-storage/1490-csi-migration-azuredisk/kep.yaml
title: In-tree Storage Plugin to CSI Migration - Azuredisk
kep-number: 1490
"https://github.com/kubernetes/design-proposals-archive/blob/master/storage/csi-migration.md"
- https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/feature-gates.md: CSIMigrationAzureDisk: {Default: false, PreRelease: featuregate.Beta}, // Off by default (requires Azure Disk CSI driver)
- https://github.com/kubernetes-sigs/cluster-api-provider-azure/issues/1673: From AKS 1.21, Azure Disk CSI driver is already the default storage driver, and we would like to turn on azure disk csi migration from 1.23, related PR: kubernetes/kubernetes#104670
- https://github.com/kubernetes/kubernetes/pull/104670: turn on CSIMigrationAzureDisk by default on 1.23
- https://github.com/kubernetes/sig-release/blob/master/releases/release-1.23/release-notes/release-notes-draft.md: Turn on CSIMigrationAzureDisk by default on 1.23 (#104670, @andyzhangx)
- https://github.com/kubernetes/sig-release/blob/master/releases/release-1.23/release-notes/maps/pr-104670-map.yaml
pr: 104670
releasenote:
  text: Turn on CSIMigrationAzureDisk by default on 1.23

```
# mix
Mixing in-tree with CSI could cause some unexpected issues.
```

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/issues/1842: csi_node does not respect max_volumes_per_node value provided by VM. is there any data disk attached to the node without using CSI driver (in-tree)? since that data disk is not managed by csi driver, the max volumes should be n-1 now.

## k8s.csi.intree.disk.static

```
# intree
kind: PersistentVolume
spec:
  azureDisk:
    cachingMode: ReadOnly
    diskName: kubernetes-dynamic-pvc-abcdef123456
    diskURI: /subscriptions/12345678-90ab-cdef-1234-567890abcdef/resourceGroups/MC_myResourceGroup_myAKSCluster_eastus/providers/Microsoft.Compute/disks/kubernetes-dynamic-pvc-abcdef123456
    fsType: ""
    kind: Managed
    readOnly: false
    
# csi
  kind: PersistentVolume
  spec:
    csi:
      driver: file.csi.azure.com
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/issues/1221: static intree pv description will also get a annotation like "pv.kubernetes.io/migrated-to: file.csi.azure.com"? as I can confirm that the migrated dynamic pv will have such annotation. the annotation of static pv is defined by end user, and that's just an annotation, does not make any difference. if you are already using driver: file.csi.azure.com, it means you are already using csi volume

```
# PersistentVolume: strict decoding error: unknown field "spec.azuredisk"
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
diskUri=$(az disk create -g $noderg -n myAKSDisk --size-gb 1 --query id --output tsv)
kubectl delete pv pv-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-azuredisk
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  azuredisk:
    cachingMode: ReadOnly
    diskURI: $diskUri
    fsType: ""
    kind: Managed
    readOnly: false
EOF
kubectl get pv -w

# success
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
diskUri=$(az disk create -g $noderg -n myAKSDisk --size-gb 1 --query id --output tsv)
kubectl delete pv pv-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-azuredisk
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: managed-csi
  csi:
    driver: disk.csi.azure.com
    readOnly: false
    volumeHandle: $diskUri # unique value
    volumeAttributes:
      fsType: ext4
EOF
kubectl get pv -w
```

```
kubectl patch pv pvName -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

- https://learn.microsoft.com/en-us/azure/aks/csi-migrate-in-tree-volumes#create-a-static-volume
