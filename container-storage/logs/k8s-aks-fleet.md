```
az extension add --name fleet
az extension update --name fleet
```

```
rg=rgfleet
az group create -n $rg -l $loc
az aks create -g $rg -n aks1 -s $vmsize -c 2 --no-wait
az aks create -g $rg -n aks2 -s $vmsize -c 2
az aks get-credentials -g $rg -n aks1 --overwrite-existing
kubectl get no; kubectl get po -A

member1Id=$(az aks show -g $rg -n aks1 --query id -otsv); echo $member1Id
member2Id=$(az aks show -g $rg -n aks2 --query id -otsv); echo $member2Id

az fleet create -g $rg -n aksfleet
az fleet member create -g $rg --fleet-name aksfleet -n aks1 --member-cluster-id $member1Id
az fleet member create -g $rg --fleet-name aksfleet -n aks2 --member-cluster-id $member2Id
```

- https://learn.microsoft.com/en-us/azure/kubernetes-fleet/quickstart-create-fleet-and-members?tabs=without-hub-cluster

```
fleetId=$(az fleet show -g $rg -n aksfleet --query id -otsv); echo $fleetId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rgfleet/providers/Microsoft.ContainerService/fleets/aksfleet

az fleet member list -g $rg -f aksfleet -o table
ClusterResourceId
                  ETag                                    Name    ProvisioningState    ResourceGroup
------------------------------------------------------------------------------------------------------------------------------------  --------------------------------------  ------  -------------------  ---------------
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rgfleet/providers/Microsoft.ContainerService/managedClusters/aks1  "65011c31-0000-4700-0000-6773ebd70000"  aks1    Succeeded            rgfleet
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/rgfleet/providers/Microsoft.ContainerService/managedClusters/aks2  "65012b31-0000-4700-0000-6773ebd80000"  aks2    Succeeded            rgfleet
```
