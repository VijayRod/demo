This creates a managed user identity.

```
# Replace the below with appropriate values.
rgname=
identityName="myIdentity$RANDOM"
```

```
# To create the managed user identity
az identity create -g $rgname --name $identityName

# To retrieve the resource Uri
identityUri=$(az identity show -g $rgname --name $identityName --query id -otsv)
```

The managed user identity can be used to create an AKS cluster as indicated in https://learn.microsoft.com/en-us/azure/aks/use-managed-identity.

```
# To create an AKS cluster using the specified identity.
clustername=aksmsiuser
az aks create -g $rgname -n $clustername --enable-managed-identity --assign-identity $identityUri
```
