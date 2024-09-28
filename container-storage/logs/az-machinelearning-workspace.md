```
rg=rg
az group create -n $rg -l $loc
az ml workspace create -g $rg -n workspace
```

```
az ml workspace show -g $rg -n workspace --query id -otsv
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.MachineLearningServices/workspaces/workspace
```

- https://learn.microsoft.com/en-us/azure/machine-learning/how-to-configure-cli?view=azureml-api-2&tabs=public#set-up
