## k8s-scale-app_cas

```
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksscale --enable-cluster-autoscaler --min-count 1 --max-count 3 -s $vmsize -c 1
az aks get-credentials -g $rg -n aksscale --overwrite-existing

az aks nodepool add -g $rg --cluster-name aksscale -n np2 --enable-cluster-autoscaler --min-count 1 --max-count 3 -s $vmsize # --os-sku Mariner
# az aks nodepool delete -g $rg --cluster-name aksscale -n np2 --no-wait
```

- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/processors/customresources/gpu_processor.go: nodesWithUnreadyGpu
- https://github.com/kubernetes/autoscaler/blob/7e95c7e63a5f0773e51bc484b1f7dbe802fe668a/cluster-autoscaler/core/static_autoscaler.go#L970: Handle GPU case - allocatable GPU may be equal to 0 up to 15 minutes after
- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/azure/README.md
- https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md
- https://learn.microsoft.com/en-us/azure/aks/cluster-autoscaler-overview
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/cannot-scale-cluster-autoscaler-enabled-node-pool
- https://cluster-api.sigs.k8s.io/tasks/automated-machine-management/autoscaling.html
- https://kubernetes.io/docs/concepts/cluster-administration/cluster-autoscaling/

## k8s-scale-app_cas.annotate.scale-down-disabled

```
# https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md#how-can-i-prevent-cluster-autoscaler-from-scaling-down-a-particular-node
kubectl annotate node aks-readnp-19992910-vmss00001y cluster-autoscaler.kubernetes.io/scale-down-disabled=true
```
