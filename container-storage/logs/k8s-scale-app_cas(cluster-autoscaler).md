## k8s-scale-app_cas

```
rg=rgscale
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-cluster-autoscaler --min-count 1 --max-count 3 -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n np2 --enable-cluster-autoscaler --min-count 1 --max-count 3 -s $vmsize # --os-sku Mariner
```

```
az aks nodepool update -g $rg --cluster-name aks -n np2 --update-cluster-autoscaler --min-count 1 --max-count 10 # update min or max count

az aks nodepool update -g $rg --cluster-name aks -n np2 --disable-cluster-autoscaler # disable

az aks nodepool delete -g $rg --cluster-name aks -n np2 --no-wait
```

- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/processors/customresources/gpu_processor.go: nodesWithUnreadyGpu
- https://github.com/kubernetes/autoscaler/blob/7e95c7e63a5f0773e51bc484b1f7dbe802fe668a/cluster-autoscaler/core/static_autoscaler.go#L970: Handle GPU case - allocatable GPU may be equal to 0 up to 15 minutes after
- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/azure/README.md
- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler-overview
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/cannot-scale-cluster-autoscaler-enabled-node-pool
- https://cluster-api.sigs.k8s.io/tasks/automated-machine-management/autoscaling.html
- https://kubernetes.io/docs/concepts/cluster-administration/cluster-autoscaling/

```
# test

kubectl create deploy nginx --image=nginx --replicas=10 --dry-run=client -o yaml | kubectl set resources --local -f - --requests=cpu=1 --dry-run=client -o yaml | kubectl apply -f -
kubectl scale deploy nginx --replicas=10
kubectl get no,po
```

```
# cas..debug.logs

kubectl get events --field-selector source=cluster-autoscaler
kubectl get configmap -n kube-system cluster-autoscaler-status -o yaml
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler?tabs=azure-cli#retrieve-cluster-autoscaler-logs-and-status

```
# cas..debug.metrics
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler?tabs=azure-cli#cluster-autoscaler-metrics

```
# cas.settings
# cluster-autoscaler-profile is set at the cluster level, not the node level
az aks update -g $rg -n aks --cluster-autoscaler-profile scan-interval=30s
az aks update -g $rg -n aks --cluster-autoscaler-profile scan-interval=30s
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler?tabs=azure-cli#cluster-autoscaler-profile-settings
- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#what-are-the-parameters-to-ca
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler?tabs=azure-cli#reset-cluster-autoscaler-profile-to-default-values

```
# cas.settings.scale-down
```

- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler-overview#scale-down-operation-failures
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler-overview#example-1-optimizing-for-performance: decreasing the scale-down-utilization-threshold
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler-overview#example-2-optimizing-for-cost: Reduce scale-down-unneeded-time. Reduce scale-down-delay-after-add. Increase scale-down-utilization-threshold
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler?tabs=azure-cli#configure-cluster-autoscaler-profile-for-aggressive-scale-down
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler?tabs=azure-cli#configure-cluster-autoscaler-profile-for-bursty-workloads

```
# cas.settings.scale-down.scale-down-disabled.annotate
```

- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-prevent-cluster-autoscaler-from-scaling-down-a-particular-node
kubectl annotate node aks-np2-19992910-vmss00001y cluster-autoscaler.kubernetes.io/scale-down-disabled=true

```
# cas.settings.scale-down.scale-down-mode
# Deallocate, Delete.  Default: Delete.
```

```
# cas.settings.scale-down.scale-down-mode.Deallocate

# node deallocation happens after scale-down-unneeded-time
az aks nodepool add -g $rg --cluster-name aks -n np2 --enable-cluster-autoscaler --min-count 1 --max-count 20 -s $vmsize -c 10 --scale-down-mode Deallocate
kubectl get no
NAME                                STATUS     ROLES    AGE   VERSION
aks-nodepool1-15526837-vmss000000   Ready      <none>   26m   v1.30.7
aks-np2-52526230-vmss000000         NotReady   <none>   21m   v1.30.7
aks-np2-52526230-vmss000001         NotReady   <none>   21m   v1.30.7
aks-np2-52526230-vmss000002         Ready      <none>   21m   v1.30.7
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az vmss get-instance-view -g $noderg -n aks-np2-52526230-vmss --instance-id 0 --query statuses[1].code -otsv # PowerState/deallocated

# cas.settings.scale-down.scale-down-mode.Deallocate.changing mode from Deallocate to Delete
# deallocated nodes will be deleted
az aks nodepool update -g $rg --cluster-name aks -n np2 --scale-down-mode Delete
kubectl get no
NAME                                STATUS   ROLES    AGE   VERSION
aks-nodepool1-15526837-vmss000000   Ready    <none>   37m   v1.30.7
aks-np2-52526230-vmss000002         Ready    <none>   32m   v1.30.7
```

```
# cas.settings.scale-down.scale-down-unneeded-time
# default is 10 minutes
az aks update -g $rg -n aks --cluster-autoscaler-profile scale-down-unneeded-time=60s   
```
