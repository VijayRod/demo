This uses commands from https://learn.microsoft.com/en-us/azure/aks/scale-down-mode.

```
# Replace values in the below.
rgname=
clustername=aks
nodepoolname=npretain
```

```
# To add a node pool with scale-down-mode set to deallocate
az aks nodepool add -g $rgname --cluster-name $clustername -n $nodepoolname --scale-down-mode deallocate
az aks get-credentials -g $rgname -n $clustername
kubectl get no -l agentpool=npretain

# Here is a sample output below
NAME                               STATUS   ROLES   AGE    VERSION
aks-npretain-86163545-vmss000000   Ready    agent   104s   v1.25.6
aks-npretain-86163545-vmss000001   Ready    agent   112s   v1.25.6
aks-npretain-86163545-vmss000002   Ready    agent   101s   v1.25.6
```

```
# To scale down the node pool. The deallocated nodes have a NotReady status for scale-down-mode deallocate.
az aks nodepool scale -g $rgname --cluster-name $clustername -n $nodepoolname -c 1
kubectl get no -l agentpool=npretain

# Here is a sample output below
NAME                               STATUS     ROLES   AGE     VERSION
aks-npretain-86163545-vmss000000   Ready      agent   6m47s   v1.25.6
aks-npretain-86163545-vmss000001   NotReady   agent   6m55s   v1.25.6
aks-npretain-86163545-vmss000002   NotReady   agent   6m44s   v1.25.6
```

```
# To update the scale-down-mode to delete. The (deallocated) scaled down nodes are deleted.
az aks nodepool update -g $rgname --cluster-name $clustername -n $nodepoolname --scale-down-mode delete
kubectl get no -l agentpool=npretain

# Here is a sample output below
NAME                               STATUS   ROLES   AGE   VERSION
aks-npretain-86163545-vmss000000   Ready    agent   10m   v1.25.6
```

```
# To display the scale-down-mode
az aks nodepool show -g $rgname --cluster-name $clustername -n $nodepoolname --query scaleDownMode -otsv

# Here is a sample output below
Delete
```

```
# To cleanup
az aks nodepool delete -g $rgname --cluster-name $clustername -n $nodepoolname --no-wait
```

https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-faq#what-s-the-difference-between-deleting-a-vm-in-a-virtual-machine-scale-set-and-deallocating-the-vm--when-should-i-choose-one-over-the-other-
