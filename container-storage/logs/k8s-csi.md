## k8s-csi

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl api-resources | grep csi
csidrivers                                              storage.k8s.io/v1                      false        CSIDriver
csinodes                                                storage.k8s.io/v1                      false        CSINode
csistoragecapacities                                    storage.k8s.io/v1                      true         CSIStorageCapacity

kubectl get csinodes
NAME                                DRIVERS   AGE
aks-nodepool1-25700344-vmss000000   2         4m19s

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

kubectl get csistoragecapacities -A
No resources found
```

- [container-storage-interface/spec](https://github.com/container-storage-interface/spec/blob/master/spec.md)
- [kubernetes.io/blog/2019/01/15/container-storage-interface-ga/](https://kubernetes.io/blog/2019/01/15/container-storage-interface-ga/)
