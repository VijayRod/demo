## azurefile-csi

```
rg=rg
az group create -n $rg -l swedencentral
az aks create -g $rg -n aks
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azurefile                file.csi.azure.com   Delete          Immediate              true                   9h
azurefile-csi            file.csi.azure.com   Delete          Immediate              true                   9h
azurefile-csi-premium    file.csi.azure.com   Delete          Immediate              true                   9h
azurefile-premium        file.csi.azure.com   Delete          Immediate              true                   9h

kubectl describe sc azurefile
Name:                  azurefile
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           file.csi.azure.com
Parameters:            skuName=Standard_LRS
AllowVolumeExpansion:  True
MountOptions:
  mfsymlinks
  actimeo=30
  nosharesock
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-azurefile-node           1         1         1       1            1           <none>          9h
csi-azurefile-node-win       0         0         0       0            0           <none>          9h
```

```
kubectl delete po nginx-azurefile
kubectl delete pvc pvc-azurefile
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/pvc-azurefile-csi.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/nginx-pod-azurefile.yaml

kubectl get po nginx-azurefile -owide
kubectl get pvc pvc-azurefile
kubectl get pv
```

```
kubectl delete po nginx-azurefile
kubectl delete pvc pvc-azurefile
cat << EOF | kubectl create -f -
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azurefile
spec:
  nodeSelector:
    "kubernetes.io/os": linux
  containers:
    - image: nginx
      name: nginx-azurefile
      command:
        - "/bin/bash"
        - "-c"
        - set -euo pipefail; while true; do echo $(date) >> /mnt/azurefile/outfile; sleep 1; done
      volumeMounts:
        - name: persistent-storage
          mountPath: "/mnt/azurefile"
          readOnly: false
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: pvc-azurefile
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-csi
EOF
kubectl get po -w
```

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md: volumeAttributes.shareName. Azure file share name
- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/aks/storage: (Volume refers to a) Static or dynamically created file share (not a storage account)
- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision
- https://github.com/kubernetes-sigs/azurefile-csi-driver/tree/master/deploy/example

## azurefile-csi.driver.parameter

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#create-a-custom-storage-class
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#storage-class-parameters-for-dynamic-persistentvolumes

## azurefile-csi.driver.parameter.skuName

```
kubectl describe sc | grep -E 'Name|Parameters'
Name:                  azurefile
Parameters:            skuName=Standard_LRS
Name:                  azurefile-csi
Parameters:            skuName=Standard_LRS
Name:                  azurefile-csi-premium
Parameters:            skuName=Premium_LRS
Name:                  azurefile-premium
Parameters:            skuName=Premium_LRS
```

## azurefile-csi.driver.parameter.storageAccount

```
az storage account list -g MC_rg_aks_swedencentral
    "name": "fd121983a51b4483dab274b",
    "networkRuleSet": {
      "bypass": "AzureServices",
      "defaultAction": "Allow", # Public network access = Enabled from all networks
```

## azurefile-csi.driver.parameter.useDataPlaneAPI aka storage account firewall: 

```
kubectl delete pvc pvc-azurefile
kubectl delete sc azurefile-dataplane
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-dataplane
mountOptions:
- mfsymlinks
- actimeo=30
parameters:
  skuName: Standard_LRS
  useDataPlaneAPI: "true"
provisioner: file.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-dataplane
EOF
kubectl get pvc -w

NAME            STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS          VOLUMEATTRIBUTESCLASS   AGE
pvc-azurefile   Pending                                      azurefile-dataplane   <unset>                 0s
pvc-azurefile   Pending   pvc-81a52b07-f3da-4a59-ad54-0a53a76d73dc   0                         azurefile-dataplane   <unset>                 1s
pvc-azurefile   Bound     pvc-81a52b07-f3da-4a59-ad54-0a53a76d73dc   100Gi      RWX            azurefile-dataplane   <unset>                 1s

az storage account list -g MC_rg_aks_swedencentral
    "networkRuleSet": {
      "bypass": "AzureServices",
      "defaultAction": "Allow",
```      

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/pkg/azurefile/controllerserver.go: len(secret) == 0 && useDataPlaneAPI... failed to GetStorageAccesskey
- https://github.com/Azure/AKS/issues/804: Azure Files PV AuthorizationFailure when using advanced networking - I know why this only allow access from selected network for storage account does not work on AKS, that's because k8s persistentvolume-controller is on AKS master node which is not in the selected network, and that's why it could not create file share on that storage account... And in the near future, I don't think we would support this feature: only allow access from selected network for storage account... one workaround is use azure file static provisioning, that is create azure file share by user, and then user provide the storage account and file share in k8s... I think azure file static provisioning would work on this case, while dynamic provisioning (*specifically the default azurefile storage classes*) won't work
  - i.e. https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#statically-provision-a-volume
  - https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/create-file-share-failed-storage-account: The Kubernetes persistentvolume-controller isn't on the network that was chosen when the Allow access from network setting was enabled for Selected networks on the storage account.

## azurefile-csi.secret.dynamic

```
kubectl get secret
NAMESPACE     NAME                                                   TYPE                            DATA   AGE
default       azure-storage-account-fd121983a51b4483dab274b-secret   Opaque                          2      45s

kubectl describe secret
Name:         azure-storage-account-fd121983a51b4483dab274b-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
azurestorageaccountkey:   88 bytes
azurestorageaccountname:  23 bytes
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#storage-class-parameters-for-dynamic-persistentvolumes: If secretNamespace isn't specified, the secret is created in the same namespace as the pod

## azurefile-csi.secret.static

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#static-provisioning-parameters-for-persistentvolume: volumeAttributes.secretName... nodeStageSecretRef.name: If empty, driver uses kubelet identity to get account key.
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#mount-file-share-as-an-inline-volume: volumeAttributes.secretName

## azurefile-csi.scale

```
# Multiple pods using the same file share volume
kubectl delete deploy nginx
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
        - name: persistent-storage
          mountPath: /mnt/azurefile
          readOnly: false
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: pvc-azurefile
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-csi
EOF
# cat /tmp/pods.yaml
kubectl get po -w

kubectl scale deploy nginx --replicas 600
kubectl get deploy nginx -w

az aks scale -g $rg -n aks -c 6
kubectl get no
```

```
# Multiple pods that each utilize a different file share volume, all housed within the same storage account
rm /tmp/pods.yaml
for i in $(seq -f "%03g" 1 600)
do
  cat <<EOF >> /tmp/pods.yaml
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azurefile-$i
spec:
  nodeSelector:
    "kubernetes.io/os": linux
  containers:
    - image: nginx
      name: nginx-azurefile
      command:
        - "/bin/bash"
        - "-c"
        - set -euo pipefail; while true; do echo $(date) >> /mnt/azurefile/outfile; sleep 1; done
      volumeMounts:
        - name: persistent-storage
          mountPath: "/mnt/azurefile"
          readOnly: false
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: pvc-azurefile-$i
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-$i
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-csi
--- # This is necessary as it precedes the next pod definition in the file
EOF
done
# cat /tmp/pods.yaml
```

```
# Multiple pods that each utilize ten file share volumes, all housed within the same storage account
pods=10
volPerPod=10
rm /tmp/pods.yaml
for i in $(seq -f "%03g" 1 $pods)
do
  cat <<EOF >> /tmp/pods.yaml
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-$i
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
EOF
for j in $(seq -f "%03g" 1 $volPerPod)
do
  cat <<EOF >> /tmp/pods.yaml
        - name: persistent-storage-$i$j
          mountPath: /mnt/azurefile$i$j
          readOnly: false
EOF
done
  cat <<EOF >> /tmp/pods.yaml
  volumes:
EOF
for j in $(seq -f "%03g" 1 $volPerPod)
do
  cat <<EOF >> /tmp/pods.yaml
    - name: persistent-storage-$i$j
      persistentVolumeClaim:
        claimName: pvc-azurefile-$i$j
EOF
done
for j in $(seq -f "%03g" 1 $volPerPod)
do
  cat <<EOF >> /tmp/pods.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-$i$j
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: azurefile-csi
---
EOF
done
done
# cat /tmp/pods.yaml

# When deploying 10 pods each with 10 azurefile-csi PVCs: Most pods are up and running in about 20 seconds. However, it consistently takes over 3 minutes for the last few pods to reach a Running state. During this delay, 'kubectl get events' shows ExternalProvisioning events indicating "Waiting for a volume to be created either by the external provisioner 'file.csi.azure.com'". The storage account activity log has TooManyRequests errors for "Put File Share" operations, specifically mentioning a Write_ObservationWindow_00:00:01.
# When deploying 10 pods each with 10 azurefile-csi-premium PVCs: Pods already running within a minute.
# When deploying 10 pods each with 200 azurefile-csi-premium PVCs: This significantly increases creation time of all pods to over 35 minutes, accompanied by ExternalProvisioning and TooManyRequests errors for "Put File Share", also with a Write_ObservationWindow_00:00:01.
tbd CSI driver creating multiple storage accounts
tbd custom azurefile storage class created with useDataPlaneAPI and standard storage
tbd custom azurefile storage class created with useDataPlaneAPI and premium storage
tbd ReadWriteOnce and Azure Disk CSI driver v2 (preview)
tbd Azure NetApp Files
tbd Azure Premium SSD v2, ultra disks, Azure Container Storage
```

```
# create
echo Before starting the creation process...
date
kubectl create -f /tmp/pods.yaml
echo After the creation process is complete...
date
kubectl get pv | grep Bound | wc -l
kubectl get po | grep Running | wc -l
watch kubectl get po # kubectl get po -w

# delete
date
kubectl delete -f /tmp/pods.yaml
kubectl delete po --all
kubectl delete pvc --all
date
kubectl get po,pvc,pv

# misc
clear
kubectl get events -w
```
