## k8s-csi

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

k get crd | grep stor
volumesnapshotclasses.snapshot.storage.k8s.io           2024-10-15T18:38:35Z
volumesnapshotcontents.snapshot.storage.k8s.io          2024-10-15T18:38:35Z
volumesnapshots.snapshot.storage.k8s.io                 2024-10-15T18:38:35Z

k api-resources | grep stor
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
volumesnapshotclasses               vsclass,vsclasses   snapshot.storage.k8s.io/v1             false        VolumeSnapshotClass
volumesnapshotcontents              vsc,vscs            snapshot.storage.k8s.io/v1             false        VolumeSnapshotContent
volumesnapshots                     vs                  snapshot.storage.k8s.io/v1             true         VolumeSnapshot
csidrivers                                              storage.k8s.io/v1                      false        CSIDriver
csinodes                                                storage.k8s.io/v1                      false        CSINode
csistoragecapacities                                    storage.k8s.io/v1                      true         CSIStorageCapacity
storageclasses                      sc                  storage.k8s.io/v1                      false        StorageClass
volumeattachments                                       storage.k8s.io/v1                      false        VolumeAttachment
```

- [kubernetes.io/blog/2019/01/15/container-storage-interface-ga/](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/)
- [container-storage-interface/spec](https://github.com/container-storage-interface/spec/blob/master/spec.md)
- https://kubernetes-csi.github.io/docs/

## k8s-csi.csidrivers

```
kubectl get csidrivers
NAME                 ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS                REQUIRESREPUBLISH   MODES                  AGE
disk.csi.azure.com   true             false            false             <unset>                      false               Persistent             5m43s
file.csi.azure.com   false            true             false             api://AzureADTokenExchange   false               Persistent,Ephemeral   5m42s

kubectl describe csidrivers disk.csi.azure.com
Name:         disk.csi.azure.com
Namespace:
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              kubernetes.io/cluster-service=true
Annotations:  csiDriver: v1.29.9
              snapshot: v6.3.3
API Version:  storage.k8s.io/v1
Kind:         CSIDriver
Metadata:
  Creation Timestamp:  2024-10-10T08:49:02Z
  Resource Version:    458
  UID:                 18feb06c-6b0b-4776-8b6d-7a43470db107
Spec:
  Attach Required:     true
  Fs Group Policy:     File
  Pod Info On Mount:   false
  Requires Republish:  false
  Se Linux Mount:      false
  Storage Capacity:    false
  Volume Lifecycle Modes:
    Persistent
Events:  <none>

kubectl describe csidrivers file.csi.azure.com
Name:         file.csi.azure.com
Namespace:
Labels:       addonmanager.kubernetes.io/mode=Reconcile
              kubernetes.io/cluster-service=true
Annotations:  csiDriver: v1.30.5
              snapshot: v6.3.3
API Version:  storage.k8s.io/v1
Kind:         CSIDriver
Metadata:
  Creation Timestamp:  2024-10-10T08:49:03Z
  Resource Version:    486
  UID:                 4a98ac56-471f-425d-8a1d-21aa386dc069
Spec:
  Attach Required:     false
  Fs Group Policy:     ReadWriteOnceWithFSType
  Pod Info On Mount:   true
  Requires Republish:  false
  Se Linux Mount:      false
  Storage Capacity:    false
  Token Requests:
    Audience:  api://AzureADTokenExchange
  Volume Lifecycle Modes:
    Persistent
    Ephemeral
Events:  <none>
```

- https://kubernetes-csi.github.io/docs/drivers.html

## k8s-csi.csinodes

```
kubectl get csinodes
NAME                                DRIVERS   AGE
aks-nodepool1-25700344-vmss000000   2         4m19s
```

## k8s-csi.csi-controller

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/csi-blob-controller.yaml
- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/deploy/csi-azurefile-controller.yaml


## k8s-csi.csi-provisioner

```
https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/charts/latest/azurefile-csi-driver/values.yaml
image:
  baseRepo: mcr.microsoft.com
    repository: /k8s/csi/azurefile-csi
    repository: /oss/kubernetes-csi/csi-provisioner
...
# tbd Note: This is part of the azurefile image.
    
https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/csi-blob-controller.yaml
  name: csi-blob-controller
        - name: csi-provisioner
          image: mcr.microsoft.com/oss/kubernetes-csi/csi-provisioner:v5.1.0

https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/deploy/csi-azurefile-controller.yaml
  name: csi-azurefile-controller
      containers:
        - name: csi-provisioner
          image: mcr.microsoft.com/oss/kubernetes-csi/csi-provisioner:v5.1.0
```

- https://kubernetes-csi.github.io/docs/external-provisioner.html: registry.k8s.io/sig-storage/csi-provisioner. The CSI external-provisioner is a sidecar container that watches the Kubernetes API server for PersistentVolumeClaim objects.
- https://github.com/kubernetes-csi/external-provisioner: The external-provisioner is a sidecar container that dynamically provisions volumes by calling CreateVolume and DeleteVolume functions of CSI drivers. It is necessary because internal persistent volume controller running in Kubernetes controller-manager does not have any direct interfaces to CSI drivers.
- https://kubernetes.io/docs/concepts/storage/storage-classes/#provisioner: You can also run and specify external provisioners, which are independent programs that follow a specification defined by Kubernetes. Authors of external provisioners have full discretion over where their code lives, how the provisioner is shipped, how it needs to be run, what volume plugin it uses (including Flex), etc. The repository kubernetes-sigs/sig-storage-lib-external-provisioner houses a library for writing external provisioners that implements the bulk of the specification. Some external provisioners are listed under the repository kubernetes-sigs/sig-storage-lib-external-provisioner.
