## azureblob-fuse

Here are steps from https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi to install this driver.
      
```
rg=rgblob
az group create -g $rg -l swedencentral
az aks create -g $rg -n aks --enable-blob-driver -s $vmsize -c 2

az aks show -g $rg -n aks --query storageProfile.blobCsiDriver -otsv
True
```

```
# Alternate installation
az aks create -g $rg -n aks

# Here is a sample output below.
#   "storageProfile": {
#     "blobCsiDriver": null,

# To enable the Azure blob CSI driver.
az aks update --enable-blob-driver -g $rg -n aks

# Here is a sample output below.
# Please make sure there is no open-source Blob CSI driver installed before enabling. (y/N): y
# ...
#   "storageProfile": {
#     "blobCsiDriver": {
#       "enabled": true
```

```
# To get credentials for running commands further below.
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azureblob-fuse-premium   blob.csi.azure.com   Delete          Immediate              true                   74s
azureblob-nfs-premium    blob.csi.azure.com   Delete          Immediate              true                   74s

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-blob-node                1         1         1       1            1           <none>          44m

# To retrieve related pods.
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below. Each node has a csi-blob-node pod. This does not include controller pods unlike the open source version.
csi-blob-node-wvn8q                   3/3     Running   0          104m   10.224.0.4    aks-nodepool1-14487815-vmss000002   <none>           <none>
csi-blob-node-zlvql                   3/3     Running   0          104m   10.224.0.5    aks-nodepool1-14487815-vmss000000   <none>           <none>
csi-blob-node-zp2rl                   3/3     Running   0          104m   10.224.0.6    aks-nodepool1-14487815-vmss000001   <none>           <none>

# To know the image. 
kubectl get po -n kube-system csi-blob-node-wvn8q -oyaml | grep image: | grep blob

# Here is a sample output below.
#    image: mcr.microsoft.com/oss/kubernetes-csi/blob-csi:v1.19.5
```

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/nodeserver.go
- https://github.com/kubernetes-sigs/blob-csi-driver#usage (features)
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/csi-debug.md
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, Azure Blob Storage CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in blobfuse plugin would be incorporated into this driver.
- https://github.com/kubernetes-sigs/blob-csi-driver/tree/master/deploy/example
- https://github.com/Azure/AKS/tree/master/vhd-notes
- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/aks/storage: (Volume refers to a) blob storage container
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-blob-storage
- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi
- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi#azure-blob-storage-csi-driver-features
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/mounting-azure-blob-storage-container-fail
- https://github.com/Azure/azure-storage-fuse/blob/main/TSG.md
- https://github.com/Seagate/cloudfuse: Cloudfuse is a fork of blobfuse2, and adds S3 support, a GUI, and Windows support

## azureblob-fuse.driver.parameter
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#storage-class-parameters-for-dynamic-persistent-volumes

## azureblob-fuse.driver.parameter.isHnsEnabled
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: enable Hierarchical namespace for Azure DataLake storage account
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#before-you-begin: To support an Azure DataLake Gen2 storage account when using blobfuse mount...
  - https://github.com/Azure/AKS/issues/4274#issuecomment-2102486680: ADLS (Azure DataLake Gen2 storage account). isHnsEnabled: "true" in the storage class parameters. mount option --use-adls=true in the persistent volume. If you are going to enable a storage account with Hierarchical Namespace, existing persistent volumes should be remounted with --use-adls=true mount option.

## azureblob-fuse.driver.parameter.protocol.fuse

```
kubectl describe sc azureblob-fuse-premium
Name:                  azureblob-fuse-premium
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:
  -o allow_other
  --file-cache-timeout-in-seconds=120
  --use-attr-cache=true
  --cancel-list-on-mount-seconds=10
  -o attr_timeout=120
  -o entry_timeout=120
  -o negative_timeout=120
  --log-level=LOG_WARNING
  --cache-size-mb=1000
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>
```

```
kubectl delete statefulset statefulset-blob
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: statefulset-blob
  labels:
    app: nginx
spec:
  serviceName: statefulset-blob
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
        - name: statefulset-blob
          image: nginx
          volumeMounts:
            - name: persistent-storage
              mountPath: /mnt/blob
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: nginx
  volumeClaimTemplates:
    - metadata:
        name: persistent-storage
      spec:
        storageClassName: azureblob-fuse-premium
        accessModes: ["ReadWriteMany"]
        resources:
          requests:
            storage: 100Gi
EOF
kubectl get po -w
```

```
kubectl delete po mypod
kubectl delete pvc pvc-azureblob-fuse
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-premium
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
EOF
kubectl get po -w

kubectl get secret
NAME                                                   TYPE     DATA   AGE
azure-storage-account-fused6a211cbd37d4469a72-secret   Opaque   2      28m

kubectl describe secret
Name:         azure-storage-account-fused6a211cbd37d4469a72-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
azurestorageaccountkey:   88 bytes
azurestorageaccountname:  23 bytes

kubectl logs -n kube-system csi-blob-node-zd69f -c blob
I1004 18:04:17.352023    5991 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
I1004 18:04:17.352040    5991 utils.go:105] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["-o allow_other","--file-cache-timeout-in-seconds=120","--use-attr-cache=true","--cancel-list-on-mount-seconds=10","-o attr_timeout=120","-o entry_timeout=120","-o negative_timeout=120","--log-level=LOG_WARNING","--cache-size-mb=1000"]}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/pv/name":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/pvc/name":"pvc-azureblob-fuse","csi.storage.k8s.io/pvc/namespace":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1728056647464-33-blob.csi.azure.com"},"volume_id":"MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#"}
I1004 18:04:17.352392    5991 blob.go:504] volumeID(MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#) authEnv: []
I1004 18:04:17.414838    5991 blob.go:911] got storage account(fused6a211cbd37d4469a72) from secret(azure-storage-account-fused6a211cbd37d4469a72-secret) namespace(default)
I1004 18:04:17.414887    5991 nodeserver.go:386] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount
protocol

volumeId MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#
mountflags [-o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000]
mountOptions [-o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384
serverAddress fused6a211cbd37d4469a72.blob.core.windows.net
I1004 18:04:17.414905    5991 nodeserver.go:166] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384
I1004 18:04:17.415364    5991 nodeserver.go:175] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384
I1004 18:04:18.645913    5991 mount_linux.go:282] Detected umount with safe 'not mounted' behavior
I1004 18:04:18.646050    5991 nodeserver.go:645] blobfuse mount at /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount success
I1004 18:04:18.646073    5991 nodeserver.go:444] volume(MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#) mount on "/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount" succeeded
I1004 18:04:18.646095    5991 utils.go:111] GRPC response: {}
I1004 18:04:18.666667    5991 utils.go:104] GRPC call: /csi.v1.Node/NodePublishVolume
I1004 18:04:18.666682    5991 utils.go:105] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount","target_path":"/var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["-o allow_other","--file-cache-timeout-in-seconds=120","--use-attr-cache=true","--cancel-list-on-mount-seconds=10","-o attr_timeout=120","-o entry_timeout=120","-o negative_timeout=120","--log-level=LOG_WARNING","--cache-size-mb=1000"]}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"4bbce626-894d-4896-bc38-718c4aaec726","csi.storage.k8s.io/pv/name":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/pvc/name":"pvc-azureblob-fuse","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","csi.storage.k8s.io/serviceAccount.tokens":"***stripped***","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1728056647464-33-blob.csi.azure.com"},"volume_id":"MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#"}
I1004 18:04:18.667074    5991 nodeserver.go:139] NodePublishVolume: volume MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# mounting /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount at /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount with mountOptions: [bind]
I1004 18:04:18.667092    5991 mount_linux.go:218] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount)
I1004 18:04:18.671368    5991 mount_linux.go:218] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount)
I1004 18:04:18.672538    5991 nodeserver.go:155] NodePublishVolume: volume MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# mount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount at /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount successfully
I1004 18:04:18.672553    5991 utils.go:111] GRPC response: {}
```

## azureblob-fuse.driver.parameter.protocol.fuse.nfs

```
kubectl describe sc azureblob-nfs-premium
Name:                  azureblob-nfs-premium
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           blob.csi.azure.com
Parameters:            protocol=nfs,skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

## azureblob-fuse.driver.parameter.nodeStageSecretRef

```
echo rg: $rg
storage="storage$RANDOM"
container="microservices"
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az storage account create -g $noderg -n $storage -o none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $noderg -n $storage -o tsv)
key=$(az storage account keys list -g $noderg --account-name $storage --query "[0].value" -o tsv)
echo Storage account key: $key
az storage container create --account-name $storage -n $container --auth-mode login

kubectl delete secret azure-secret
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storage --from-literal=azurestorageaccountkey=$key

kubectl delete po mypod
kubectl delete pvc pvc-blobmodels
kubectl delete pv pv-blobmodels
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-blobmodels
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: blob.csi.azure.com
    readOnly: true
    volumeHandle: pv-blobmodels
    volumeAttributes:
      containerName: $container
    nodeStageSecretRef:
      name: azure-secret
      namespace: default
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-blobmodels
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 10Gi
  volumeName: pv-blobmodels
  storageClassName: ""
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: /mnt/blob
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-blobmodels
EOF
kubectl get po,pv,pvc
sleep 10
```

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: secret name that stores...
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/pv-blobfuse-auth.yaml
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/pv-blobfuse-csi.yaml

## azureblob-fuse.driver.parameter.skuName.GRS

```
kubectl delete po mypod
kubectl delete pvc pvc-azureblob-fuse
kubectl delete sc azureblob-fuse-my
cat << EOF | k create -f -
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  labels:
    kubernetes.io/cluster-service: "true"
  name: azureblob-fuse-my
mountOptions:
- -o allow_other
- --file-cache-timeout-in-seconds=120
- --use-attr-cache=true
- --cancel-list-on-mount-seconds=10
- -o attr_timeout=120
- -o entry_timeout=120
- -o negative_timeout=120
- --log-level=LOG_WARNING
- --cache-size-mb=1000
parameters:
  skuName: Standard_GRS
provisioner: blob.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-my
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
EOF
kubectl get po -w
# kubectl describe pv

az storage account list -g MC_rgcni_akseadsv5_swedencentral | grep -E 'id|"name"'
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fuse414dbe20ef224a7a9ae",
    "name": "fuse414dbe20ef224a7a9ae",
      "name": "Premium_LRS",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fusec76e7488ea2047c9a2b",
    "name": "fusec76e7488ea2047c9a2b",
      "name": "Standard_GRS",
```

## azureblob-fuse.driver.parameter.skuName.LRS

```
kubectl describe sc azureblob-fuse-premium
Parameters:            skuName=Premium_LRS

az storage account list -g MC_rgcni_akseadsv5_swedencentral | grep -E 'id|"name"'
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fuse414dbe20ef224a7a9ae",
    "name": "fuse414dbe20ef224a7a9ae",
      "name": "Premium_LRS",
```

## azureblob-fuse.driver.parameter.useDataPlaneAPI aka storage account firewall: 

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: specify whether use data plane API for blob container create/delete, this could solve the SRP API throttling issue since data plane API has almost no limit, while it would fail when there is firewall or vnet setting on storage account i.e. make sure the storage account is not set to "Check Allow Access From (All Networks / Selected Networks)" "Selected Networks" i.e. set "Enabled from all networks" in the specified storage account
- https://learn.microsoft.com/en-us/answers/questions/1166011/getting-a-403-error-when-connecting-to-a-blob-cont: "Selected Networks" - It means the storage account is firewall enabled.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/controllerserver.go: if len(secrets) == 0 && useDataPlaneAPI {... "failed to GetStorageAccesskey on account
