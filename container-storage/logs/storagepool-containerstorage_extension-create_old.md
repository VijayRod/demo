This page utilizes the creation steps mentioned in the following Microsoft Azure documentation: https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-aks-quickstart?tabs=cli. For additional information, you can refer to the [update](https://azure.microsoft.com/en-us/updates/public-preview-azure-container-storage/) and the [blog](https://azure.microsoft.com/en-us/blog/transforming-containerized-applications-with-azure-container-storage-now-in-preview/). After creating installing the Azure Container Storage extension, proceed with creating a labeled node pool.

```
# Replace values in the below.
rgname=resourceGroupName
clustername=clusterName
nodepoolname=npacstor
```

```
# Create a cluster.
az aks create -g $rgname -n $clustername -l westeurope # Optionally with region.

# Create the role assignment.
export AKS_MI_OBJECT_ID=$(az aks show -g $rgname -n $clustername --query "identityProfile.kubeletidentity.objectId" -o tsv)
export AKS_NODE_RG=$(az aks show -g $rgname --n $clustername  --query "nodeResourceGroup" -o tsv)
az role assignment create --assignee $AKS_MI_OBJECT_ID --role "Contributor" --resource-group "$AKS_NODE_RG"
```

Install the Azure Container Storage extension.

```
# azurecontainerstorage extension create.
az k8s-extension create --cluster-type managedClusters -g $rgname --cluster-name $clustername --name azurecontainerstorage --extension-type microsoft.azurecontainerstorage --scope cluster --release-train prod --release-namespace acstor
az k8s-extension list --cluster-type managedClusters -g $rgname --cluster-name $clustername
```

Wait for ProvisioningState=Succeeded for the installed extension.

```
az k8s-extension list --cluster-type managedClusters -g $rgname --cluster-name $clustername -otable
```

```
kubectl api-versions | grep containerstorage

# Here is a sample output below.
# containerstorage.azure.com/v1alpha1
```
