```
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query nodeTaints # default value is "nodeTaints": null,
  
kubectl describe po -n kube-system -l k8s-app=kube-dns # Tolerations:                 CriticalAddonsOnly op=Exists
```

- https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#add-a-dedicated-system-node-pool-to-an-existing-aks-cluster
