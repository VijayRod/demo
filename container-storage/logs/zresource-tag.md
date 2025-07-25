```
# resource.tag

az tag list --resource-id /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral
{
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Resources/tags/default",
  "name": "default",
  "properties": {
    "tags": {
      "aks-managed-cluster-name": "aks",
      "aks-managed-cluster-rg": "rg"
    }
  },
  "resourceGroup": "MC_rg_aks_swedencentral",
  "type": "Microsoft.Resources/tags"
}

az resource show --ids /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral
{
  "extendedLocation": null,
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral",
  "identity": null,
  "kind": null,
  "location": "swedencentral",
  "managedBy": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/Microsoft.ContainerService/managedClusters/aks",
  "name": "MC_rg_aks_swedencentral",
  "plan": null,
  "properties": {
    "provisioningState": "Succeeded"
  },
  "sku": null,
  "tags": {
    "aks-managed-cluster-name": "aks",
    "aks-managed-cluster-rg": "rg"
  },
  "type": "Microsoft.Resources/resourceGroups"
}
 
az resource show --query tags --ids /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral
{
  "aks-managed-cluster-name": "aks",
  "aks-managed-cluster-rg": "rg"
}
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources-cli
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#tag-resource-groups

```
# resource.rp
```

- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support#microsoftcompute

```
# resource.rp.microsoft.containerservice.tag (aks)

az aks create -g $rg -n aks --tags dept=IT costcenter=9999 -s $vmSize
# az aks update -g $rg -n aks --tags dept=IT team=alpha costcenter=12345 # The MC_ resource group and its network resources (NSG, route table, LB) now have these tags.
# az aks update -g repro-502 -n aks-repro-502 --tags ""
az aks show -g $rg -n aks --query '[tags]' # Default value is [ null ]

az aks nodepool add -g $rg --cluster-name aks -n nptag --tags abtest=a costcenter=5555 -s $vmSize -c 1 --no-wait
# az aks nodepool update -g $rg --cluster-name aks -n nptag --tags appversion=0.0.2 costcenter=4444 --no-wait
az aks show -g $rg -n aks --query 'agentPoolProfiles[].{nodepoolName:name,tags:tags}'
```

- https://azure.microsoft.com/en-us/updates/general-availability-azure-tags-support-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/use-tags
- https://learn.microsoft.com/en-us/azure/aks/faq#can-i-modify-tags-and-other-properties-of-the-aks-resources-in-the-node-resource-group
- https://learn.microsoft.com/en-us/azure/aks/faq#can-i-provide-my-own-name-for-the-aks-node-resource-group: tag

```
# resource.rp.microsoft.compute.vm

az vm create -g $rg -n myvm  --image Ubuntu2404 --admin-username azureuser
# az vm update -g $rg -n myvm --set tags.env=prod tags.owner=me
# az vm create -g $rg -n myvmtag  --image Ubuntu2404 --admin-username azureuser --tags env=prod owner=me
az vm show -g $rg -n myvm  --query tags
```

```
# resource.rp.microsoft.compute.vm.vmss

rg=rgtag
az group create -n $rg -l $loc
az vmss create -g $rg -n myvmss --image Ubuntu2404 --admin-username azureuser --vm-sku $vmsize
# az vmss create -g $rg -n myvmsstag --image Ubuntu2404 --admin-username azureuser --vm-sku $vmsize --tags env=prod owner=me
# az vmss update -g $rg -n myvmss --set tags.env=prod tags.owner=me
az vmss show -g $rg -n myvmss --query tags

```

```
# resource.rp.microsoft.compute/disks
# this is relevant only for managed disks and does not apply to ephemeral disks, as ephemeral disks are free and not used for billing purposes, which is a primary reason for using tags.
```

```
# resource.rp.microsoft.compute/disks.data-disk.aks (PVC)

kubectl delete po nginx-pv-pod
kubectl delete pvc azure-disk-pvc
kubectl delete sc azure-disk-sc
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azure-disk-sc
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
  tags: "env=prod,owner=me"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-disk-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: azure-disk-sc
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pv-pod
spec:
  containers:
    - name: nginx
      image: nginx
      volumeMounts:
        - mountPath: "/mnt/azure"
          name: azure-storage
  volumes:
    - name: azure-storage
      persistentVolumeClaim:
        claimName: azure-disk-pvc
EOF
kubectl get po -w
Kubectl get pv

az disk show -g MC_RG9TAG_AKS_SWEDENCENTRAL -n pvc-7d2e5624-5ea1-4bdd-b0a6-ed33d806e548 --query "tags"

```

```
# resource.rp.microsoft.compute/disks.data-disk.aks 2

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

```
# resource.rp.microsoft.compute/disks.os-disk.vm

# /subscriptions/$subId/resourceGroups/rgtag/providers/Microsoft.Compute/disks/myvm_OsDisk_1_f728bc93898d447880a35bc96991c224
diskUri=$(az vm show -g $rg -n myvm  --query storageProfile.osDisk.managedDisk.id -otsv); echo $diskUri
az disk show --query tags --ids $diskUri
```

```
# resource.rp.microsoft.compute/disks.os-disk.vm.vmss

az vmss list-instances -g $rg -n myvmss
az vmss list-instances -g $rg -n myvmss \
                       --query "[].{InstanceId:instanceId, OS_Disk:storageProfile.osDisk.managedDisk.id}" \
                       --output table # no rows
az disk show --query tags --ids /subscriptions/$subId/resourceGroups/rgtag/providers/Microsoft.Compute/disks/myvmss_8f9b10a7_OsDisk_1_a445bcbfa3da487fb01ca4d9a0fb8917 # disk URI from the VMSS instance in portal
```

```
# resource.rp.microsoft.compute/disks.os-disk.vm.vmss.k8s.aks
# To see the updated node pool tags on the OS disk of an existing node pool, you need to create a new VM instance, such as by performing a node image upgrade.

Portal: Cost Management: lists resources including the node pool VM instance and the OS disk with their tags

az vmss list-instances -g MC_rgtag_aks_swedencentral -n aks-nodepool1-30351815-vmss \
                       --query "[].{InstanceId:instanceId, OS_Disk:storageProfile.osDisk.managedDisk.id}" \
                       --output table # has rows
```

```
# resource.rp.microsoft.containerservice.nodepool

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --tags appversion=0.0.2 costcenter=4444

az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query tags
```


