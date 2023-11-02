```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az ml workspace create -g $rg -n workspace
workspaceId=$(az ml workspace show -g $rg -n workspace --query id -otsv)
echo $workspaceId

TBD (InvalidParameter properties.roles) az aks trustedaccess rolebinding create -g $rg --cluster-name aks -n test-binding --source-resource-id $workspaceId --roles Microsoft.MachineLearningServices/workspaces
```

```
TBD (InvalidParameter properties.roles) az aks trustedaccess rolebinding update -g $rg --cluster-name aks -n test-binding --source-resource-id $workspaceId --roles Microsoft.MachineLearningServices/workspaces

az aks trustedaccess rolebinding show -g $rg --cluster-name aks --name test-binding
az aks trustedaccess rolebinding list -g $rg --cluster-name aks
az aks trustedaccess rolebinding delete -g $rg --cluster-name aks --name test-binding
```

- https://learn.microsoft.com/en-us/azure/aks/trusted-access-feature
