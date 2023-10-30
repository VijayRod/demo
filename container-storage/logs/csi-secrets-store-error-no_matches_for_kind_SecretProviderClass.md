<b>RCA</b>: When attempting to create a SecretProviderClass in a cluster without the Key Vault addon, you may encounter the error message `no matches for kind "SecretProviderClass"`. To resolve this, ensure that the addon is installed or enable it using the command `az aks enable-addons --addons azure-keyvault-secrets-provider --name myAKSCluster --resource-group myResourceGroup`, and then retry adding the SecretProviderClass.

```
cat << EOF | kubectl apply -f -
# This is a SecretProviderClass example using user-assigned identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-user-msi
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "true"          # Set to true for using managed identity
    userAssignedIdentityID: dummyid1-1111-1111-1111-111111111111   # Set the clientID of the user-assigned managed identity to use
    keyvaultName: dummyname        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: secret1
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
    tenantId: dummyid1-1111-1111-1111-111111111111                 # The tenant ID of the key vault
EOF
```

<b>Output</b>:

The following error is returned:

```
error: resource mapping not found for name: "azure-kvname-user-msi" namespace: "" from "STDIN": no matches for kind "SecretProviderClass" in version "secrets-store.csi.x-k8s.io/v1"
ensure CRDs are installed first
```

No rows are returned with the following commands:

```
kubectl get crd | grep secrets-store

az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider
```
