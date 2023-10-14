```
rg=rgnpm
az group create -n $rg -l $loc
az aks create -g $rg -n aks --network-plugin azure --network-policy azure -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
kubectl get po -n kube-system -l k8s-app=azure-npm
NAME              READY   STATUS    RESTARTS   AGE
azure-npm-z7tdq   1/1     Running   0          76m

kubectl get ds -n kube-system azure-npm
NAME        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
azure-npm   1         1         1       1            1           <none>          76m
```

- https://github.com/Azure/azure-container-networking/blob/master/docs/npm.md
- https://learn.microsoft.com/en-us/azure/aks/use-network-policies#network-policy-options-in-aks
