```
# Replace the below with appropriate values
rgname=secureshack2
registry=imageshack
clustername=aksacr
```

```
# To create an ACR (Azure Container Registry)
az acr create -g $rgname -n $registry --sku basic

# To create a cluster
az aks create -g $rgname -n $clustername --attach-acr $registry
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
