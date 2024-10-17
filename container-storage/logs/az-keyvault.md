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

## az-keyvault.hsm.key

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

## az-keyvault.hsm.role

```
az keyvault role assignment list --hsm-name $keyvaultName -o

assignee=$(az ad signed-in-user show --query userPrincipalName -otsv)
az keyvault role assignment create --hsm-name $keyvaultName --role "Managed HSM Crypto User" --assignee $assignee --scope /keys
```

- https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/role-management
- https://learn.microsoft.com/en-us/azure/key-vault/managed-hsm/built-in-roles#built-in-roles: Managed HSM Administrator. Not permitted to perform any key management operations.
