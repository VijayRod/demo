```
az aks create -g $rgname -n aksas --vm-set-type AvailabilitySet
```

```
# az aks show -g $rgname -n aksas --query agentPoolProfiles[0].type -otsv
AvailabilitySet

# kubectl get no
NAME                       STATUS   ROLES   AGE     VERSION
aks-nodepool1-56247321-0   Ready    agent   3m20s   v1.26.6
aks-nodepool1-56247321-1   Ready    agent   3m20s   v1.26.6
aks-nodepool1-56247321-2   Ready    agent   3m20s   v1.26.6

# az aks create -h
--vm-set-type                                       : Agent pool vm set type.
                                                          VirtualMachineScaleSets or
                                                          AvailabilitySet.
```

- https://github.com/Azure/AKS/releases/tag/2019-08-26
- https://github.com/Azure/AKS/issues/2325: Allow for migration from VMAS to VMSS
