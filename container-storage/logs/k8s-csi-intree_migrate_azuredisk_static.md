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
