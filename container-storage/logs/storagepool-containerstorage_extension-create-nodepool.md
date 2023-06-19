This page follows the steps outlined in https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-aks-quickstart?tabs=cli, incorporating the addition of the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md).

```
# Replace values in the below.
rgname=resourceGroupName
clustername=clusterName
nodepoolname=npacstor
```

```
# Create a node pool to associate with Azure Container Storage.
az aks nodepool add -g $rgname --cluster-name $clustername -n $nodepoolname -s Standard_D8s_v3 --node-count 3 --labels acstor.azure.com/io-engine=acstor --node-osdisk-type Ephemeral --mode user ## Required minimum of three nodes, four virtual CPUs (vCPUs), and the label.
```

```
# Get cluster credentials.
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

# List the nodes associated with Azure Container Storage.
kubectl get no --selector=acstor.azure.com/io-engine=acstor

# Here is a sample output below.
# NAME                               STATUS   ROLES   AGE   VERSION
# aks-npacstor-26728444-vmss000000   Ready    agent   30m   v1.25.6
# aks-npacstor-26728444-vmss000001   Ready    agent   30m   v1.25.6
# aks-npacstor-26728444-vmss000002   Ready    agent   30m   v1.25.6

# Miscellaneous commands.
# az aks nodepool update -g $rgname --cluster-name $clustername -n $nodepoolname --labels acstor.azure.com/io-engine=acstor
# az aks nodepool show -g $rgname --cluster-name $clustername -n $nodepoolname --query nodeLabels | grep acstor ## Has output "acstor.azure.com/io-engine": "acstor"
```
