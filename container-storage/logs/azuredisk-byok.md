The provided code snippet demonstrates the creation and configuration of Azure Disk encryption resources, including a key vault, key, disk encryption set, and an AKS cluster with disk encryption set integration with BYOK (Bring Your Own Key).

```
# Replace the below with appropriate values.
rgname=
clustername=
keyvaultName=
keyvaultResourceGroupName=
keyName=ContosoFirstKey
```

```
# Key vault and key.
az keyvault create -g $keyvaultResourceGroupName -n $keyvaultName --enable-purge-protection true --retention-days 7
az keyvault key create --vault-name $keyvaultName --name $keyName --protection software
keyVaultId=$(az keyvault show --name $keyvaultName --query "[id]" -o tsv)
keyVaultKeyUrl=$(az keyvault key show --vault-name $keyvaultName --name $keyName --query "[key.kid]" -o tsv)

# disk-encryption-set.
az disk-encryption-set create -n myDiskEncryptionSetName  -g $rgname --source-vault $keyVaultId --key-url $keyVaultKeyUrl
desIdentity=$(az disk-encryption-set show -n myDiskEncryptionSetName  -g $rgname --query "[identity.principalId]" -o tsv)
az keyvault set-policy -g $keyvaultResourceGroupName -n $keyvaultName --object-id $desIdentity --key-permissions wrapkey unwrapkey get

# cluster.
diskEncryptionSetId=$(az disk-encryption-set show -n mydiskEncryptionSetName -g $rgname --query "[id]" -o tsv)
az aks create -g $rgname -n $clustername --node-osdisk-diskencryptionset-id $diskEncryptionSetId # --node-osdisk-type Ephemeral -s Standard_DS3_v2
```

To verify, you can use the following command:

```
az aks show -g $rgname -n $clustername --query diskEncryptionSetId -otsv

# Here is a sample output below.
# The behavior of this command has been altered by the following extension: aks-preview
# /subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/diskEncryptionSetResourceGroupName/providers/Microsoft.Compute/diskEncryptionSets/myDiskEncryptionSetName
```

```
# This is an optional vmss command. Replace the name of the VM Scale Set and the instance ID in the following command.
nodeResourceGroupName=$(az aks show -g $rgname -n $clustername --query nodeResourceGroup -otsv)
az vmss show -g $nodeResourceGroupName -n aks-nodepool1-18780979-vmss --instance-id 0 --query storageProfile.osDisk.managedDisk.diskEncryptionSet

# Here is a sample output below.
# {
#   "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/diskEncryptionSetResourceGroupName/providers/Microsoft.Compute/diskEncryptionSets/myDiskEncryptionSetName",
#   "resourceGroup": "diskEncryptionSetResourceGroupName"
# }

# Alternatively, when navigating to the "Disks" section of the VM Scale Set in the portal, the OS Disk Encryption is shown as "SSE with CMK" (Customer Managed Key) instead of "SSE with PMK" (Platform Managed Key).
```

Here are some related links:

- [aks/azure-disk-customer-managed-keys](https://learn.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys)
- [key-vault/adding-a-key-secret](https://learn.microsoft.com/en-us/azure/key-vault/general/manage-with-cli2#adding-a-key-secret-or-certificate-to-the-key-vault)
- [information-protection/byok-price-restrictions](https://learn.microsoft.com/en-us/azure/information-protection/byok-price-restrictions)
- [virtual-machines/disk-encryption#customer-managed-keys](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption#customer-managed-keys)
- [virtual-machines/disk-encryption#encryption-at-host---end-to-end-encryption-for-your-vm-data](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption#encryption-at-host---end-to-end-encryption-for-your-vm-data)
- [virtual-machines/ephemeral-os-disks#customer-managed-key](https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks#customer-managed-key).
