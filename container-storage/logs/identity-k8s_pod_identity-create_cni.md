```
# Replace the below with appropriate values
rgname=
clustername=aksidentcni
```

```
# Create an AKS cluster with Azure CNI network plugin
az aks create -g $rgname -n $clustername --enable-pod-identity --network-plugin azure
```

```
# To view the pod identity profile
az aks show -g $rgname -n $clustername --query podIdentityProfile

# Here is a sample output below
{
  "allowNetworkPluginKubenet": false,
  "enabled": true,
  "userAssignedIdentities": null,
  "userAssignedIdentityExceptions": null
}
```
