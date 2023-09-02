```
# Replace the below with appropriate values
rgname=secureshack2
registry=imageshack
```

```
# To create a container registry
az acr create -g $rgname -n $registry --sku basic
```

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-health-error-reference
