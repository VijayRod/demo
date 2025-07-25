- https://learn.microsoft.com/en-us/azure/aks/concepts-network-isolated

```
# network-isolated
rg=rgisolate
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize --bootstrap-artifact-source Cache
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A
```
- https://learn.microsoft.com/en-us/azure/aks/network-isolated

```
# network-isolated.outbound-type=none.private-cluster (aka Private link-based)
rg=rgprivate
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize --bootstrap-artifact-source Cache --outbound-type none --network-plugin azure --enable-private-cluster
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A
```
- https://learn.microsoft.com/en-us/azure/aks/network-isolated?pivots=aks-managed-acr#private-link-based
