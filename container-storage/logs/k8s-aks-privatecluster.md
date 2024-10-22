## k8s-aks-privatecluster

```
rg=rgsec
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-private-cluster -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks show -g $rg -n aks --query apiServerAccessProfile # "apiServerAccessProfile": null for a non-private cluster
{
  "authorizedIpRanges": null,
  "disableRunCommand": null,
  "enablePrivateCluster": true,
  "enablePrivateClusterPublicFqdn": true,
  "enableVnetIntegration": null,
  "privateDnsZone": "system",
  "subnetId": null
}

az aks show -g $rg -n aks --query fqdn -otsv
aks-rgsec-8d99b0-zodmp4em.hcp.swedencentral.azmk8s.io

az aks show -g $rg -n aks --query privateFqdn -otsv
aks-rgsec-111111-3d9q3p7f.1d71c86b-50e6-40b5-9f84-111111111111.privatelink.swedencentral.azmk8s.io

az aks show -g $rg -n aks --query privateLinkResources
[
  {
    "groupId": "management",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rgsec/providers/Microsoft.ContainerService/managedClusters/aks/privateLinkResources/management",
    "name": "management",
    "privateLinkServiceId": null,
    "requiredMembers": [
      "management"
    ],
    "resourceGroup": "rgsec",
    "type": "Microsoft.ContainerService/managedClusters/privateLinkResources"
  }
]
```

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal

## k8s-aks-privatecluster.kubectl

```
# This from a machine that's not in the same virtual network or in a connected peer network
az aks get-credentials -g $rg -n aksprivate
The behavior of this command has been altered by the following extension: aks-preview
Merged "aksprivate" as current context in /root/.kube/config
k get ns
E1022 22:49:10.398697    2193 memcache.go:265] couldn't get current server API group list: Get "https://aksprivate-rg-efec8e-sdh56nw0.b313df19-f990-44e7-8fcd-06f1051b18f7.privatelink.swedencentral.azmk8s.io:443/api?timeout=32s": tls: failed to verify certificate: x509: certificate is valid for *.notebooks.azure.net, not aksprivate-rg-efec8e-sdh56nw0.b313df19-f990-44e7-8fcd-06f1051b18f7.privatelink.swedencentral.azmk8s.io

# You can run this command from any computer that's logged in with Azure credentials
az aks command invoke -g $rg -n aksprivate --command "kubectl get ns"
command started at 2024-10-22 23:04:44+00:00, finished at 2024-10-22 23:04:44+00:00 with exitcode=0
NAME              STATUS   AGE
aks-command       Active   4s
default           Active   73m
kube-node-lease   Active   73m
kube-public       Active   73m
kube-system       Active   73m
```
