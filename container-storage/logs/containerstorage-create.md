This page utilizes the creation steps mentioned in the following Microsoft Azure documentation: https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-aks-quickstart?tabs=cli. For additional information, you can refer to the [update](https://azure.microsoft.com/en-us/updates/public-preview-azure-container-storage/) and the [blog](https://azure.microsoft.com/en-us/blog/transforming-containerized-applications-with-azure-container-storage-now-in-preview/).

```
# Replace values in the below.
rgname=resourceGroupName
clustername=clusterName
```

```
az aks create -g $rgname -n $clustername -s Standard_D4s_v5 -l westeurope # Minimum of four virtual CPUs (vCPUs). Optionally with region.

az aks nodepool update -g $rgname --cluster-name $clustername -n nodepool1 --labels acstor.azure.com/io-engine=acstor
# az aks nodepool show -g $rgname --cluster-name $clustername -n nodepool1 --query nodeLabels | grep acstor # Has output "acstor.azure.com/io-engine": "acstor"

export AKS_MI_OBJECT_ID=$(az aks show -g $rgname -n $clustername --query "identityProfile.kubeletidentity.objectId" -o tsv)
export AKS_NODE_RG=$(az aks show -g $rgname --n $clustername  --query "nodeResourceGroup" -o tsv)
az role assignment create --assignee $AKS_MI_OBJECT_ID --role "Contributor" --resource-group "$AKS_NODE_RG"

az k8s-extension create --cluster-type managedClusters -g $rgname --cluster-name $clustername --name azurecontainerstorage --extension-type microsoft.azurecontainerstorage --scope cluster --release-train prod --release-namespace acstor
az k8s-extension list --cluster-type managedClusters -g $rgname --cluster-name $clustername
```

Wait for ProvisioningState=Succeeded for the installed extension.

```
az k8s-extension list --cluster-type managedClusters -g $rgname --cluster-name $clustername -otable
```

```
az aks get-credentials -g $rgname -n $clustername --overwrite-existing
kubectl api-versions | grep containerstorage

# This returns -> containerstorage.azure.com/v1alpha1
```
