- https://external-secrets.io/provider-azure-key-vault/
- https://external-secrets.io/v0.4.4/guides-getting-started/
- https://github.com/external-secrets/external-secrets/

```
kubectl delete -f https://github.com/external-secrets/external-secrets/releases/download/v0.17.0/external-secrets.yaml
kubectl apply -f https://github.com/external-secrets/external-secrets/releases/download/v0.17.0/external-secrets.yaml
echo $keyvaultName
echo $tenantId

kubectl delete SecretStore azure-secrets
kubectl delete ExternalSecret my-secret
kubectl delete SecretProviderClass azure-kv-sync
kubectl apply -f -<<EOF
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: azure-secrets
spec:
  provider:
    azurekv:
      tenantId: "${tenantId}"
      vaultUrl: "https://${keyvaultName}.vault.azure.net/"
      authType: WorkloadIdentity
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: my-secret
spec:
  secretStoreRef:
    name: azure-secrets
  target:
    name: my-synced-secret
  data:
    - secretKey: password
      remoteRef:
        key: my-password-in-kv
---
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kv-sync
spec:
  provider: azure
  parameters:
    usePodIdentity: "true"
    keyvaultName: my-vault
    objects: |
      array:
        - objectName: my-secret
          objectType: secret
  secretObjects:
    - secretName: my-synced-secret
      type: Opaque
      data:
        - objectName: my-secret
          key: password
EOF
kubectl get SecretStore # InvalidProviderConfig: missing environment variables. AZURE_CLIENT_ID, AZURE_TENANT_ID and AZURE_FEDERATED_TOKEN_FILE must be set
kubectl get ExternalSecret
kubectl get SecretProviderClass
```
