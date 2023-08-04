These steps are for a private cluster. To use a custom domain in a public cluster, you have two options: you can either use CoreDNS with a custom domain or redirect traffic using an ExternalName service.

```
# To create and link a private DNS zone. The custom private DNS zone name should be in the following format: "privatelink.<region>.azmk8s.io" or "<subzone>.privatelink.<region>.azmk8s.io"
privatezone="privatelink.swedencentral.azmk8s.io"
az network private-dns zone create -g $rgname -n $privatezone
az network private-dns link vnet create -g $rgname -n MyDNSAksLink -z $privatezone -v $vnet -e true
privatezoneUri=$(az network private-dns zone show -g $rgname -n $privatezone --query id -otsv)
az network private-dns zone list -g $rgname | grep State

# To create an identity
identityName="myIdentity$RANDOM"
az identity create -g $rgname --name $identityName
identityUri=$(az identity show -g $rgname --name $identityName --query id -otsv)
# To grant permission to the identity
subId=$(az account show --query id -otsv)
assignmentScope="/subscriptions/$subId/resourceGroups/$rgname"
identityPrincipalId=$(az identity create -g $rgname -n $identityName --query principalId -otsv)
sleep 30; az role assignment create --assignee $identityPrincipalId --role "DNS Zone Contributor" --scope $assignmentScope
az role assignment create --assignee $identityPrincipalId --role "Network Contributor" --scope $assignmentScope
# To create a subnet
az network vnet subnet create -g $rgname --vnet-name $vnet -n nodesubnet --address-prefixes 10.2.1.0/24 -o none
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n nodesubnet --query id -otsv)
# To create a cluster
clustername=aksprivatedns
az aks create -g $rgname -n $clustername --enable-private-cluster --private-dns-zone $privatezoneUri --enable-managed-identity --assign-identity $identityUri --vnet-subnet-id $subnetId
```

```
# az aks show -g $rgname -n $clustername --query apiServerAccessProfile.privateDnsZone -otsv
/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/testshack3/providers/Microsoft.Network/privateDnsZones/privatelink.swedencentral.azmk8s.io
```

- https://learn.microsoft.com/en-us/azure/aks/private-clusters#configure-a-private-dns-zone
