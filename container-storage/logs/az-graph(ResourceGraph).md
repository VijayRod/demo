```
az graph query --graph-query "Resources | where resourceGroup =~ 'rg' | project id, name, type, tags"
tbd az graph query -q "where type =~ 'Microsoft.Compute' | project name, tags"
```

- https://learn.microsoft.com/en-us/cli/azure/graph?view=azure-cli-latest
- https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview: Azure Resource Graph is an Azure service designed to extend Azure Resource Management by providing efficient and performant resource exploration.
- https://learn.microsoft.com/en-us/azure/governance/resource-graph/first-query-azurecli
