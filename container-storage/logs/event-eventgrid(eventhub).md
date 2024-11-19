## eventgrid

```
eventhub_namespace="eventhub$RANDOM"
az eventhubs namespace create -g $rg -n $eventhub_namespace
az eventhubs eventhub create -g $rg -n MyEventGridHub --namespace-name $eventhub_namespace

az eventhubs namespace show -g $rg -n $eventhub_namespace --query id -otsv # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg2/providers/Microsoft.EventHub/namespaces/eventhub11644
az eventhubs eventhub show -g $rg -n MyEventGridHub --namespace-name $eventhub_namespace --query id -otsv # /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg2/providers/Microsoft.EventHub/namespaces/eventhub11644/eventhubs/MyEventGridHub

az eventgrid event-subscription create --name MyEventGridSubscription --source-resource-id $SOURCE_RESOURCE_ID --endpoint-type eventhub --endpoint $ENDPOINT
az eventgrid event-subscription list --source-resource-id $SOURCE_RESOURCE_ID
```

- https://learn.microsoft.com/en-us/azure/service-bus-messaging/compare-messaging-services#azure-event-grid
- https://stackoverflow.com/questions/57740782/message-bus-vs-service-bus-vs-event-hub-vs-event-grid
- https://learn.microsoft.com/en-us/azure/event-grid/overview
- https://learn.microsoft.com/en-us/cli/azure/eventgrid?view=azure-cli-latest
- https://azure.microsoft.com/en-us/products/event-grid
- https://azure.microsoft.com/en-us/pricing/details/event-grid/

## eventgrid.app.aks

```
eventhub_namespace="eventhub$RANDOM"
az eventhubs namespace create -g $rg -n $eventhub_namespace
az eventhubs eventhub create -g $rg -n MyEventGridHub --namespace-name $eventhub_namespace

SOURCE_RESOURCE_ID=$(az aks show -g $rg -n aks --query id --output tsv)
ENDPOINT=$(az eventhubs eventhub show -g $rg -n MyEventGridHub --namespace-name $eventhub_namespace --query id --output tsv)
az eventgrid event-subscription create --name MyEventGridSubscription --source-resource-id $SOURCE_RESOURCE_ID --endpoint-type eventhub --endpoint $ENDPOINT

az eventgrid event-subscription list --source-resource-id $SOURCE_RESOURCE_ID
    "filter": {
      "advancedFilters": null,
      "enableAdvancedFilteringOnArrays": null,
      "includedEventTypes": [
        "Microsoft.ContainerService.NewKubernetesVersionAvailable",
        "Microsoft.ContainerService.ClusterSupportEnded",
        "Microsoft.ContainerService.ClusterSupportEnding",
        "Microsoft.ContainerService.NodePoolRollingStarted",
        "Microsoft.ContainerService.NodePoolRollingSucceeded",
        "Microsoft.ContainerService.NodePoolRollingFailed"
```

- https://learn.microsoft.com/en-us/azure/aks/quickstart-event-grid?tabs=azure-cli

## eventgrid.schema

- https://learn.microsoft.com/en-us/azure/event-grid/event-schema

## eventgrid.sdk
- https://learn.microsoft.com/en-us/azure/event-grid/sdk-overview
