RCA: The steps below are after creating a cluster with customer-managed keys to use for encryption at rest for the OS disk. As indicated in https://learn.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys#encrypt-your-aks-cluster-data-disk, the managed identity needs to have contributor access to the resource group where the diskencryptionset is deployed.

```
# Replace the below with appropriate values.
diskEncryptionSet2=myDiskEncryptionSet2
diskEncryptionSet2ResourceGroup=
subId=$(az account show --query id -otsv)
```

```
# To create the disk encryption set
az disk-encryption-set create -n $diskEncryptionSet2  -g $diskEncryptionSet2ResourceGroup --source-vault $keyVaultId --key-url $keyVaultKeyUrl
diskEncryptionSetId2=$(az disk-encryption-set show -n $diskEncryptionSet2 -g $diskEncryptionSet2ResourceGroup --query "[id]" -o tsv)
```

```
# To create the storage class
cat << EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1  
metadata:
  name: byok
provisioner: disk.csi.azure.com # replace with "kubernetes.io/azure-disk" if aks version is less than 1.21
parameters:
  skuname: StandardSSD_LRS
  kind: managed
  diskEncryptionSetID: "/subscriptions/$subId/resourceGroups/$diskEncryptionSet2ResourceGroup/providers/Microsoft.Compute/diskEncryptionSets/$diskEncryptionSet2"
EOF

# To display the storage class
kubectl get sc byok

# Here is a sample output below.
NAME   PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
byok   disk.csi.azure.com   Delete          Immediate           false                  13s
```

Here's a sample pvc create to test this.

```
# To test with a sample pvc create.
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: azure-byok-disk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: byok
  resources:
    requests:
      storage: 5Gi
EOF

# To describe the pvc
k describe pvc azure-byok-disk

# Here is a sample output below.
Status:        Pending
  Warning  ProvisioningFailed    8s (x4 over 16s)   disk.csi.azure.com_csi-azuredisk-controller-554f75f97f-wg84t_d748f8d0-3341-44c8-8efd-ade2a1c5f39f  failed to provision volume with StorageClass "byok": rpc error: code = Internal desc = Retriable: false, RetryAfter: 0s, HTTPStatusCode: 403, RawError: {"error":{"code":"LinkedAuthorizationFailed","message":"The client 'dde4ce70-6d1b-4865-bb97-aa7011462339' with object id 'dde4ce70-6d1b-4865-bb97-aa7011462339' has permission to perform action 'Microsoft.Compute/disks/write' on scope '/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/mc_secureshack2_aksencrypt_swedencentral/providers/Microsoft.Compute/disks/pvc-04c417de-4da4-4060-86c8-d965d85e8a1a'; however, it does not have permission to perform action 'read' on the linked scope(s) '/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/resourceGroupName/providers/Microsoft.Compute/diskEncryptionSets/diskEncryptionSet2' or the linked scope(s) are invalid."}}
  
# After some time, the describe may only have the below.
  Normal  ExternalProvisioning  4m9s (x542 over 139m)  persistentvolume-controller                                                                        waiting for a volume to be created, either by external provisioner "disk.csi.azure.com" or manually created by system administrator
  Normal  Provisioning          3m37s (x44 over 139m)  disk.csi.azure.com_csi-azuredisk-controller-554f75f97f-wg84t_d748f8d0-3341-44c8-8efd-ade2a1c5f39f  External provisioner is provisioning volume for claim "default/azure-byok-disk"
  
kubectl describe po mypod
Status:           Pending
  Warning  FailedScheduling  18m (x23 over 133m)  default-scheduler  0/3 nodes are available: 3 pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.
```

Run the below with appropriate values to resolve this.

```
objectId=dummyo-6d1b-4865-bb97-aa7011462339
assignmentScope="/subscriptions/$subId/resourceGroups/$diskEncryptionSet2ResourceGroup"

az role assignment create --assignee $objectId --role "Contributor" --scope $assignmentScope
```

```
# To cleanup
kubectl delete pvc azure-byok-disk
kubectl delete sc byok
```
