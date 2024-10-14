## azuredisk-csi

```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

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

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
default (default)        disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed                  disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed-csi              disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed-csi-premium      disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h
managed-premium          disk.csi.azure.com   Delete          WaitForFirstConsumer   true                   9h

kubectl describe sc default
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

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-azuredisk-node           1         1         1       1            1           <none>          9h
csi-azuredisk-node-win       0         0         0       0            0           <none>          9h
```

- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/aks/storage: (Volume refers to a) managed disks
  
## azuredisk-csi.driver.parameter

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi#create-a-custom-storage-class

## azuredisk-csi.driver.parameter.skuName

```
kubectl describe sc | grep -E 'Name|Parameters'
Name:                  default
Parameters:            skuname=StandardSSD_LRS
Name:                  managed
Parameters:            cachingmode=ReadOnly,kind=Managed,storageaccounttype=StandardSSD_LRS
Name:                  managed-csi
Parameters:            skuname=StandardSSD_LRS
Name:                  managed-csi-premium
Parameters:            skuname=Premium_LRS
Name:                  managed-premium
Parameters:            cachingmode=ReadOnly,kind=Managed,storageaccounttype=Premium_LRS
```

## azuredisk-csi.provision.dynamic

```
kubectl delete deploy nginx
kubectl delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
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
      storage: 20Gi
  storageClassName: managed-csi
EOF
watch kubectl get deploy
```
