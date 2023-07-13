```
# Replace the below with appropriate values
rgname=
clustername=akskube
```

```
# Create an AKS cluster with Kubenet network plugin
az aks create -g $rgname -n $clustername --enable-pod-identity --enable-pod-identity-with-kubenet
```

```
# To view the pod identity profile
az aks show -g $rgname -n $clustername --query podIdentityProfile
```

```
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
