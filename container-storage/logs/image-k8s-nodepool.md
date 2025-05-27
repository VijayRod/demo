```
az aks show -g $rg -n aks --query agentPoolProfiles[0].nodeImageVersion -otsv
AKSUbuntu-2204gen2containerd-202309.06.0

kubectl describe no aks-nodepool1-41508760-vmss000000 | grep image
Labels:             agentpool=nodepool1
                    kubernetes.azure.com/node-image-version=AKSUbuntu-2204gen2containerd-202309.06.0
                    
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.labels.kubernetes\.azure\.com\/node-image-version}{"\n"}{end}' # View for all nodes
aks-nodepool1-41508760-vmss000000       AKSUbuntu-2204gen2containerd-202309.06.0

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az vmss show -g $noderg -n aks-nodepool1-41508760-vmss --query virtualMachineProfile.storageProfile.imageReference
{
  "communityGalleryImageId": null,
  "exactVersion": null,
  "id": "/subscriptions/redactImageSub-1111-1111-1111-111111111111/resourceGroups/AKS-Ubuntu/providers/Microsoft.Compute/galleries/AKSUbuntu/images/2204gen2containerd/versions/202309.06.0",
  "offer": null,
  "publisher": null,
  "resourceGroup": "AKS-Ubuntu",
  "sharedGalleryImageId": null,
  "sku": null,
  "version": null
}
```

```
az aks nodepool get-upgrades -g $rg --cluster-name aks -n nodepool1 # --query latestNodeImageVersion -otsv
{
  "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rg/providers/Microsoft.ContainerService/managedClusters/aks/agentPools/nodepool1/upgradeProfiles/default",
  "kubernetesVersion": "1.26.6",
  "latestNodeImageVersion": "AKSUbuntu-2204gen2containerd-202309.06.0",
  "name": "default",
  "osType": "Linux",
  "resourceGroup": "rg",
  "type": "Microsoft.ContainerService/managedClusters/agentPools/upgradeProfiles",
  "upgrades": null
}

az aks nodepool upgrade -g $rg --cluster-name aks -n np2019 --node-image-only
az aks upgrade -g $rg -n aks -n --node-image-only # All node pools
```

- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster: node-image
- https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-node-image
- https://learn.microsoft.com/en-us/azure/aks/planned-maintenance: default, aksManagedNodeOSUpgradeSchedule
- https://github.com/Azure/AKS/blob/master/CHANGELOG.md: option None in the node OS upgrade
- https://learn.microsoft.com/en-us/azure/aks/node-image-upgrade

```
# image.aks.node.image
```

- https://github.com/Azure/AKS/tree/2023-10-29/vhd-notes/aks-ubuntu/AKSUbuntu-2204
- https://github.com/Azure/AgentBaker/blob/master/vhdbuilder/release-notes/AKSUbuntu/gen2/2204containerd/latest.txt (latest)
- https://github.com/Azure/AKS/releases: image has been updated to

```
# image.aks.node.diff

diff <(curl -s https://raw.githubusercontent.com/Azure/AKS/2025-03-16/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202503.13.0.txt) \
     <(curl -s https://raw.githubusercontent.com/Azure/AKS/2025-04-06/vhd-notes/aks-ubuntu/AKSUbuntu-2204/202504.06.0.txt)
```
