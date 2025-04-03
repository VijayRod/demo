## k8s-aks-api_rest

```
token=$(az account get-access-token|jq -r .accessToken)
curl -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/providers/Microsoft.ContainerService/managedClusters?api-version=2025-01-01|jq -r .value.[].id # list resource IDs of the clusters in this sub
curl -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/providers/Microsoft.ContainerService/managedClusters?api-version=2025-01-01|jq -r .value.[1].properties.agentPoolProfiles.[].count # 0 for a stopped cluster
```

```
token=$(az account get-access-token|jq -r .accessToken)
clusterNames=`curl -s -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/providers/Microsoft.ContainerService/managedClusters?api-version=2025-01-01 | jq -r ' .value[].name '`
for cluster in $clusterNames; do
echo "Cluster: $cluster"
echo "From agentPoolProfiles:"
curl -s -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/providers/Microsoft.ContainerService/managedClusters?api-version=2025-01-01 | jq -c --arg cluster "$cluster" '.value[] | select(.name==$cluster)' | jq -r '.properties.agentPoolProfiles[] |  .name, .count'
done
date
```

> ## rest.app.ContainerService/managedCluster (aks)

- https://learn.microsoft.com/en-us/rest/api/aks/operation-groups

> ## rest.app.ContainerService/managedCluster.listClusterUserCredential

- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/list-cluster-user-credentials
- https://medium.com/@weinong/azure-kubernetes-service-built-in-roles-8083b90e7ba: Azure Kubernetes Service Cluster User Role
- https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles/containers#azure-kubernetes-service-cluster-user-role

> ## rest.CLI.az rest

- https://learn.microsoft.com/en-us/cli/azure/use-azure-cli-rest-command?tabs=bash

> ## rest.parameter.$filter

```
curl -s -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/resources?api-version=2018-05-01&`$filter=resourceType eq 'Microsoft.Compute/virtualMachineScaleSets'`

curl -s -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/resources?api-version=2018-05-01&`$filter=location eq '$loc'`
```
- https://stackoverflow.com/questions/45238148/azure-rest-api-location-filter: https://management.azure.com/subscriptions/{subscription-id}/resources?$filter=resourceType%20eq%20'Microsoft.Network/virtualnetworks'%20and%20location eq%20'ukwest'&api-version={api-version}

> ## rest.token.az

```
token=$(az account get-access-token|jq -r .accessToken)
curl -s -H "Authorization: Bearer $token" -X GET https://management.azure.com/subscriptions/$subId/providers/Microsoft.ContainerService/managedClusters?api-version=2025-01-01

```

> ## rest.token.portal

- https://jiasli.github.io/azure-notes/common/rest-curl.html
