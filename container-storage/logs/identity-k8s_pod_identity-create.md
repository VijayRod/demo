This uses steps from https://learn.microsoft.com/en-us/azure/aks/use-azure-ad-pod-identity.

```
rg=rgident
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-pod-identity --network-plugin azure -s $vmsize -c 1
# az aks update -g $rg -n aks --enable-pod-identity
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks show -g $rg -n aks --query podIdentityProfile
{
  "allowNetworkPluginKubenet": false,
  "enabled": true,
  "userAssignedIdentities": null,
  "userAssignedIdentityExceptions": null
}
```

```
# Replace the below with appropriate values
rgname=$rg
clustername=akskube
export IDENTITY_RESOURCE_GROUP=$rgname
export IDENTITY_NAME="application-identity"
export SUBSCRIPTION_ID=$(az account show --query id -otsv)

# To create an identity
az identity create --resource-group ${IDENTITY_RESOURCE_GROUP} --name ${IDENTITY_NAME}
export IDENTITY_CLIENT_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME} --query clientId -otsv)"
export IDENTITY_RESOURCE_ID="$(az identity show -g ${IDENTITY_RESOURCE_GROUP} -n ${IDENTITY_NAME} --query id -otsv)"

# To obtain the name of the resource group containing the Virtual Machine Scale set of your AKS cluster, commonly called the node resource group
NODE_GROUP=$(az aks show -g $rgname -n $clustername --query nodeResourceGroup -o tsv)

# To obtain the id of the node resource group 
NODES_RESOURCE_ID=$(az group show -n $NODE_GROUP -o tsv --query "id")

# To create a role assignment granting your managed identity permissions on the node resource group
az role assignment create --role "Virtual Machine Contributor" --assignee "$IDENTITY_CLIENT_ID" --scope $NODES_RESOURCE_ID

# To create a pod identity
export POD_IDENTITY_NAME="my-pod-identity"
export POD_IDENTITY_NAMESPACE="my-app"
az aks pod-identity add --resource-group ${IDENTITY_RESOURCE_GROUP} --cluster-name $clustername --namespace ${POD_IDENTITY_NAMESPACE}  --name ${POD_IDENTITY_NAME} --identity-resource-id ${IDENTITY_RESOURCE_ID}
```

```
# To deploy a sample application. TBDc - This must be in the same namespace defined using "az aks pod-identity", else the output of "kubectl logs demo" includes a 404 with "no azure identity found for request clientID".
az aks get-credentials -g $rgname -n $clustername --overwrite-existing
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: demo
  namespace: $POD_IDENTITY_NAMESPACE
  labels:
    aadpodidbinding: $POD_IDENTITY_NAME
spec:
  containers:
  - name: demo
    image: mcr.microsoft.com/oss/azure/aad-pod-identity/demo:v1.6.3
    args:
      - --subscriptionid=$SUBSCRIPTION_ID
      - --clientid=$IDENTITY_CLIENT_ID
      - --resourcegroup=$IDENTITY_RESOURCE_GROUP
    env:
      - name: MY_POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: MY_POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: MY_POD_IP
        valueFrom:
          fieldRef:
            fieldPath: status.podIP
  nodeSelector:
    kubernetes.io/os: linux
EOF
```

```
# To view the pod identity profile
az aks show -g $rgname -n $clustername --query podIdentityProfile

# Here is a sample output below
{
  "allowNetworkPluginKubenet": true,
  "enabled": true,
  "userAssignedIdentities": [
    {
      "bindingSelector": null,
      "identity": {
        "clientId": "dummyc-111-111-111-111111111111",
        "objectId": "dummyo-111-111-111-111111111111",
        "resourceId": "/subscriptions/dummys-111-111-111-111111111111/resourcegroups/secureshack2/providers/Microsoft.ManagedIdentity/userAssignedIdentities/application-identity"
      },
      "name": "my-pod-identity",
      "namespace": "my-app",
      "provisioningInfo": null,
      "provisioningState": "Assigned"
    }
  ],
  "userAssignedIdentityExceptions": null
}
```

```    
# To view the created Azure identity and identity binding
kubectl get azureidentity -n $POD_IDENTITY_NAMESPACE
kubectl get azureidentitybinding -n $POD_IDENTITY_NAMESPACE
    
# To view the logs of the demo pod
kubectl logs demo --follow --namespace $POD_IDENTITY_NAMESPACE

# Here is a sample output below
successfully doARMOperations vm count 0
successfully acquired a token using the MSI, msiEndpoint(http://169.254.169.254/metadata/identity/oauth2/token)
successfully acquired a token, userAssignedID MSI, msiEndpoint(http://169.254.169.254/metadata/identity/oauth2/token) clientID(xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
successfully made GET on instance metadata
```
