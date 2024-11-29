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

## datadisk.zone.aks.ZRS

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
  
## datadisk.zone.disk.error.not in the same zone as the VM

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

## datadisk.zone.sc.skuName.ZRS

```
# Use zone-redundant storage (ZRS) disks

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

