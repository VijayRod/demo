FailedMount with SecretNotFound indicates that the key vault does not have a secret defined in the configured SecretProviderClass.

RCA: Verify that the secret "secret1" mentioned in the error exists in the key vault defined in the associated SecretProviderClass.

```
# Replace the below with appropriate values.
rgname=resourceGroupName
clustername=clusterName
keyvaultName=keyvaultName

userAssignedIdentityID=$(az aks show -g $rgname -n $clustername --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv)
tenantId=$(az aks show -g $rgname -n $clustername --query identity.tenantId -o tsv)

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
    userAssignedIdentityID: "$userAssignedIdentityID"   # Set the clientID of the user-assigned managed identity to use
    keyvaultName: "$keyvaultName"        # Set to the name of your key vault
    cloudName: ""                         # [OPTIONAL for Azure] if not provided, the Azure environment defaults to AzurePublicCloud
    objects:  |
      array:
        - |
          objectName: secret1
          objectType: secret              # object types: secret, key, or cert
          objectVersion: ""               # [OPTIONAL] object versions, default to latest if empty
        - |
          objectName: key1
          objectType: key
          objectVersion: ""
    tenantId: "$tenantId"                 # The tenant ID of the key vault
---
# This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
kind: Pod
apiVersion: v1
metadata:
  name: busybox-secrets-store-inline-user-msi
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-1
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "azure-kvname-user-msi"
EOF

kubectl get po busybox-secrets-store-inline-user-msi

NAME                                    READY   STATUS              RESTARTS   AGE
busybox-secrets-store-inline-user-msi   0/1     ContainerCreating   0          34m

kubectl describe po busybox-secrets-store-inline-user-msi

Warning  FailedMount  5m38s (x9 over 26m)  kubelet            Unable to attach or mount volumes: unmounted volumes=[secrets-store01-inline], unattached volumes=[secrets-store01-inline kube-api-access-n68bh]: timed out waiting for the condition
Warning  FailedMount  91s (x21 over 28m)   kubelet            MountVolume.SetUp failed for volume "secrets-store01-inline" : rpc error: code = Unknown desc = failed to mount secrets store objects for pod default/busybox-secrets-store-inline-user-msi, err: rpc error: code = Unknown desc = failed to mount objects, error: failed to get objectType:secret, objectName:secret1, objectVersion:: keyvault.BaseClient#GetSecret: Failure responding to request: StatusCode=404 -- Original Error: autorest/azure: Service returned an error. Status=404 Code="SecretNotFound" Message="A secret with (name/id) secret1 was not found in this key vault. If you recently deleted this secret you may be able to recover it using the correct recovery command. For help resolving this issue, please see https://go.microsoft.com/fwlink/?linkid=2125182"

# Cleanup
kubectl delete po busybox-secrets-store-inline-user-msi --force
kubectl delete SecretProviderClass azure-kvname-user-msi
```
