## privateendpoint

```
# See the section on privateendpoint.app.webapp
```

- https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview: A private endpoint is a network interface that uses a private IP address from your virtual network.
- https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-cli
- https://learn.microsoft.com/en-us/azure/private-link/private-link-faq
- https://learn.microsoft.com/en-us/azure/well-architected/security/networking#connectivity-to-platform-as-a-service-paas-services
- https://learn.microsoft.com/en-us/azure/well-architected/security/networking#private-endpoints
- https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints: When you create a private endpoint, the DNS CNAME resource record for the storage account is updated to an alias in a subdomain with the prefix privatelink
  - Use the same connection string to connect to the storage account using private endpoints as you'd use otherwise. Please don't connect to the storage account using its privatelink subdomain URL.

## privateendpoint.app.csi.k8s

- https://github.com/kubernetes-sigs/azurefile-csi-driver/blob/master/docs/driver-parameters.md: private endpoint
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision: private endpoint

## privateendpoint.app.k8s.aks.privatecluster

```
az group create -n $rg -l $loc
az aks create -g $rg -n aksprivate --enable-private-cluster -s $vmsize -c 1
clusterId=$(az aks show -g $rg -n aksprivate --query id -otsv)
noderg=$(az aks show -g $rg -n aksprivate --query nodeResourceGroup -o tsv)

clusterVNet=aks-vnet-75528806
clusterVNetId=$(az network vnet show -g $noderg -n $clusterVNet --query id -otsv)

# vnet address space must not overlap with the vnet of the private cluster, else it will fail to run az network private-dns link vnet create
az network vnet create -g $rg --name vnet --address-prefixes 11.2.0.0/16 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n appsubnet --address-prefixes 11.2.240.0/24 -o none
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n appsubnet --query id -otsv)

# PE - in the app vnet with resource type Microsoft.ContainerService/managedClusters
# Private DNS zone - in the app vnet with the same name as the private cluster zone, A record that matches the private cluster zone, and a link (PLS) (private-dns link vnet) to the private cluster vnet
# https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=default-basic-networking%2Cazure-portal#create-a-private-endpoint-resource
zone="1ff2fc33-1b01-4e76-a7f0-1e07e31b40a0.privatelink.swedencentral.azmk8s.io" # Make sure this matches the private cluster zone name
az network private-endpoint create -g $rg -n pe --connection-name appcon --vnet-name vnet --subnet appsubnet --private-connection-resource-id $clusterId --group-id Microsoft.ContainerService/managedClusters
az network private-dns zone create -g $rg -n $zone
az network private-dns record-set a add-record -g $rg --zone-name $zone -n aksprivate-rg2-efec8e-54w66yee --ipv4-address 10.224.0.4 # Grab these values from the private cluster zone DNS record  and make sure the TTL value matches too
az network private-dns link vnet create -g $rg --zone-name $zone -n dnslink --virtual-network $clusterVNetId --registration-enabled false
az network private-endpoint dns-zone-group create -g $rg --endpoint-name pe -n zonegroup --private-dns-zone $zone --zone-name aks

# Mitigate
# Delete the cluster PE, then reconcile the cluster to recreate the PE. az aks update -g $rg -n aksprivate
# Stop and start the cluster to delete the PE and the associated control plane. https://learn.microsoft.com/en-us/azure/aks/private-clusters: If the private cluster is stopped and restarted, the private cluster's original private link service (PLS) is removed and recreated

# Cleanup
# Here's the right order of steps: First, delete the PLE (private-endpoint) and PLS (private-dns link vnet) in the app DNS zone (optionally make sure it's deleted in the cluster DNS zones too). After that, you can delete the ingress (with the finalizers in its service, which will remove the LB).
```

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=default-basic-networking%2Cazure-portal#use-a-private-endpoint-connection
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/create-upgrade-delete/cannot-delete-load-balancer-private-link-service?source=recommendations: CannotDeleteLoadBalancerWithPrivateLinkService, PrivateLinkServiceWithPrivateEndpointConnectionsCannotBeDeleted

## privateendpoint.app.storage

- https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints

## privateendpoint.app.webapp

```
rg=rgvnet
az group create -n $rg -l $loc

plan=plan
app="app$RANDOM"
az appservice plan create -g $rg -n $plan --sku P2V2 # PremiumV2-tier or higher app service plan
planId=$(az appservice plan show -g $rg -n $plan --query id -o tsv)
az webapp create -g $rg -n $app -p $plan
appId=$(az webapp show -g $rg -n $app --query id -otsv)
appUrl=$(az webapp show -g $rg -n $app --query defaultHostName -otsv)
echo $appUrl
curl $appUrl -I

az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n appsubnet --address-prefixes 10.240.0.0/16 -o none
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n appsubnet --query id -otsv)

az network private-endpoint create -g $rg -n pe --connection-name appcon --vnet-name vnet --subnet appsubnet --private-connection-resource-id $appId --group-id sites
az network private-dns zone create -g $rg -n "privatelink.azurewebsites.net"
az network private-dns link vnet create -g $rg --zone-name "privatelink.azurewebsites.net" -n dnslink --virtual-network vnet --registration-enabled false
az network private-endpoint dns-zone-group create -g $rg --endpoint-name pe -n zonegroup --private-dns-zone "privatelink.azurewebsites.net" --zone-name webapp

subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n appsubnet --query id -otsv)
az vm create -g $rg -n vm --image Ubuntu2204 --admin-username azureuser --public-ip-sku Standard --subnet $subnetId

# nslookup shows the private IP address
ssh azureuser@ip
azureuser@vm:~$ nslookup mywebapp27540.azurewebsites.net
mywebapp27540.azurewebsites.net canonical name = mywebapp27540.privatelink.azurewebsites.net.
Name:   mywebapp27540.privatelink.azurewebsites.net
Address: 10.240.0.4
```
  
- https://learn.microsoft.com/en-us/azure/private-link/create-private-endpoint-cli?tabs=dynamic-ip

## privateendpoint.debug

```
# Our test, which involved editing the host file on a cluster node to include the correct DNS record, allowed docker login to succeed, confirming our theory about the need for correct DNS record.
```
