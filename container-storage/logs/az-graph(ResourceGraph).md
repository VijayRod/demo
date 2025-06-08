
- https://learn.microsoft.com/en-us/cli/azure/graph?view=azure-cli-latest
- https://learn.microsoft.com/en-us/azure/governance/resource-graph/overview: Azure Resource Graph is an Azure service designed to extend Azure Resource Management by providing efficient and performant resource exploration.
- https://learn.microsoft.com/en-us/azure/governance/resource-graph/first-query-azurecli

```
# graph..equivalent
az graph query -q "distinct type | order by type"
az graph query -q "resources | distinct type | order by type"
az graph query -q "
resources 
| distinct type
| order by type
"
```

```
# graph..portal
# portal: Azure Resource Graph Explorer, query - resources | limit 02
```

```
# graph.example

az graph query -q "limit 01"

az graph query --graph-query "Resources | where resourceGroup =~ 'rg' | project id, name, type, tags"

az graph query -q "where type =~ 'Microsoft.Compute' | project name, tags"

az graph query -q "Resources | where resourceGroup == '$rg'" --query "data[]" -o table # list resources in a resource group

az graph query -q "
resources
| where type == 'microsoft.containerservice/managedclusters'
| where name == 'aks'
| limit 01
"

token=$(az account get-access-token|jq -r .accessToken)
curl -X POST "https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2021-03-01" \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "subscriptions": ["$subId"],
  "query": "Resources | where resourceGroup == '$rg'"
}
EOF

az rest --method post --uri https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01 --body @request-body.json

az rest --method post \
  --uri "https://management.azure.com/providers/Microsoft.ResourceGraph/resources?api-version=2022-10-01" \
  --body '{
    "subscriptions": [\"$subId\"],
    "query": "Resources | where type =~ 'Microsoft.Compute/virtualmachinescalesets' | project name, location"
  }'
```
```
