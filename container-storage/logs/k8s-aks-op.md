## k8s-aks-op

```
az aks --debug
az aks --no-wait
```

## k8s-aks-op.abort

```
az aks operation-abort -g $rg -n aks
az aks nodepool operation-abort -g $rg --cluster-name aks --nodepool-name nodepool1

# (OperationNotAllowed) Cancel operation is not allowed when the ProvisioningState is Failed
```

- https://azure.microsoft.com/en-us/updates/public-preview-operation-abort/
- https://azure.microsoft.com/en-us/updates/generally-available-operation-abort-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/manage-abort-operations?tabs=azure-cli
- https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/abort-latest-operation
- https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-operation-abort
- https://learn.microsoft.com/en-us/cli/azure/aks/nodepool?view=azure-cli-latest#az-aks-nodepool-operation-abort

## k8s-aks-op.delete.cluster

```
# cluster.delete.reconcile/OperationNotAllowed
# (OperationNotAllowed) Cluster in Deleting provisioning state cannot be reconciled. The only allowed operation after deletion has started is to retry cluster deletion.
```

```
# cluster.delete.sub-resource.NotFound
# If the resource was manually or accidentally deleted, for instance, in the node resource group, manually recreate the resource since a reconcile will not work after a cluster is marked for deletion. Then, retry the cluster delete.
```

```
# The node resource group was removed before the cluster deletion was fully completed
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)   
az group delete -n $noderg -y -f # --no-wait
az aks delete -g $rg -n aks -y # --no-wait # success

# Removed the cluster resource group
az group delete -n $rg -y -f # --no-wait # success
```

## k8s-aks-op.maintenanceconfiguration

```
az aks maintenanceconfiguration list -g $rg --cluster-name aks # []
```

## k8s-aks-op.maintenanceconfiguration.aksManagedAutoUpgradeSchedule

```
az aks maintenanceconfiguration add -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule --schedule-type Weekly --interval-weeks 1 --day-of-week Monday --start-time 01:00
--duration 5
```

```
az aks maintenanceconfiguration update -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule --schedule-type Weekly --interval-weeks 1 --day-of-week Monday --start-time 02:00 --duration 5
az aks maintenanceconfiguration show -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule
az aks maintenanceconfiguration delete -g $rgname --cluster-name $clustername -n aksManagedAutoUpgradeSchedule

az aks maintenanceconfiguration list -g $rgname --cluster-name $clustername
az aks show -g $rgname -n $clustername --query autoUpgradeProfile # No rows
```

## k8s-aks-op.maintenanceconfiguration.aksManagedNodeOSUpgradeSchedule

```
az aks maintenanceconfiguration add -g $rgname --cluster-name $clustername -n aksManagedNodeOSUpgradeSchedule --schedule-type Weekly --interval-weeks 1 --day-of-week Monday --start-time 01:00 --duration 5
```

```
az aks maintenanceconfiguration update -g $rgname --cluster-name $clustername -n aksManagedNodeOSUpgradeSchedule --schedule-type Weekly --interval-weeks 1 --day-of-week Monday --start-time 02:00 --duration 5
az aks maintenanceconfiguration show -g $rgname --cluster-name $clustername -n aksManagedNodeOSUpgradeSchedule
az aks maintenanceconfiguration delete -g $rgname --cluster-name $clustername -n aksManagedNodeOSUpgradeSchedule

az aks maintenanceconfiguration list -g $rgname --cluster-name $clustername
az aks show -g $rgname -n $clustername --query autoUpgradeProfile # No rows
```

## k8s-aks-op.maintenanceconfiguration.default

```
az aks maintenanceconfiguration add -g $rgname --cluster-name $clustername -n default --weekday Monday --start-hour 1 --duration 5
```

```
az aks maintenanceconfiguration update -g $rgname --cluster-name $clustername -n default --weekday Monday --start-hour 2 --duration 5
az aks maintenanceconfiguration show -g $rgname --cluster-name $clustername -n default
az aks maintenanceconfiguration delete -g $rgname --cluster-name $clustername -n default

az aks maintenanceconfiguration list -g $rgname --cluster-name $clustername
az aks show -g $rgname -n $clustername --query autoUpgradeProfile # No rows
```

- https://azure.microsoft.com/id-id/updates/public-preview-planned-maintenance-windows-in-aks/
- https://learn.microsoft.com/en-us/azure/aks/planned-maintenance
  
## k8s-aks-op.reconcile

```
az aks update -g $rg -n aks
az aks nodepool update -g $noderg --cluster-name aks -n nodepool1
az resource update --id /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/$rg/providers/Microsoft.ContainerService/managedClusters/aks
```

## k8s-aks-op.reconcile.auto

```
k describe ds -n kube-system csi-azuredisk-node | grep Limits: -A 1.
kubectl set resources daemonset csi-azuredisk-node -c=azuredisk --limits=memory=1200Mi -n kube-system # AKS quickly reverts back my change
```

## k8s-aks-op.upgrade

```
# See the section on k8s version
# See the section on maintenanceconfiguration
# More details in pdb

az aks get-versions -otable -l swedencentral
az aks get-upgrades -g $rg -n aks -otable

az aks upgrade -y -g $rg -n aks --kubernetes-version 1.27.1
# az aks upgrade --control-plane-only -y -g $rg -n aks --kubernetes-version 1.27.1
# az aks nodepool upgrade -y -g $rg --cluster-name aks -n nodepool1 --kubernetes-version 1.27.1

az aks show -g $rg -n aks --query agentPoolProfiles[0].upgradeSettings
  "drainTimeoutInMinutes": null,
  "maxSurge": "10%",
  "nodeSoakDurationInMinutes": null,
  "undrainableNodeBehavior": null
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade
- https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli
- https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster
- tbd https://www.pjlewis.com/posts/best-practices-for-upgrading-updating-your-aks-clusters/

## k8s-aks-op.upgrade.events

```
# See the section on eventgrid aks

kubectl get events
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#view-upgrade-events
- https://azure.microsoft.com/en-us/updates/generally-available-azure-kubernetes-support-for-upgrade-events/

## k8s-aks-op.upgrade.autoUpgrade

```
az aks show -g $rg -n aks --query autoUpgradeProfile
  "nodeOsUpgradeChannel": "NodeImage",
  "upgradeChannel": null
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade#automatic-upgrades
- https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster#configure-automatic-upgrades

## k8s-aks-op.upgrade.autoUpgrade.nodeOsUpgradeChannel


## k8s-aks-op.upgrade.autoUpgrade.upgradeChannel

```
az aks update -g $rgname -n $clustername --auto-upgrade-channel stable

az aks show -g $rgname -n $clustername --query autoUpgradeProfile
{
  "nodeOsUpgradeChannel": null,
  "upgradeChannel": "stable"
}

# To cleanup
az aks update -g $rgname -n $clustername --auto-upgrade-channel none
```

- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster
  
## k8s-aks-op.upgrade.upgradeSettings.drainTimeoutInMinutes

```
# See the section on pod state Terminating and terminationGracePeriodSeconds

az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.drainTimeoutInMinutes -otsv # null

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --drain-timeout 45
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.drainTimeoutInMinutes -otsv # 45
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#set-node-drain-timeout-value

## k8s-aks-op.upgrade.upgradeSettings.max-surge

```
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.maxSurge -otsv # "10%"

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --max-surge 33%
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.maxSurge -otsv # 33%

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --max-surge 1
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.maxSurge -otsv # 1
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#customize-node-surge-upgrade

## k8s-aks-op.upgrade.upgradeSettings.node-soak-duration

```
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.nodeSoakDurationInMinutes -otsv # null

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --node-soak-duration 5
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.nodeSoakDurationInMinutes -otsv # 5
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade-aks-cluster?tabs=azure-cli#set-node-soak-time-value

## k8s-aks-op.upgrade.upgradeSettings.undrainable-node-behavior

```
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.undrainableNodeBehavior -otsv # null

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --undrainable-node-behavior Cordon
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.undrainableNodeBehavior -otsv # Cordon

az aks nodepool update -g $rg --cluster-name aks -n nodepool1 --undrainable-node-behavior Schedule
az aks nodepool show -g $rg --cluster-name aks -n nodepool1 --query upgradeSettings.undrainableNodeBehavior -otsv # Schedule

kubectl get nodes --show-labels=true
kubectl get nodes -l kubernetes.azure.com/upgrade-status=Quarantined
```

- https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster#optimize-for-undrainable-node-behavior-preview
