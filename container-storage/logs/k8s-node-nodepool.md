## nodepool.spec.scale-down-mode

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

- https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-faq#what-s-the-difference-between-deleting-a-vm-in-a-virtual-machine-scale-set-and-deallocating-the-vm--when-should-i-choose-one-over-the-other-

## nodepool.op.delete-machines

```
kubectl get no
az aks nodepool delete-machines -g $rg --cluster-name aks -n nodepool1 --machine-names aks-nodepool1-32689978-vmss000000 aks-nodepool1-32689978-vmss000001
kubectl get no
```

- https://learn.microsoft.com/en-us/azure/aks/manage-node-pools#remove-specific-vms-in-the-existing-node-pool

```
# Unsupported - The node was deleted using the VMSS API and isn't recreated with a cluster PUT command. kubectl get no & az aks nodepool show now automatically update to show only the remaining nodes.

rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 2
az aks get-credentials -g $rg -n aks --overwrite-existing
kubectl get no; kubectl get po -A

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss delete-instances -g $noderg --instance-ids 1 --name aks-nodepool1-36372875-vmss

### The node is marked NotReady and eventually removed. The pods on the node go into Terminating state and are deleted
kubectl get no; kubectl get po -A
NAME                                STATUS     ROLES    AGE     VERSION
aks-nodepool1-36372875-vmss000000   Ready      <none>   3m48s   v1.30.6
aks-nodepool1-36372875-vmss000001   NotReady   <none>   3m46s   v1.30.6
NAMESPACE     NAME                                 READY   STATUS        RESTARTS   AGE
kube-system   coredns-54b69f46b8-c6mss             1/1     Running       0          39s
kube-system   coredns-54b69f46b8-kcm9n             1/1     Running       0          4m12s
kube-system   coredns-54b69f46b8-s64c8             1/1     Terminating   0          3m5s
...
NAME                                STATUS   ROLES    AGE     VERSION
aks-nodepool1-36372875-vmss000000   Ready    <none>   8m57s   v1.30.6
NAMESPACE     NAME                                 READY   STATUS    RESTARTS   AGE
kube-system   cloud-node-manager-sfggz             1/1     Running   0          8m57s
kube-system   coredns-54b69f46b8-c6mss             1/1     Running   0          5m47s
kube-system   coredns-54b69f46b8-kcm9n             1/1     Running   0          9m20s
kube-system   coredns-autoscaler-bfcb7c74c-pmfpv   1/1     Running   0          9m20s

az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query count # 1
az aks update -g $rg -n aks --load-balancer-managed-outbound-ip-count 2 # node won't be recreated
az aks update -g $rg -n aks --api-server-authorized-ip-ranges "" # node won't be recreated
az aks update -g $rg -n aks --api-server-authorized-ip-ranges 0.0.0.0/32 # node won't be recreated
az aks update -g $rg -n aks --api-server-authorized-ip-ranges 1.1.1.1/32 # node won't be recreated

## Unsupported - This is for a node pool that has the cluster-autoscaler turned on. The node was deleted using the VMSS API and isn't recreated with a cluster PUT command. kubectl get no & az aks nodepool show now automatically update to show only the remaining nodes.

az aks nodepool add -g $rg --cluster-name aks -n np2 --enable-cluster-autoscaler --min-count 1 --max-count 2 -s $vmsize -c 2 # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aks -n np2 --no-wait

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)  
az vmss delete-instances -g $noderg --instance-ids 1 --name aks-np2-20833300-vmss

NAME                                STATUS   ROLES    AGE     VERSION
aks-nodepool1-36372875-vmss000000   Ready    <none>   30m     v1.30.6
aks-np2-20833300-vmss000000         Ready    <none>   6m38s   v1.30.6

az aks nodepool show -g $rg --cluster-name aks -n np2 --query count # 1
az aks nodepool show -g $rg --cluster-name aks -n np2 --query minCount # 1
az aks nodepool show -g $rg --cluster-name aks -n np2 --query maxCount # 2
az aks update -g $rg -n aks --load-balancer-managed-outbound-ip-count 1 # node won't be recreated
az aks update -g $rg -n aks --api-server-authorized-ip-ranges "" # node won't be recreated
az aks update -g $rg -n aks --api-server-authorized-ip-ranges 0.0.0.0/32 # node won't be recreated
az aks update -g $rg -n aks --api-server-authorized-ip-ranges 1.1.1.1/32 # node won't be recreated
```
