## nodepool.spec.agentPoolProfiles

```
# nodepool.agentPoolProfiles
az aks show -g $rg -n aks --query agentPoolProfiles
az aks nodepool show -g $rg --cluster-name aks -n nodepool1
```

```
# agentPoolProfiles.count - is it possible for a customer to update the capacity of the aks vmss to zero?

az aks nodepool update -h | grep count -A 5
    --max-count                           : Maximum nodes count used for autoscaler, when "--enable-
                                            cluster-autoscaler" specified. Please specify the value
                                            in the range of [0, 1000] for user nodepool, and
                                            [1,1000] for system nodepool.
    --min-count                           : Minimun nodes count used for autoscaler, when "--enable-
                                            cluster-autoscaler" specified. Please specify the value
                                            in the range of [0, 1000] for user nodepool, and
                                            [1,1000] for system nodepool.
                 
# nodepool without cluster-autoscaler
az aks nodepool add -g $rg --cluster-name aks -n np0manual -c 2
k get no # 2
az aks nodepool update -g $rg --cluster-name aks -n np0manual -c 0 # unrecognized arguments: -c 0
az aks nodepool stop -g $rg --cluster-name aks -n np0manual
k get no # 0

# nodepool with cluster-autoscaler
az aks nodepool add -g $rg --cluster-name aks -n np0cas --min-count 2 --max-count 10
k get no # 2
az aks nodepool update -g $rg --cluster-name aks -n np0cas --update-cluster-autoscaler --min-count 0 --max-count 10
k get no # 2
az aks update -g $rg -n aks --cluster-autoscaler-profile scale-down-unneeded-time=1m
k get no # 0, after 10 minutes (default) depending on the scale-down-unneeded-time
```

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
```

```
# Unsupported - The node was delete with kubernetes API.
# Manual editing isn't supported or recommended. The node count in the agent pool profile wasn't updated. 
# (tbd) Then agent pool reconciliation was triggered and vmss was scaled up. This is expected.

kubectl get no
NAME                                STATUS   ROLES    AGE   VERSION
aks-nodepool1-21822725-vmss000000   Ready    <none>   56s   v1.30.6
aks-nodepool1-21822725-vmss000001   Ready    <none>   51s   v1.30.6

kubectl delete no aks-nodepool1-21822725-vmss000001

kubectl get no
NAME                                STATUS   ROLES    AGE     VERSION
aks-nodepool1-21822725-vmss000000   Ready    <none>   6m51s   v1.30.6

az aks show -g $rg -n aks --query agentPoolProfiles[0].count # 2

az aks update -g $rg -n aks # reconcile

kubectl get no
NAME                                STATUS   ROLES    AGE   VERSION
aks-nodepool1-21822725-vmss000000   Ready    <none>   10m   v1.30.6
```

```
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
