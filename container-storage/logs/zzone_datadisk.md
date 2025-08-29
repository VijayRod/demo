## datadisk

```
# See the section on data disk

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 2
az aks nodepool add -g $rg --cluster-name aks -n np2 -z 1 -s $vmsize -c 2 # zone
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

kubectl describe sc | grep -E 'sku|Provisioner'
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           blob.csi.azure.com
Parameters:            protocol=nfs,skuName=Premium_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           file.csi.azure.com
Parameters:            skuName=Premium_LRS
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_LRS
Provisioner:           disk.csi.azure.com
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_LRS
Provisioner:           disk.csi.azure.com
Parameters:            skuname=Premium_LRS
Provisioner:           disk.csi.azure.com
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-disk-volume#error1: Disk cannot be attached to the VM because it is not in the same zone as the VM. In AKS, the default and other built-in StorageClasses for Azure disks use locally redundant storage (LRS). topology.disk.csi.azure.com/zone
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-redundancy#limitations
- https://github.com/kubernetes/kubernetes/issues/97080#issuecomment-751203190: In mixed node pools scenario(user has both zoned and non-zoned node pools), let's add affinity to schedule pod only on non-zone node pool on the pod/statefulset/deployoment
- https://cloud-provider-azure.sigs.k8s.io/topics/availability-zones/#node-labels
- https://kubernetes.io/docs/setup/best-practices/multiple-zones/#storage-access-for-zones
- https://learn.microsoft.com/en-us/azure/aks/availability-zones-overview#azure-disk-availability-zones-support: Volumes that use Azure managed LRS disks aren't zone-redundant resources, and attaching across zones isn't supported. StorageClass. skuName: StandardSSD_ZRS  # or Premium_ZRS
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-redundancy
- https://learn.microsoft.com/en-us/azure/aks/aks-zone-resiliency#make-your-storage-disk-decision

```
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview#data-disk: Data disks are registered as SCSI drives and are labeled with a letter that you choose
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-scalability-targets: For optimal performance, limit the number of highly utilized disks attached to the virtual machine to avoid possible throttling. If all attached disks aren't highly utilized at the same time, the virtual machine can support a larger number of disks.

```
# portal: Disk, Overview has Disk State = Attached, and the Managed By field displays the node name

kubectl delete po nginx
kubectl delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: azure
      mountPath: /mnt/azure
  volumes:
  - name: azure
    persistentVolumeClaim:
      claimName: pvc-azuredisk
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
      storage: 1Gi
  #storageClassName: managed-csi
EOF
kubectl get po -w

k get po,pv,pvc,volumeattachment
NAME        READY   STATUS    RESTARTS   AGE
pod/nginx   1/1     Running   0          114s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-e96a31a5-2246-449e-b90f-2b6933595e22   1Gi        RWO            Delete           Bound    default/pvc-azuredisk   default        <unset>                          110s

NAME                                  STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-azuredisk   Bound    pvc-e96a31a5-2246-449e-b90f-2b6933595e22   1Gi        RWO            default        <unset>                 113s

NAME                                                                                                   ATTACHER             PV                                         NODE                                ATTACHED   AGE
volumeattachment.storage.k8s.io/csi-859f338b71b4d725a1b92e6d8b78b36359b1de2c9bf293e7ffa96fc0f6bc8a20   disk.csi.azure.com   pvc-e96a31a5-2246-449e-b90f-2b6933595e22   aks-nodepool1-29436964-vmss000002   true       110s

k describe po,pv,pvc,volumeattachment
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             aks-nodepool1-29436964-vmss000002/10.224.0.5
Start Time:       Mon, 11 Aug 2025 18:06:01 +0000
Labels:           run=nginx
Annotations:      <none>
Status:           Running
IP:               10.244.2.35
IPs:
  IP:  10.244.2.35
Containers:
  nginx:
    Container ID:   containerd://db132cf92ccaf9827e4b9091512c777a0befe4540299cc97f5682fa933138e4c
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:84ec966e61a8c7846f509da7eb081c55c1d56817448728924a87ab32f12a72fb
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 11 Aug 2025 14:06:24 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /mnt/azure from azure (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-qhkck (ro)
Volumes:
  azure:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pvc-azuredisk
    ReadOnly:   false
  kube-api-access-qhkck:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
Events:
  Type     Reason                  Age    From                     Message
  ----     ------                  ----   ----                     -------
  Warning  FailedScheduling        6m10s  default-scheduler        0/3 nodes are available: persistentvolumeclaim "pvc-azuredisk" not found. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
  Normal   Scheduled               6m6s   default-scheduler        Successfully assigned default/nginx to aks-nodepool1-29436964-vmss000002
  Normal   SuccessfulAttachVolume  5m53s  attachdetach-controller  AttachVolume.Attach succeeded for volume "pvc-e96a31a5-2246-449e-b90f-2b6933595e22"
  Normal   Pulling                 5m51s  kubelet                  Pulling image "nginx"
  Normal   Pulled                  5m44s  kubelet                  Successfully pulled image "nginx" in 6.707s (6.707s including waiting). Image size: 72223946 bytes.
  Normal   Created                 5m44s  kubelet                  Created container: nginx
  Normal   Started                 5m44s  kubelet                  Started container nginx


Name:              pvc-e96a31a5-2246-449e-b90f-2b6933595e22
Labels:            <none>
Annotations:       pv.kubernetes.io/provisioned-by: disk.csi.azure.com
                   volume.kubernetes.io/provisioner-deletion-secret-name:
                   volume.kubernetes.io/provisioner-deletion-secret-namespace:
Finalizers:        [external-provisioner.volume.kubernetes.io/finalizer kubernetes.io/pv-protection external-attacher/disk-csi-azure-com]
StorageClass:      default
Status:            Bound
Claim:             default/pvc-azuredisk
Reclaim Policy:    Delete
Access Modes:      RWO
VolumeMode:        Filesystem
Capacity:          1Gi
Node Affinity:
  Required Terms:
    Term 0:        topology.disk.csi.azure.com/zone in []
Message:
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            disk.csi.azure.com
    FSType:
    VolumeHandle:      /subscriptions/$subId/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-e96a31a5-2246-449e-b90f-2b6933595e22
    ReadOnly:          false
    VolumeAttributes:      csi.storage.k8s.io/pv/name=pvc-e96a31a5-2246-449e-b90f-2b6933595e22
                           csi.storage.k8s.io/pvc/name=pvc-azuredisk
                           csi.storage.k8s.io/pvc/namespace=default
                           requestedsizegib=1
                           skuname=StandardSSD_LRS
                           storage.kubernetes.io/csiProvisionerIdentity=1754914100857-8712-disk.csi.azure.com
Events:                <none>

Name:          pvc-azuredisk
Namespace:     default
StorageClass:  default
Status:        Bound
Volume:        pvc-e96a31a5-2246-449e-b90f-2b6933595e22
Labels:        <none>
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
               volume.beta.kubernetes.io/storage-provisioner: disk.csi.azure.com
               volume.kubernetes.io/selected-node: aks-nodepool1-29436964-vmss000002
               volume.kubernetes.io/storage-provisioner: disk.csi.azure.com
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      1Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Used By:       nginx
Events:
  Type    Reason                 Age                    From                                                                                               Message
  ----    ------                 ----                   ----                                                                                               -------
  Normal  WaitForPodScheduled    6m11s (x2 over 6m11s)  persistentvolume-controller                                                                        waiting for pod nginx to be scheduled
  Normal  Provisioning           6m10s                  disk.csi.azure.com_csi-azuredisk-controller-5d665bc968-qm89h_d574326d-da61-4539-a48f-02f4cdd434dc  External provisioner is provisioning volume for claim "default/pvc-azuredisk"
  Normal  ExternalProvisioning   6m10s                  persistentvolume-controller                                                                        Waiting for a volume to be created either by the external provisioner 'disk.csi.azure.com' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
  Normal  ProvisioningSucceeded  6m8s                   disk.csi.azure.com_csi-azuredisk-controller-5d665bc968-qm89h_d574326d-da61-4539-a48f-02f4cdd434dc  Successfully provisioned volume pvc-e96a31a5-2246-449e-b90f-2b6933595e22


Name:         csi-859f338b71b4d725a1b92e6d8b78b36359b1de2c9bf293e7ffa96fc0f6bc8a20
Namespace:
Labels:       <none>
Annotations:  csi.alpha.kubernetes.io/node-id: aks-nodepool1-29436964-vmss000002
API Version:  storage.k8s.io/v1
Kind:         VolumeAttachment
Metadata:
  Creation Timestamp:  2025-08-11T18:06:01Z
  Finalizers:
    external-attacher/disk-csi-azure-com
  Resource Version:  34051
  UID:               23084b6f-9dc8-4780-8551-28d30a657542
Spec:
  Attacher:   disk.csi.azure.com
  Node Name:  aks-nodepool1-29436964-vmss000002
  Source:
    Persistent Volume Name:  pvc-e96a31a5-2246-449e-b90f-2b6933595e22
Status:
  Attached:  true
  Attachment Metadata:
    LUN:  0
Events:   <none>

k get sc
NAME                    PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
default (default)       disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   125m

k describe sc default
Name:                  default
IsDefaultClass:        Yes
Annotations:           storageclass.kubernetes.io/is-default-class=true
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
```

> ## datadisk.error.MaxVolumeCountExceeded

```
clear
kubectl delete pvc --all
kubectl delete pod --all
rm /tmp/pods.yaml
for i in $(seq -f "%03g" 1 30)
do
cat <<EOF >> /tmp/pods.yaml
# cat << EOF | kubectl create -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk$i
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: managed-csi-premium
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk$i
spec:
  nodeSelector:
    kubernetes.io/hostname: aks-nodepool1-37603350-vmss000002 #
  containers:
    - image: nginx
      name: nginx-azuredisk
      volumeMounts:
        - name: azuredisk01
          mountPath: /mnt/azuredisk
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk$i
EOF
done
# cat /tmp/pods.yaml
kubectl create -f /tmp/pods.yaml
date
kubectl get po -w
kubectl get po,pv,pvc
kubectl describe po | grep Events -A 20

Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  55s   default-scheduler  0/2 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 1 node(s) exceed max volume count. preemption: 0/2 nodes are available: 1 No preemption victims found for incoming pod, 1 Preemption is not helpful for scheduling.
```

- https://github.com/kubernetes/kubernetes/blob/master/pkg/scheduler/framework/plugins/nodevolumelimits/csi.go: // ErrReasonMaxVolumeCountExceeded is used for MaxVolumeCount predicate error.
	ErrReasonMaxVolumeCountExceeded = "node(s) exceed max volume count"
- https://learn.microsoft.com/en-us/azure/virtual-machines/sizes/memory-optimized/dv2-dsv2-series-memory: Max data disks
- https://github.com/kubernetes-sigs/azuredisk-csi-driver/issues/1842: csi_node does not respect max_volumes_per_node value provided by VM. is there any data disk attached to the node without using CSI driver? since that data disk is not managed by csi driver, the max volumes should be n-1 now.

## datadisk.zone..none

```
# pod/pvc without a specficed zone

kubectl delete po nginx
kubectl delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: azure
      mountPath: /mnt/azure
  volumes:
  - name: azure
    persistentVolumeClaim:
      claimName: pvc-azuredisk
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
      storage: 1Gi
  #storageClassName: managed-csi
EOF
kubectl get po -w

k describe pv
Name:              pvc-d1ba87ea-2cb0-4226-bc26-6e30aad6fb33
Node Affinity:
  Required Terms:
    Term 0:        topology.disk.csi.azure.com/zone in [swedencentral-1]

kubectl get no -o yaml | grep volumesAttached # no rows without a pvc

kubectl get no -o yaml | grep volumesAttached -A 15 # | grep pvc-d3ea24ab -B 10 -A 15
- apiVersion: v1
  status:
    volumesAttached:
    - devicePath: ""
      name: kubernetes.io/csi/disk.csi.azure.com^/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-d1ba87ea-2cb0-4226-bc26-6e30aad6fb33
    volumesInUse:
    - kubernetes.io/csi/disk.csi.azure.com^/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-d1ba87ea-2cb0-4226-bc26-6e30aad6fb33
kind: List
```

## datadisk.zone.error.disk.not in the same zone as the VM

```
# HTTPStatusCode: 400, BadRequest, Disk <uri> cannot be attached to the VM because it is not in the same zone as the VM. VM zone: '1'. Disk zone: '2'

kubectl describe no -l kubernetes.azure.com/agentpool=np2 | grep zone # topology.disk.csi.azure.com/zone=swedencentral-1
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
diskUri=$(az disk create -g $noderg -n myAKSDisk --size-gb 1 --zone 2 --query id --output tsv); echo $diskUri # --zone different from VM

kubectl delete po mypod
kubectl delete pvc pvc-azuredisk
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
      storage: 1Gi
  volumeName: pv-azuredisk
  storageClassName: managed-csi
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  nodeSelector:
    kubernetes.azure.com/agentpool: np2
  volumes:
    - name: azure
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get po,pv,pvc
kubectl get po -owide

NAME        READY   STATUS              RESTARTS   AGE
pod/mypod   0/1     ContainerCreating   0          30s

NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pv-azuredisk   1Gi        RWO            Retain           Bound    default/pvc-azuredisk   managed-csi    <unset>                          30s

NAME                                  STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-azuredisk   Bound    pv-azuredisk   1Gi        RWO            managed-csi    <unset>                 30s

kubectl describe po
Node:             aks-np2-39852331-vmss000000/10.224.0.5
Status:           Pending
Containers:
  nginx:
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
Conditions:
  Type                        Status
  PodReadyToStartContainers   False
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  azure:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pvc-azuredisk
    ReadOnly:   false
  kube-api-access-swh78:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
Events:
  Type     Reason              Age               From                     Message
  ----     ------              ----              ----                     -------
  Normal   Scheduled           41s               default-scheduler        Successfully assigned default/mypod to aks-np2-39852331-vmss000000
  Warning  FailedAttachVolume  5s (x7 over 39s)  attachdetach-controller  AttachVolume.Attach failed for volume "pv-azuredisk" : rpc error: code = Internal desc = Attach volume /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/disks/myAKSDisk to instance aks-np2-39852331-vmss000000 failed with Retriable: false, RetryAfter: 0s, HTTPStatusCode: 400, RawError: {\r
  "error": {\r
    "code": "BadRequest",\r
    "message": "Disk /redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/myAKSDisk cannot be attached to the VM because it is not in the same zone as the VM. VM zone: '1'. Disk zone: '2'."\r
  }\r
}

kubectl logs -n kube-system -l app=csi-azuredisk-node -c azuredisk # no rows
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume#error1

## datadisk.zone.node

```
# Instead of having multi-AZ nodepools, use one nodepool per zone.

az aks nodepool create -z
```

## datadisk.zone.node.cluster-autoscaler

```
# avoid having multi-AZ nodepools and instead create one nodepool per zone, enabling the --balance-similar-node-group flag.
```

- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#im-running-cluster-with-nodes-in-multiple-zones-for-ha-purposes-is-that-supported-by-cluster-autoscaler: --balance-similar-node-groups flag to support this use case. If you set the flag to true, CA will automatically identify node groups with the same instance type and the same set of labels (except for automatically added zone label) and try to keep the sizes of those node groups balanced.

## datadisk.zone.pod.nodeAffinity

```
# nodeAffinity - Ensure disk and node hosting the pod are in the same zone

# k describe no -l kubernetes.azure.com/agentpool=np2 | grep zone # topology.disk.csi.azure.com/zone=swedencentral-1
kubectl delete po nginx
kubectl delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.disk.csi.azure.com/zone
            operator: In
            values:
            - swedencentral-1   
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: azure
      mountPath: /mnt/azure
  nodeSelector:
    kubernetes.azure.com/agentpool: np2
  volumes:
  - name: azure
    persistentVolumeClaim:
      claimName: pvc-azuredisk
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
      storage: 1Gi
  #storageClassName: managed-csi
EOF
kubectl get po -w # Running
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume#solution-1-ensure-disk-and-node-hosting-the-pod-are-in-the-same-zone

## datadisk.zone.sc.allowedTopologies

```
# k describe no -l kubernetes.azure.com/agentpool=np2 | grep zone # topology.disk.csi.azure.com/zone=swedencentral-1
kubectl delete po nginx
kubectl delete pvc pvc-azuredisk
kubectl delete sc managed-csi-lrs-zone
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-csi-lrs-zone
provisioner: disk.csi.azure.com
parameters:
  skuName: StandardSSD_LRS # LRS
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
allowedTopologies: # zone
- matchLabelExpressions:
  - key: topology.kubernetes.io/zone
    values:
    - swedencentral-1
    - swedencentral-2
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: azure
      mountPath: /mnt/azure
  nodeSelector:
    kubernetes.azure.com/agentpool: np2 # node
  volumes:
  - name: azure
    persistentVolumeClaim:
      claimName: pvc-azuredisk
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
      storage: 1Gi
  storageClassName: managed-csi-lrs-zone # sc
EOF
kubectl get po -w # Running
```

- https://kubernetes.io/docs/concepts/storage/storage-classes/#allowed-topologies: When a cluster operator specifies the WaitForFirstConsumer volume binding mode, it is no longer necessary to restrict provisioning to specific topologies in most situations. However, if still required, allowedTopologies can be specified.
- https://kubernetes.io/docs/setup/best-practices/multiple-zones/#storage-access-for-zones: You can specify a StorageClass for PersistentVolumeClaims that specifies the failure domains (zones) that the storage in that class may use. To learn about configuring a StorageClass that is aware of failure domains or zones, see Allowed topologies.

## datadisk.zone.sc.skuName.PremiumV2_LRS

- https://learn.microsoft.com/en-us/azure/aks/use-premium-v2-disks
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-deploy-premium-v2?tabs=azure-cli#limitations: can't be used as an OS disk. can only be attached to zonal VMs. doesn't support host caching.

```
# dynamic volume

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akszone --zones 1 2 -s $vmsize -c 2 # PremiumV2_LRS needs VMs in an availability zone
az aks get-credentials -g $rg -n akszone --overwrite-existing
kubectl get no; kubectl get po -A

kubectl delete po nginx
kubectl delete pvc premium2-disk
kubectl delete sc premium2-disk-sc
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: premium2-disk-sc
parameters:
   cachingMode: None
   skuName: PremiumV2_LRS
   # DiskIOPSReadWrite: "4000"
   # DiskMBpsReadWrite: "1000"
provisioner: disk.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: premium2-disk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: premium2-disk-sc
  resources:
    requests:
      storage: 1Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /mnt/azure
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: premium2-disk
EOF
kubectl get po -w # Running
```

```
# static volume

noderg=$(az aks show -g $rg -n akszone --query nodeResourceGroup -o tsv) 
az disk create -g $noderg -n disk2 --size-gb 300 --zone 2 --sku PremiumV2_LRS
diskId=$(az disk show -g $noderg -n disk2 --query id -otsv)

kubectl delete po nginx
kubectl delete pvc pvc-premiumv2
kubectl delete pv pv-premiumv2
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
 annotations:
   pv.kubernetes.io/provisioned-by: disk.csi.azure.com
 name: pv-premiumv2
spec:
 capacity:
   storage: 1Gi
 accessModes:
   - ReadWriteOnce
 persistentVolumeReclaimPolicy: Retain
 # storageClassName: premium2-disk-sc
 csi:
   driver: disk.csi.azure.com
   volumeHandle: $diskId
   volumeAttributes:
     cachingMode: None
     skuName: PremiumV2_LRS
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 annotations:
 name: pvc-premiumv2
spec:
 # storageClassName: premium2-disk-sc
 accessModes:
 - ReadWriteOnce
 resources:
   requests:
     storage: 1Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.disk.csi.azure.com/zone
            operator: In
            values:
            - swedencentral-2 # same zone as the static disk 
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /mnt/azure
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-premiumv2
EOF
kubectl get po -w # Running
kubectl exec nginx -- ls /mnt/azure # lost+found
```

```
# Cluster or nodepool created without --zone

kubectl describe po
Events:
  Type     Reason              Age                 From                     Message
  ----     ------              ----                ----                     -------
  Warning  FailedScheduling    116s (x2 over 2m)   default-scheduler        0/2 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
  Normal   Scheduled           113s                default-scheduler        Successfully assigned default/nginx to aks-nodepool1-29173261-vmss000000
  Warning  FailedAttachVolume  42s (x8 over 110s)  attachdetach-controller  AttachVolume.Attach failed for volume "pvc-7a005c66-8aa2-47c5-a7e5-dc3487a3a9c1" : rpc error: code = Internal desc = Attach volume /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_akscni_swedencentral/providers/Microsoft.Compute/disks/pvc-7a005c66-8aa2-47c5-a7e5-dc3487a3a9c1 to instance aks-nodepool1-29173261-vmss000000 failed with Retriable: false, RetryAfter: 0s, HTTPStatusCode: 400, RawError: {\r
  "error": {\r
    "code": "InvalidParameter",\r
    "message": "Managed disks with 'PremiumV2_LRS' storage account type can be used only with Virtual Machines in an Availability Zone.",\r
    "target": "managedDisk.storageAccountType"\r
  }\r
}
```

## datadisk.zone.sc.skuName.ZRS

```
# az aks create --zones
  
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akszrs --zones 1 2 -s $vmsize -c 2 # --zones
az aks get-credentials -g $rg -n akszrs --overwrite-existing
kubectl get no; kubectl get po -A
kubectl describe sc | grep -E 'Name|sku|Provisioner'

Name:                  azurefile
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
Name:                  azurefile-csi
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
Name:                  azurefile-csi-premium
Provisioner:           file.csi.azure.com
Parameters:            skuName=Premium_LRS
Name:                  azurefile-premium
Provisioner:           file.csi.azure.com
Parameters:            skuName=Premium_LRS
Name:                  default
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_ZRS
Name:                  managed
Provisioner:           disk.csi.azure.com
Name:                  managed-csi
Provisioner:           disk.csi.azure.com
Parameters:            skuname=StandardSSD_ZRS
Name:                  managed-csi-premium
Provisioner:           disk.csi.azure.com
Parameters:            skuname=Premium_ZRS
Name:                  managed-premium
Provisioner:           disk.csi.azure.com
```

- https://learn.microsoft.com/en-us/azure/aks/availability-zones-overview#azure-disk-availability-zones-support: Effective starting with Kubernetes version 1.29, when you deploy Azure Kubernetes Service (AKS) clusters across multiple availability zones, AKS now utilizes zone-redundant storage (ZRS) to create managed disks within built-in storage classes.
  - ZRS ensures synchronous replication of your Azure managed disks across multiple Azure availability zones in your chosen region. This redundancy strategy enhances the resilience of your applications and safeguards your data against datacenter failures.
  - However, it's important to note that zone-redundant storage (ZRS) comes at a higher cost compared to locally redundant storage (LRS). If cost optimization is a priority, you can create a new storage class with the skuname parameter set to LRS. You can then use the new storage class in your Persistent Volume Claim (PVC).

```
# Use zone-redundant storage (ZRS) disks
# Use ZRS disks: ZRS (Premium_ZRS, StandardSSD_ZRS) disks can be scheduled on both zone and non-zone agent nodes, without needing to keep the disk volume in the same zone as the node. Note that ZRS disks are only supported in a few regions, so check the details.

kubectl delete pvc pvc-azuredisk
kubectl delete po nginx
kubectl delete sc managed-csi-zrs
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-csi-zrs
provisioner: disk.csi.azure.com
parameters:
  skuName: StandardSSD_ZRS  # or Premium_ZRS
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: azure
      mountPath: /mnt/azure
  nodeSelector:
    kubernetes.azure.com/agentpool: np2
  volumes:
  - name: azure
    persistentVolumeClaim:
      claimName: pvc-azuredisk
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
      storage: 1Gi
  storageClassName: managed-csi-zrs
EOF
kubectl get po -w # Running
```

- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/fail-to-mount-azure-disk-volume#solution-2-use-zone-redundant-storage-zrs-disks

## datadisk.zone.sc.spec.volumeBindingMode

```
# Modify the volumeBindingMode to WaitForFirstConsumer

kubectl describe sc | grep -E 'VolumeBindingMode|Provisioner'
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           file.csi.azure.com
VolumeBindingMode:  Immediate
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
Provisioner:           disk.csi.azure.com
VolumeBindingMode:     WaitForFirstConsumer
```
