## k8s-aks-acr

```
# Replace the below with appropriate values
rgname=secureshack2
registry=imageshack
clustername=aksacr
az group create -n $rgname -l $loc
```

```
# To create an ACR (Azure Container Registry)
az acr create -g $rgname -n $registry --sku basic -s $vmsize -c 2

# To create a cluster
az aks create -g $rgname -n $clustername --attach-acr $registry -s $vmsize -c 2
az aks get-credentials -g $rgname -n $clustername

# To deploy a pod with an image from the registry
kubectl run ubuntu --image=$registry.azurecr.io/samples/ubuntu
```

```
# kubectl describe po ubuntu
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  14s               default-scheduler  Successfully assigned default/ubuntu to aks-nodepool1-31040111-vmss000000
  Normal   Pulled     10s               kubelet            Successfully pulled image "imageshack.azurecr.io/samples/ubuntu" in 3.027778658s (3.027782658s including waiting)
  Normal   Pulling    9s (x2 over 13s)  kubelet            Pulling image "imageshack.azurecr.io/samples/ubuntu"
  Normal   Created    9s (x2 over 10s)  kubelet            Created container ubuntu
  Normal   Pulled     9s                kubelet            Successfully pulled image "imageshack.azurecr.io/samples/ubuntu" in 100.976602ms (100.996702ms including waiting)
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-container-registry-integration

## k8s-aks-acr.debug

- https://learn.microsoft.com/en-us/azure/container-registry/container-registry-troubleshoot-login
  
## k8s-aks-acr.check-acr

```
# az aks check-acr -g $rgname -n $clustername --acr $registry
The login server endpoint suffix '.azurecr.io' is automatically appended.
[2023-08-03T12:36:46Z] Checking host name resolution (imageshack.azurecr.io): SUCCEEDED
[2023-08-03T12:36:46Z] Canonical name for ACR (imageshack.azurecr.io): r0726sec.swedencentral.cloudapp.azure.com.
[2023-08-03T12:36:46Z] ACR location: swedencentral
[2023-08-03T12:36:46Z] Checking managed identity...
[2023-08-03T12:36:46Z] Kubelet managed identity client ID: dummyi-959f-429a-94f9-c11f73867df8
[2023-08-03T12:36:46Z] Validating managed identity existance: SUCCEEDED
[2023-08-03T12:36:47Z] Validating image pull permission: SUCCEEDED
[2023-08-03T12:36:47Z]
Your cluster can pull images from imageshack.azurecr.io!

# az aks check-acr -g $rgname -n $clustername --acr $registry --node-name aks-nodepool1-31040111-vmss000005
The login server endpoint suffix '.azurecr.io' is automatically appended.
[2023-08-03T12:37:12Z] Checking host name resolution (imageshack.azurecr.io): SUCCEEDED
[2023-08-03T12:37:12Z] Canonical name for ACR (imageshack.azurecr.io): r0726sec.swedencentral.cloudapp.azure.com.
[2023-08-03T12:37:12Z] ACR location: swedencentral
[2023-08-03T12:37:12Z] Checking managed identity...
[2023-08-03T12:37:12Z] Kubelet managed identity client ID: dummyi-959f-429a-94f9-c11f73867df8
[2023-08-03T12:37:13Z] Validating managed identity existance: SUCCEEDED
[2023-08-03T12:37:13Z] Validating image pull permission: SUCCEEDED
[2023-08-03T12:37:13Z]
Your cluster can pull images from imageshack.azurecr.io!
```

## k8s-aks-acr.check-acr.canipull

- https://github.com/Azure/aks-canipull
- https://github.com/andyzhangx/demo/blob/master/aks/canipull/README.md - "deprecation: please use az aks check-acr (--node-name) command to throubleshoot ACR connection issue on specific AKS node"
