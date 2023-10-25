```
rg=rgsec
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-pod-security-policy -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
TBD

az aks show -g $rg -n aks

kubectl get psp
kubectl get rolebindings default:privileged -n kube-system # -o yaml

kubectl get constrainttemplates # No rows. TBD
```

- https://learn.microsoft.com/en-us/azure/aks/use-pod-security-policies
