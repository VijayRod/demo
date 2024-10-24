## identity-auth-openid_oidc_WorkloadIdentity.aks

```
export RESOURCE_GROUP=$rg
export LOCATION="swedencentral"
export CLUSTER_NAME="myAKSCluster"
export SERVICE_ACCOUNT_NAMESPACE="default"
export SERVICE_ACCOUNT_NAME="workload-identity-sa"
export SUBSCRIPTION="$(az account show --query id --output tsv)"
export USER_ASSIGNED_IDENTITY_NAME="myIdentity"
export FEDERATED_IDENTITY_CREDENTIAL_NAME="myFedIdentity"
# Include these variables to access key vault secrets from a pod in the cluster.
export KEYVAULT_NAME="keyvault-workload-id"
export KEYVAULT_SECRET_NAME="my-secret"

az group create --name "${RESOURCE_GROUP}" --location "${LOCATION}"

az aks create --resource-group "${RESOURCE_GROUP}" --name "${CLUSTER_NAME}" --enable-oidc-issuer --enable-workload-identity -s $vmsize -c 2

export AKS_OIDC_ISSUER="$(az aks show --name "${CLUSTER_NAME}" --resource-group "${RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" --output tsv)"

az identity create --name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${RESOURCE_GROUP}" --location "${LOCATION}" --subscription "${SUBSCRIPTION}"
export USER_ASSIGNED_CLIENT_ID="$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query 'clientId' --output tsv)"
sleep 30

az aks get-credentials --name "${CLUSTER_NAME}" --resource-group "${RESOURCE_GROUP}" --overwrite-existing
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: "${USER_ASSIGNED_CLIENT_ID}"
  name: "${SERVICE_ACCOUNT_NAME}"
  namespace: "${SERVICE_ACCOUNT_NAMESPACE}"
EOF

az identity federated-credential create --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} --identity-name "${USER_ASSIGNED_IDENTITY_NAME}" --resource-group "${RESOURCE_GROUP}" --issuer "${AKS_OIDC_ISSUER}" --subject system:serviceaccount:"${SERVICE_ACCOUNT_NAMESPACE}":"${SERVICE_ACCOUNT_NAME}" --audience api://AzureADTokenExchange

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sample-workload-identity
  namespace: ${SERVICE_ACCOUNT_NAMESPACE}
  labels:
    azure.workload.identity/use: "true"  # Required. Only pods with this label can use workload identity.
spec:
  serviceAccountName: ${SERVICE_ACCOUNT_NAME}
  containers:
    - image: nginx
      name: nginx
EOF
sleep 5
kubectl get po sample-workload-identity
```

- https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity
- https://azure.github.io/azure-workload-identity/docs/installation/managed-clusters.html

### identity-auth-openid_oidc_WorkloadIdentity.aks (earlier)

This uses steps in https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity.

```
# To export environmental variables
export RESOURCE_GROUP=$rg
export LOCATION="swedencentral" # (currently not necessary) "For az identity federated-credential create" error "(MethodNotAllowed) The request format was unexpected : Support for federated identity credentials not enabled", refer https://learn.microsoft.com/en-us/azure/active-directory/workload-identities/workload-identity-federation-considerations#unsupported-regions-user-assigned-managed-identities
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
az aks create -g "${RESOURCE_GROUP}" -n $clustername --enable-oidc-issuer --enable-workload-identity -s $vmsize -c 2 # -l "${LOCATION}"
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
sleep 5
kubectl logs quick-start
kubectl get po quick-start
```

```
# userIdentityId=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query id -otsv); echo $userIdentityId
# userIdentityName=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query name -otsv); echo $userIdentityName
# userIdentityPrincipalId=$(az identity show --resource-group "${RESOURCE_GROUP}" --name "${USER_ASSIGNED_IDENTITY_NAME}" --query principalId -otsv); echo $userIdentityPrincipalId

az aks show -g $rg -n akswork --query oidcIssuerProfile
The behavior of this command has been altered by the following extension: aks-preview
{
  "enabled": true,
  "issuerUrl": "https://westcentralus.oic.prod-aks.azure.com/redactt-1111-1111-1111-111111111111/redacti-1111-1111-1111-111111111111/"
}

az aks show -g $rg -n akswork --query securityProfile.workloadIdentity
The behavior of this command has been altered by the following extension: aks-preview
{
  "enabled": true
}

kubectl get all -n kube-system -l azure-workload-identity.io/system=true
NAME                                                       READY   STATUS    RESTARTS   AGE
pod/azure-wi-webhook-controller-manager-59959b4d95-k87hm   1/1     Running   0          100s
pod/azure-wi-webhook-controller-manager-59959b4d95-pk24m   1/1     Running   0          100s

NAME                                       TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/azure-wi-webhook-webhook-service   ClusterIP   10.0.45.159   <none>        443/TCP   100s

NAME                                                  READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/azure-wi-webhook-controller-manager   2/2     2            2           101s

NAME                                                             DESIRED   CURRENT   READY   AGE
replicaset.apps/azure-wi-webhook-controller-manager-59959b4d95   2         2         2       101s

# To check whether all properties are injected properly with the webhook
kubectl describe pod quick-start
    Environment:
      KEYVAULT_URL:                https://azwi-kv-work15212.vault.azure.net/
      SECRET_NAME:                 my-secret
      AZURE_CLIENT_ID:             redacti-1111-1111-1111-111111111111
      AZURE_TENANT_ID:             redactt-1111-1111-1111-111111111111
      AZURE_FEDERATED_TOKEN_FILE:  /var/run/secrets/azure/tokens/azure-identity-token
      AZURE_AUTHORITY_HOST:        https://login.microsoftonline.com/
    Mounts:
      /var/run/secrets/azure/tokens from azure-identity-token (ro)

# To verify the pod can get a token and access the secret from the Key Vault
# Sample output - I1013 22:49:29.872708       1 main.go:30] "successfully got secret" secret="Hello!"
kubectl logs quick-start
```

```
# To clean up
kubectl delete po quick-start
kubectl delete sa ${SERVICE_ACCOUNT_NAME} -n ${SERVICE_ACCOUNT_NAMESPACE}
```

- https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity
- https://azure.github.io/azure-workload-identity/docs/installation/managed-clusters.html

## identity-auth-openid_oidc_WorkloadIdentity.aks.keyvault

- https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#grant-permissions-to-access-azure-key-vault
