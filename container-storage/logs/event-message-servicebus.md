```
servicebus="servicebus$RANDOM"
az servicebus namespace create -g $rg -n $servicebus --sku Basic
az servicebus namespace show -g $rg -n $servicebus --query serviceBusEndpoint -otsv
echo $servicebus
```

- https://learn.microsoft.com/en-us/azure/service-bus-messaging/compare-messaging-services#azure-service-bus
- https://stackoverflow.com/questions/57740782/message-bus-vs-service-bus-vs-event-hub-vs-event-grid
- https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-quickstart-cli
