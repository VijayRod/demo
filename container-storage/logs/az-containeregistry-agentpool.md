```
rg=rg
acr="acr$RANDOM$RANDOM"
az acr create -g $rg -n $acr --sku premium # -l eastus
az acr agentpool create -r $acr -n agentpool --tier S2
```

```
az acr agentpool show -r $acr -n agentpool --query id -otsv
/subscriptions//subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/acr80488485/agentPools/agentpool

az acr agentpool delete -r $acr -n agentpool -y
az acr delete -g $rg -n $acr -y
```

- https://learn.microsoft.com/en-us/azure/container-registry/tasks-agent-pools
