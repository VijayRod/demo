```
rg=rg
acr=imageshack # acr="acr$RANDOM$RANDOM"
az acr create -g $rg -n $acr --sku basic # -l eastus
```

```
az acr show -g $rg -n $acr --query id -otsv
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.ContainerRegistry/registries/imageshack

az acr check-name -n $acr
{
  "message": null,
  "nameAvailable": true,
  "reason": null
}

az acr delete -g $rg -n $acr -y
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-health-error-reference
- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-check-health
- https://learn.microsoft.com/en-us/rest/api/containerregistry/
- https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/checknameavailability
- https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcontainerregistry
