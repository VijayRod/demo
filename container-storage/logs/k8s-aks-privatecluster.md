## k8s-aks-privatecluster

```
# See the section on privateendpoint privatecluster

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

## k8s-aks-privatecluster.debug

```
# See the section on run commandinvoke aks

fqdn=$(az aks show -g $rg -n aks --query privateFqdn -otsv)
nslookup $fqdn
** server can't find aks-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io: NXDOMAIN

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

```
# conn

az aks show -g $rg -n aksprivate | grep azmk8s
WARNING: The behavior of this command has been altered by the following extension: aks-preview
  "azurePortalFqdn": "127956cd387c12f8541f055eee83e384-priv.portal.hcp.swedencentral.azmk8s.io",
  "fqdn": "aksprivate-rg-efec8e-vylsis3l.hcp.swedencentral.azmk8s.io",
  "privateFqdn": "aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io",

az aks command invoke -g $rg -n aksprivate --command "curl -Iv https://aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io"
command started at 2024-11-21 18:40:17+00:00, finished at 2024-11-21 18:40:17+00:00 with exitcode=60
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 10.224.0.4:443...
* Connected to aksprivate-rg-efec8e-2fc44ihq.ec2ccfad-dd02-4ef6-8ce0-e3f276ae86aa.privatelink.swedencentral.azmk8s.io (10.224.0.4) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*  CAfile: /etc/ssl/certs/ca-certificates.crt
*  CApath: /etc/ssl/certs
} [5 bytes data]
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
} [512 bytes data]
* TLSv1.3 (IN), TLS handshake, Server hello (2):
{ [122 bytes data]
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
{ [15 bytes data]
* TLSv1.3 (IN), TLS handshake, Request CERT (13):
{ [89 bytes data]
* TLSv1.3 (IN), TLS handshake, Certificate (11):
{ [1668 bytes data]
* TLSv1.3 (OUT), TLS alert, unknown CA (560):
} [2 bytes data]
* SSL certificate problem: unable to get local issuer certificate
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
* Closing connection 0
curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.se/docs/sslcerts.html
curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

## k8s-aks-privatecluster.spec.other.publicfqdn

```
rg=rgsec
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-private-cluster --disable-public-fqdn -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing
```

```
az aks update -g $rg -n aks --disable-public-fqdn
az aks update -g $rg -n aks --enable-public-fqdn

az aks show -g $rg -n aks --query apiServerAccessProfile.enablePrivateClusterPublicFqdn # false
az aks show -g $rg -n aks --query fqdn # null
```  

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal#disable-a-public-fqdn

## k8s-aks-privatecluster.spec.other.vm

TBD

```
# Replace the below with appropriate values
rgname=testshack2
loc=swedencentral
vnet=myvnet
akssubnet=akssubnet
clustername=aksprivate
vnet2=myvnet2
vmsubnet=vmsubnet
vm=myvm
image=debian
user=azureuser

# To create a virtual network with an AKS cluster
az group create -n $rgname -l $loc
az network vnet create -g $rgname -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $akssubnet --subnet-prefixes 10.2.0.0/24
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $akssubnet --query id -otsv)
az aks create -g $rgname -n $clustername --vnet-subnet-id $subnetId --enable-private-cluster
privateFqdn=$(az aks show -g $rgname -n $clustername --query privateFqdn -otsv)

# To create a second *non-peered* virtual network
az network vnet create -g $rgname -n $vnet2 --address-prefix 11.2.0.0/16 --subnet-name $vmsubnet --subnet-prefixes 11.2.0.0/24
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet2 -n $vmsubnet --query id -otsv)
az vm create -g $rgname -n $vm --image $image --subnet $subnetId --admin-username $user --public-ip-sku Standard
ip=$(az vm show --show-details -g $rgname -n $vm --query publicIps --output tsv)

TBD
ssh azureuser@$ip 
## curl $privateFqdn
```

- https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal#options-for-connecting-to-the-private-cluster
- https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
