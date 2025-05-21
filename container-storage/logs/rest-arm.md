> # arm..core.resource.contract

- https://github.com/AzureExpert/azure-resource-manager-rpc

> # arm..core.resource..provisioningState
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md: The provisioningState field has three terminal states: Succeeded , Failed and Canceled. If the resource returns no provisioningState, it is assumed to be Succeeded.

> # arm..core.resource..regional-endpoint
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md: ARM will proxy the request to the appropriate region based on the resource's location.
  
> # arm..core.resource.op..async
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md: Asynchronous Operations
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/async-operations

> # arm..core.resource.op..http-202
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md:The asynchronous operation APIs frequently use the 202 Accepted status code and Location headers to indicate progress.

> # arm..core.resource.op..proxyrequest
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md: ARM will proxy requests to backing resource providers even if they are not related directly to resource management or subscription lifecycle changes. examples include: restart a VM
  
> # arm..core.resource.op.create/update
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md: 1. Respond to the initial PUT request with a 201 Created or 200 OK (per normal guidance); 2. Since provisioning is not complete, the PUT response body MUST contain a provisioningState set to a non-terminal value (e.g. "Accepted", or "Created");

> # arm..core.resource.op.delete
- https://github.com/AzureExpert/azure-resource-manager-rpc/blob/master/v1.0/Addendum.md: RP will receive a DELETE call on each individual tracked resource in that group. In some cases, the resources will have interdependencies and therefore can only be deleted in a certain order that ARM does not understand. To address this, ARM can simply ask each resource to delete in arbitrary order. If the resource refuses the deletion, then ARM will revisit it after trying to delete the rest of the group's resources. It will continue to revisit resources
Respond to the initial DELETE request with a 202 Accepted;
```
# ARM > RP
az resource show --ids /subscriptions/$subId/resourcegroups/rg/providers/Microsoft.ContainerService/managedClusters/aks --debug
urllib3.connectionpool: https://management.azure.com:443 "GET /subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/Microsoft.ContainerService/managedClusters/aks?api-version=2025-03-01 HTTP/1.1" 200 4532

# ARM only
az resource list -l swedencentral -otable --debug
cli.azure.cli.core.sdk.policies: Request URL: 'https://management.azure.com/subscriptions/redacts-1111-1111-1111-111111111111/resources?$filter=location%20eq%20%27swedencentral%27&$expand=createdTime%2CchangedTime%2CprovisioningState&api-version=2022-09-01'
```
