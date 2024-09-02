```
servicebus="servicebus$RANDOM"
az servicebus namespace create -g $rg -n $servicebus --sku Basic
az servicebus namespace show -g $rg -n $servicebus --query serviceBusEndpoint -otsv
echo $servicebus
```
