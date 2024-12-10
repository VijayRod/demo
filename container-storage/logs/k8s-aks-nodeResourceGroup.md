Directly modifying resources in the node resource group can cause your cluster to become unstable or unresponsive. Unless otherwise documented, we do not recommend changes to the node resource group and such changes can result in the cluster being unsupported.

```
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)

kubectl describe no | grep /cluster
Name:               aks-nodepool1-16663898-vmss000001
Labels:             agentpool=nodepool1
                    kubernetes.azure.com/cluster=MC_rg_aks_centralus
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#custom-resource-group-name
- https://learn.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#node-resource-group
- https://learn.microsoft.com/en-us/azure/aks/faq#why-are-two-resource-groups-created-with-aks

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
