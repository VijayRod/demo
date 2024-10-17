## az-keyvault.hsm (managed hsm)

```
# most commands prefer the use of --hsm-name over -n.

# provision
oid=$(az ad signed-in-user show --query id -o tsv)
keyvaultName=mhsm$RANDOM
az keyvault create -g $rg --hsm-name $keyvaultName --administrators $oid --retention-days 7
keyVaultId=$(az keyvault show --hsm-name $keyvaultName --query "[id]" -o tsv) 
echo $keyVaultId # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.KeyVault/managedHSMs/mhsm23736

# activate
cd /tmp
mkdir certs
openssl req -newkey rsa:2048 -nodes -keyout cert_0.key -x509 -days 365 -out ./certs/cert_0.cer -batch # The -batch option skips additional prompts in our test setup.
openssl req -newkey rsa:2048 -nodes -keyout cert_1.key -x509 -days 365 -out ./certs/cert_1.cer -batch
openssl req -newkey rsa:2048 -nodes -keyout cert_2.key -x509 -days 365 -out ./certs/cert_2.cer -batch
ls ./certs
az keyvault security-domain download --hsm-name $keyvaultName --sd-wrapping-keys ./certs/cert_0.cer ./certs/cert_1.cer ./certs/cert_2.cer --sd-quorum 2 --security-domain-file ContosoMHSM-SD.json
```

- https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/quick-create-cli
- https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/overview

### az-keyvault.hsm.key

```
# https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/built-in-roles#built-in-roles: Managed HSM Administrator. Not permitted to perform any key management operations.
assignee=$(az ad signed-in-user show --query userPrincipalName -otsv)
az keyvault role assignment create --hsm-name $keyvaultName --role "Managed HSM Crypto User" --assignee $assignee --scope /keys

keyName=ContosoFirstKey
az keyvault key create --hsm-name $keyvaultName --name $keyName --protection software
keyVaultKeyUrl=$(az keyvault key show --hsm-name $keyvaultName --name $keyName --query "[key.kid]" -o tsv) 
echo $keyVaultKeyUrl # https://mhsm23735.managedhsm.azure.net/keys/ContosoFirstKey/ddc76a3635954bbe2f3ebfbbc7fb7613

az keyvault key list --hsm-name $keyvaultName
```

https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/key-management

### az-keyvault.hsm.role

```
az keyvault role assignment list --hsm-name $keyvaultName -o

assignee=$(az ad signed-in-user show --query userPrincipalName -otsv)
az keyvault role assignment create --hsm-name $keyvaultName --role "Managed HSM Crypto User" --assignee $assignee --scope /keys
```

- https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/role-management
- https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/built-in-roles#built-in-roles: Managed HSM Administrator. Not permitted to perform any key management operations.

# az-keyvault.hsm.example.aks

```
rg=rg
az group create -n $rg -l $loc

# https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/quick-create-cli#provision-a-managed-hsm
# These instructions are tailored for managed HSM setups.
oid=$(az ad signed-in-user show --query id -o tsv)
keyvaultName=mhsm$RANDOM
az keyvault create -g $rg --hsm-name $keyvaultName --administrators $oid --retention-days 7
keyVaultId=$(az keyvault show --hsm-name $keyvaultName --query "[id]" -o tsv) 
echo $keyVaultId # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.KeyVault/managedHSMs/mhsm23736

# https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/quick-create-cli#activate-your-managed-hsm
# These instructions are tailored for managed HSM setups.
cd /tmp
mkdir certs
openssl req -newkey rsa:2048 -nodes -keyout cert_0.key -x509 -days 365 -out ./certs/cert_0.cer -batch # The -batch option skips additional prompts in our test setup.
openssl req -newkey rsa:2048 -nodes -keyout cert_1.key -x509 -days 365 -out ./certs/cert_1.cer -batch
openssl req -newkey rsa:2048 -nodes -keyout cert_2.key -x509 -days 365 -out ./certs/cert_2.cer -batch
ls ./certs
az keyvault security-domain download --hsm-name $keyvaultName --sd-wrapping-keys ./certs/cert_0.cer ./certs/cert_1.cer ./certs/cert_2.cer --sd-quorum 2 --security-domain-file ContosoMHSM-SD.json

# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/disks-enable-customer-managed-keys-cli#azure-key-vault-managed-hsm
# These instructions are tailored for managed HSM setups.
rgName=$rg
keyVaultName=$keyvaultName
keyName=ContosoFirstKey
diskEncryptionSetName=yourDiskEncryptionSetName
az keyvault update-hsm -g $rgName --hsm-name $keyVaultName --enable-purge-protection true
## To avoid the "(AccessDenied) Not authorized to access Microsoft.KeyVault/managedHsm/keys/create on '/keys'" error when using "az keyvault key create", it's necessary to assign the "Managed HSM Crypto User" role to the user issuing this command.
## https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/built-in-roles#built-in-roles: Managed HSM Administrator. Not permitted to perform any key management operations.
assignee=$(az ad signed-in-user show --query userPrincipalName -otsv)
az keyvault role assignment create --hsm-name $keyvaultName --role "Managed HSM Crypto User" --assignee $assignee --scope /keys
## 
az keyvault key create --hsm-name $keyVaultName --name $keyName --ops wrapKey unwrapKey --kty RSA-HSM --size 2048
keyVaultKeyUrl=$(az keyvault key show --hsm-name $keyVaultName --name $keyName --query [key.kid] -o tsv)
az disk-encryption-set create -n $diskEncryptionSetName -g $rgName --key-url $keyVaultKeyUrl --enable-auto-key-rotation false
desIdentity=$(az disk-encryption-set show -n $diskEncryptionSetName -g $rgName --query [identity.principalId] -o tsv)
az keyvault role assignment create --hsm-name $keyVaultName --role "Managed HSM Crypto Service Encryption User" --assignee $desIdentity --scope /keys # switched to using hsm-name

# https://learn.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys#create-a-new-aks-cluster-and-encrypt-the-os-disk
diskEncryptionSetId=$(az disk-encryption-set show --name $diskEncryptionSetName --resource-group $rg --query "[id]" -o tsv)
az aks create -g $rg -n akshsm --node-osdisk-diskencryptionset-id $diskEncryptionSetId --node-vm-size $vmsize # updated command to mine
# az aks nodepool add --cluster-name akshsm --resource-group $rg --name np2 --node-osdisk-type Ephemeral
### You can also go to the "Disks" section of the VM Scale Set instance on the portal. There, you'll see that the OS disk Encryption is listed as "SSE with CMK" (Customer Managed Key) rather than "SSE with PMK" (Platform Managed Key), and there's a link that takes you directly to the managed HSM.

# It's necessary to follow these steps for data disks, even when using the same data encryption set.
# https://learn.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys#encrypt-your-aks-cluster-data-disk
aksIdentity=$(az aks show --resource-group $rg -n akshsm --query identity.principalId -otsv)
az role assignment create --role Contributor --assignee $aksIdentity --scope $diskEncryptionSetId
az aks get-credentials -g $rg -n akshsm --overwrite-existing # added the command
subId=$(az account show --query id -otsv)
k delete sc byok
cat << EOF | kubectl create -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: byok
provisioner: disk.csi.azure.com # replace with "kubernetes.io/azure-disk" if aks version is less than 1.21
parameters:
  skuname: StandardSSD_LRS
  kind: managed
  diskEncryptionSetID: /subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Compute/diskEncryptionSets/$diskEncryptionSetName
EOF
## https://learn.microsoft.com/en-us/azure/aks/azure-disk-customer-managed-keys#encrypt-your-aks-cluster-data-disk: The managed identity needs to have contributor access to the resource group where the diskencryptionset is deployed.
## Else k describe for a pod using an Azure Disk (aka data disk) encounters an error LinkedAuthorizationFailed indicating "it does not have permission to perform action(s) 'Microsoft.Compute/diskEncryptionSets/read'"
rgId=$(az group show -n $rg --query id -otsv)
az role assignment create --role Contributor --assignee $aksIdentity --scope $rgId

# Now, go ahead and set up a pod using an Azure disk, then check to make sure it's up and running.
### You can then go to the "Disks" section of the VM Scale Set instance on the portal. There, you'll see that the data disk Encryption is listed as "SSE with CMK" (Customer Managed Key) rather than "SSE with PMK" (Platform Managed Key), and there's a link that takes you directly to the managed HSM.

NAME                     READY   STATUS    RESTARTS   AGE
nginx-7f5df5b7dd-bfp87   1/1     Running   0          33s
```
