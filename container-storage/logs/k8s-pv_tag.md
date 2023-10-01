```
kubectl delete po nginx-azuredisk
kubectl delete pvc pvc-azuredisk
kubectl delete sc default-custom
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: default-custom
parameters:
  skuname: StandardSSD_LRS
  tags: key1=val1,key2=val2
provisioner: disk.csi.azure.com
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
      storage: 10Gi
  storageClassName: default-custom
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-azuredisk
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - image: nginx
      name: nginx
      volumeMounts:
        - name: azuredisk01
          mountPath: /mnt/azuredisk
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get po,pv,pvc
kubectl describe pv | grep VolumeH
```

```
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rg_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-44dd2af0-d46a-44c7-b3b0-76be50f7499d
    
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)   
az disk list -g $noderg
az disk list -g $noderg --query [0].tags
az disk show -g $noderg -n pvc-44dd2af0-d46a-44c7-b3b0-76be50f7499d --query tags

{
  "k8s-azure-created-by": "kubernetes-azure-dd",
  "key1": "val1",
  "key2": "val2",
  "kubernetes.io-created-for-pv-name": "pvc-44dd2af0-d46a-44c7-b3b0-76be50f7499d",
  "kubernetes.io-created-for-pvc-name": "pvc-azuredisk",
  "kubernetes.io-created-for-pvc-namespace": "default"
}
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-disk-storage-provision#dynamic-provisioning-parameters
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-policies#policy-definitions: Add or replace a tag on resources (PVC - VolumeResizeFailed  - RequestDisallowedByPolicy)
