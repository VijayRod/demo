This page utilizes the creation steps mentioned in the following Microsoft Azure documentation: https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-aks-quickstart?tabs=cli. For additional information, you can refer to the [update](https://azure.microsoft.com/en-us/updates/public-preview-azure-container-storage/) and the [blog](https://azure.microsoft.com/en-us/blog/transforming-containerized-applications-with-azure-container-storage-now-in-preview/).

```
# Replace values in the below.
rgname=resourceGroupName
clustername=clusterName
nodepoolname=npacstor
```

```
# Cluster create.
az aks create -g $rgname -n $clustername -l westeurope # Optionally with region.

# Nodepool create.
az aks nodepool add -g $rgname --cluster-name $clustername -n $nodepoolname -s Standard_D4s_v5  --node-count 3 --labels acstor.azure.com/io-engine=acstor --node-osdisk-type Ephemeral --mode user ## Required minimum of three nodes, four virtual CPUs (vCPUs), and the label.

# Role assignment create.
export AKS_MI_OBJECT_ID=$(az aks show -g $rgname -n $clustername --query "identityProfile.kubeletidentity.objectId" -o tsv)
export AKS_NODE_RG=$(az aks show -g $rgname --n $clustername  --query "nodeResourceGroup" -o tsv)
az role assignment create --assignee $AKS_MI_OBJECT_ID --role "Contributor" --resource-group "$AKS_NODE_RG"

# azurecontainerstorage extension create.
az k8s-extension create --cluster-type managedClusters -g $rgname --cluster-name $clustername --name azurecontainerstorage --extension-type microsoft.azurecontainerstorage --scope cluster --release-train prod --release-namespace acstor
az k8s-extension list --cluster-type managedClusters -g $rgname --cluster-name $clustername
```

```
# Miscellaneous notes.
# az aks nodepool update -g $rgname --cluster-name $clustername -n $nodepoolname --labels acstor.azure.com/io-engine=acstor
# az aks nodepool show -g $rgname --cluster-name $clustername -n $nodepoolname --query nodeLabels | grep acstor ## Has output "acstor.azure.com/io-engine": "acstor"
```

Wait for ProvisioningState=Succeeded for the installed extension.

```
az k8s-extension list --cluster-type managedClusters -g $rgname --cluster-name $clustername -otable
```

```
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

kubectl get no --selector=acstor.azure.com/io-engine=acstor

# Here is a sample output below.
# NAME                               STATUS   ROLES   AGE   VERSION
# aks-npacstor-26728444-vmss000000   Ready    agent   30m   v1.25.6
# aks-npacstor-26728444-vmss000001   Ready    agent   30m   v1.25.6
# aks-npacstor-26728444-vmss000002   Ready    agent   30m   v1.25.6

kubectl api-versions | grep containerstorage

# Here is a sample output below.
# containerstorage.azure.com/v1alpha1
```
