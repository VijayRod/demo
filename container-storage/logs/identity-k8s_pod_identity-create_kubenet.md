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

# Here is a sample output below
{
  "allowNetworkPluginKubenet": true,
  "enabled": true,
  "userAssignedIdentities": null,
  "userAssignedIdentityExceptions": null
}
```
