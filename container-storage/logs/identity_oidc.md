This uses steps in https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity.

```
# To export environmental variables
export RESOURCE_GROUP="secureshack2"
export LOCATION="westcentralus" # "For az identity federated-credential create" error "(MethodNotAllowed) The request format was unexpected : Support for federated identity credentials not enabled", refer https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-considerations#unsupported-regions-user-assigned-managed-identities
export SERVICE_ACCOUNT_NAMESPACE="default"
export SERVICE_ACCOUNT_NAME="workload-identity-sa"
export SUBSCRIPTION="$(az account show --query id --output tsv)"
export USER_ASSIGNED_IDENTITY_NAME="myIdentitywork"
export FEDERATED_IDENTITY_CREDENTIAL_NAME="myFedIdentitywork"
export KEYVAULT_NAME="azwi-kv-work$RANDOM"
export KEYVAULT_SECRET_NAME="my-secret"
export clustername=akswork
```

```
# To create an AKS cluster
az aks create -g "${RESOURCE_GROUP}" -n $clustername --node-count 1 --enable-oidc-issuer --enable-workload-identity -l "${LOCATION}"
export AKS_OIDC_ISSUER="$(az aks show -n $clustername -g "${RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" -otsv)"

# To create an Azure Key Vault and secret
az keyvault create --resource-group "${RESOURCE_GROUP}" --location "${LOCATION}" --name "${KEYVAULT_NAME}"
az keyvault secret set --vault-name "${KEYVAULT_NAME}" --name "${KEYVAULT_SECRET_NAME}" --value 'Hello!'
export KEYVAULT_URL="$(az keyvault show -g "${RESOURCE_GROUP}" -n ${KEYVAULT_NAME} --query properties.vaultUri -o tsv)"

# To create a managed identity and grant permissions to access the secret
az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${RESOURCE_GROUP}" --location "${LOCATION}" --subscription "${SUBSCRIPTION}"
sleep 30
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' -otsv)"
az keyvault set-policy --name "${KEYVAULT_NAME}" --secret-permissions get --spn "${USER_ASSIGNED_CLIENT_ID}"

# To create Kubernetes service account
az aks get-credentials -n $clustername -g "${RESOURCE_GROUP}" --overwrite-existing
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
EOF

# To establish federated identity credential
az identity federated-credential create --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} --identity-name ${USER_ASSIGNED_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP} --issuer ${AKS_OIDC_ISSUER} --subject system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_NAME}

# To deploy the workload
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: quick-start
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: ${SERVICE_ACCOUNT_NAME}
  containers:
    - image: ghcr.io/azure/azure-workload-identity/msal-go
      name: oidc
      env:
      - name: KEYVAULT_URL
        value: ${KEYVAULT_URL}
      - name: SECRET_NAME
        value: ${KEYVAULT_SECRET_NAME}
  nodeSelector:
    kubernetes.io/os: linux
EOF
```

```
# To check whether all properties are injected properly with the webhook
kubectl describe pod quick-start

# To verify the pod can get a token and access the secret from the Key Vault
# Sample output - I1013 22:49:29.872708       1 main.go:30] "successfully got secret" secret="Hello!"
kubectl logs quick-start
```

```
# To clean up
kubectl delete po quick-start
kubectl delete sa ${SERVICE_ACCOUNT_NAME} -n ${SERVICE_ACCOUNT_NAMESPACE}
```
