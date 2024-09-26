```
kubectl delete po fiopod
kubectl delete pvc pvc-azuredisk
kubectl delete sc azuredisk-custom

# To create the resources
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azuredisk-custom
provisioner: disk.csi.azure.com
parameters:
  skuName: abc
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: azuredisk-custom
  resources:
    requests:
      storage: 250Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  volumes:
    - name: azuredisk
      persistentVolumeClaim:
        claimName: pvc-azuredisk
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: azuredisk
EOF
kubectl get po,pv,pvc,sc
```

```
kubectl describe persistentvolumeclaim/pvc-azuredisk

Name:          pvc-azuredisk
Namespace:     default
StorageClass:  azuredisk-custom
Status:        Pending
  Warning  ProvisioningFailed    6s (x5 over 21s)  disk.csi.azure.com_csi-azuredisk-controller-7ff6dc747b-5dcp9_d28c37cf-d81f-4a8a-82b6-728c756f0057  failed to provision volume with StorageClass "azuredisk-custom": rpc error: code = InvalidArgument desc = azureDisk - abc is not supported sku/storageaccounttype. Supported values are [Premium_LRS Premium_ZRS Standard_LRS StandardSSD_LRS StandardSSD_ZRS UltraSSD_LRS PremiumV2_LRS]
  Normal   ExternalProvisioning  0s (x3 over 21s)  persistentvolume-controller
                                  waiting for a volume to be created, either by external provisioner "disk.csi.azure.com" or manually created by system administrator
```
                                  
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#dynamic-provisioning-parameters: skuName
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage: SKU
