## k8s-aro

```
rg=rgaro
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n aromastersubnet --address-prefixes 10.240.1.0/24 -o none
az network vnet subnet create -g $rg --vnet-name vnet -n aroworkersubnet --address-prefixes 10.240.2.0/24 -o none 
masterSubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n aromastersubnet --query id -otsv)
workerSubnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n aroworkersubnet --query id -otsv)
az aro create -g $rg -n aro --master-subnet $masterSubnetId --worker-subnet $workerSubnetId # Automatically selects the most cost-effective SKU allowed

aroId=$(az aro show -g $rg -n aro --query id -otsv); echo $aroId
/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.RedHatOpenShift/openShiftClusters/aro

aroApiUrl=$(az aro show -g $rg -n aro --query apiserverProfile.url -otsv); echo $aroApiUrl
https://api.zr4skrmn.swedencentral.aroapp.io:6443/

aroNodeRg=$(az aro show -g $rg -n aro --query clusterProfile.resourceGroupId -otsv); echo $aroNodeRg
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/aro-zr4skrmn
```

- https://access.redhat.com/documentation/en-us/openshift_container_platform/ (Product Documentation)
- https://learn.microsoft.com/en-us/azure/openshift/intro-openshift
- https://learn.microsoft.com/en-us/azure/openshift/openshift-faq
- https://learn.microsoft.com/en-us/azure/openshift/support-policies-v4
- https://learn.microsoft.com/en-us/cli/azure/aro
- https://access.redhat.com/search/knowledgebase

## k8s-aro.billing.OpenShift

- https://learn.microsoft.com/en-us/azure/openshift/howto-infrastructure-nodes#before-you-begin: three nodes. Any additional nodes are charged an OpenShift fee. All other workloads would deem these worker nodes and thus subject to the fee.

## k8s-aro.debug

```
# laptop
nslookup api.zr4skrmn.swedencentral.aroapp.io
Server:         10.255.255.254
Address:        10.255.255.254#53
Non-authoritative answer:
Name:   api.zr4sirmn.swedencentral.aroapp.io
Address: 135.225.119.142

dig api.zr4skrmn.swedencentral.aroapp.io
; <<>> DiG 9.16.48-Ubuntu <<>> api.zr4sirmn.swedencentral.aroapp.io
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57686
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4000
;; QUESTION SECTION:
;api.zr4sirmn.swedencentral.aroapp.io. IN A
;; ANSWER SECTION:
api.zr4sirmn.swedencentral.aroapp.io. 300 IN A  135.225.119.132
;; Query time: 79 msec
;; SERVER: 10.255.255.254#53(10.255.255.254)
;; WHEN: Thu Oct 24 18:10:07 UTC 2024
;; MSG SIZE  rcvd: 81

telnet api.zr4skrmn.swedencentral.aroapp.io 6443
Trying 135.225.119.132...
Connected to api.zr4skrmn.swedencentral.aroapp.io.
Escape character is '^]'.

# laptop
curl https://api.zr4skrmn.swedencentral.aroapp.io:6443/
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
}

curl -v https://api.zr4skrmn.swedencentral.aroapp.io:6443/
*   Trying 135.225.119.142:6443...
* TCP_NODELAY set
* Connected to api.zr4skrmn.swedencentral.aroapp.io (135.225.119.142) port 6443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/certs/ca-certificates.crt
  CApath: /etc/ssl/certs
* TLSv1.3 (OUT), TLS handshake, Client hello (1):
* TLSv1.3 (IN), TLS handshake, Server hello (2):
* TLSv1.3 (IN), TLS handshake, Encrypted Extensions (8):
* TLSv1.3 (IN), TLS handshake, Request CERT (13):
* TLSv1.3 (IN), TLS handshake, Certificate (11):
* TLSv1.3 (IN), TLS handshake, CERT verify (15):
* TLSv1.3 (IN), TLS handshake, Finished (20):
* TLSv1.3 (OUT), TLS change cipher, Change cipher spec (1):
* TLSv1.3 (OUT), TLS handshake, Certificate (11):
* TLSv1.3 (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / TLS_AES_128_GCM_SHA256
* ALPN, server accepted to use h2
* Server certificate:
*  subject: C=US; ST=WA; L=Redmond; O=Microsoft Corporation; CN=api.zr4sirmn.swedencentral.aroapp.io
*  start date: Oct 24 19:25:10 2024 GMT
*  expire date: Oct 19 19:25:10 2025 GMT
*  subjectAltName: host "api.zr4sirmn.swedencentral.aroapp.io" matched cert's "api.zr4sirmn.swedencentral.aroapp.io"
*  issuer: C=US; O=Microsoft Corporation; CN=Microsoft Azure RSA TLS Issuing CA 08
*  SSL certificate verify ok.
* Using HTTP2, server supports multi-use
* Connection state changed (HTTP/2 confirmed)
* Copying HTTP/2 data in stream buffer to connection buffer after upgrade: len=0
* Using Stream ID: 1 (easy handle 0x55cce36410e0)
> GET / HTTP/2
> Host: api.zr4skrmn.swedencentral.aroapp.io:6443
> user-agent: curl/7.68.0
> accept: */*
>
* TLSv1.3 (IN), TLS handshake, Newsession Ticket (4):
* Connection state changed (MAX_CONCURRENT_STREAMS == 2000)!
< HTTP/2 403
< audit-id: 1df33c5d-7392-4678-a25c-96f04055f5eb
< cache-control: no-cache, private
< content-type: application/json
< strict-transport-security: max-age=31536000; includeSubDomains; preload
< x-content-type-options: nosniff
< x-kubernetes-pf-flowschema-uid: 4a9c9ecc-e518-45a7-8edd-30fd6bc0bc04
< x-kubernetes-pf-prioritylevel-uid: c2d7f2f4-6cdc-4f7e-ae7a-d358c0e766e7
< content-length: 217
< date: Thu, 24 Oct 2024 20:25:51 GMT
<
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "forbidden: User \"system:anonymous\" cannot get path \"/\"",
  "reason": "Forbidden",
  "details": {},
  "code": 403
* Closing connection 0
* TLSv1.3 (OUT), TLS alert, close notify (256):
}

tbd
   oc adm node-logs --role master
        oc adm node-logs --role worker
        oc adm node-logs --role=master --path=openshift-apiserver # Collect logss from /var/log/openshift-apiserver on Master Nodes
or inside of one the Workeder nodes:
# Debug/Access Node :
        oc debug --image registry.redhat.io/rhel8/support-tools:latest node/<NODE_NAME>
        oc debug node/<NODE_NAME>
```

## k8s-aro.spec.apiserver.url

```
aroApiUrl=$(az aro show -g $rg -n aro --query apiserverProfile.url -otsv); echo $aroApiUrl
https://api.zr4skrmn.swedencentral.aroapp.io:6443/
```

- https://learn.microsoft.com/en-us/azure/openshift/howto-create-private-cluster-4x: By default OpenShift uses self-signed certificates for all of the routes created on *.apps.<random>.<location>.aroapp.io.

## k8s-aro.spec.clusterProfile.resourceGroupId

```
aroNodeRg=$(az aro show -g $rg -n aro --query clusterProfile.resourceGroupId -otsv); echo $aroNodeRg
/subscriptions/redacts-1111-1111-1111-111111111111/resourcegroups/aro-zr4skrmn

az resource list -l $loc -otable | grep aro-zr4skrmn
aro-xwjww-nsg                                                                           aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkSecurityGroups
imageregistryxw6rp                                                                      aro-zr4skrmn                                         swedencentral  Microsoft.Storage/storageAccounts
aro-xwjww-pe                                                                            aro-zr4skrmn                                         swedencentral  Microsoft.Network/privateEndpoints
clusterxw6rp                                                                            aro-zr4skrmn                                         swedencentral  Microsoft.Storage/storageAccounts
aro-xwjww-internal                                                                      aro-zr4skrmn                                         swedencentral  Microsoft.Network/loadBalancers
aro-xwjww-pip-v4                                                                        aro-zr4skrmn                                         swedencentral  Microsoft.Network/publicIPAddresses
aro-xwjww-default-v4                                                                    aro-zr4skrmn                                         swedencentral  Microsoft.Network/publicIPAddresses
aro-xwjww                                                                               aro-zr4skrmn                                         swedencentral  Microsoft.Network/loadBalancers
aro-xwjww-pls                                                                           aro-zr4skrmn                                         swedencentral  Microsoft.Network/privateLinkServices
aro-xwjww-pls.nic.f1358a98-aa8b-494d-a397-3b70a5ecbc11                                  aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-pe.nic.1b5fa5cf-89d2-4aa2-83bc-38a43a7d3bda                                   aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-master0-nic                                                                   aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-master2-nic                                                                   aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-master1-nic                                                                   aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-master-1                                                                      aro-zr4skrmn                                         swedencentral  Microsoft.Compute/virtualMachines
aro-xwjww-master-0                                                                      aro-zr4skrmn                                         swedencentral  Microsoft.Compute/virtualMachines
aro-xwjww-master-2                                                                      aro-zr4skrmn                                         swedencentral  Microsoft.Compute/virtualMachines
aro-xwjww-worker-swedencentral2-grggt-nic                                               aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-worker-swedencentral2-grggt                                                   aro-zr4skrmn                                         swedencentral  Microsoft.Compute/virtualMachines
aro-xwjww-worker-swedencentral3-f2thf-nic                                               aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-worker-swedencentral3-f2thf                                                   aro-zr4skrmn                                         swedencentral  Microsoft.Compute/virtualMachines
aro-xwjww-worker-swedencentral1-gdhrw-nic                                               aro-zr4skrmn                                         swedencentral  Microsoft.Network/networkInterfaces
aro-xwjww-worker-swedencentral1-gdhrw                                                   aro-zr4skrmn                                         swedencentral  Microsoft.Compute/virtualMachines
```

## k8s-aro.spec.MachineSet.node-role.master

```
az aro show -g $rg -n aro --query masterProfile
{
  "diskEncryptionSetId": null,
  "encryptionAtHost": "Disabled",
  "subnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aromastersubnet",
  "vmSize": "Standard_D8s_v3"
}
```

## k8s-aro.spec.MachineSet.node-role.infra

```
# Infrasture nodes are custom ARO installations on user VMs
```

- https://docs.openshift.com/container-platform/4.17/machine_management/creating-infrastructure-machinesets.html
- https://learn.microsoft.com/en-us/azure/openshift/howto-infrastructure-nodes#before-you-begin: The nodes must have an Azure tag of node_role: infra

## k8s-aro.spec.MachineSet.node-role.worker

```
az aro show -g $rg -n aro --query workerProfiles
az aro show -g $rg -n aro --query workerProfilesStatus
[
  {
    "count": 3,
    "diskEncryptionSetId": null,
    "diskSizeGb": 128,
    "encryptionAtHost": "Disabled",
    "name": "worker",
    "subnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aroworkersubnet",
    "vmSize": "Standard_D4s_v3"
  }
]
[
  {
    "count": 1,
    "diskEncryptionSetId": null,
    "diskSizeGb": 128,
    "encryptionAtHost": "Disabled",
    "name": "aro-xwjww-worker-swedencentral1",
    "subnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aroworkersubnet",
    "vmSize": "Standard_D4s_v3"
  },
  {
    "count": 1,
    "diskEncryptionSetId": null,
    "diskSizeGb": 128,
    "encryptionAtHost": "Disabled",
    "name": "aro-xwjww-worker-swedencentral2",
    "subnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aroworkersubnet",
    "vmSize": "Standard_D4s_v3"
  },
  {
    "count": 1,
    "diskEncryptionSetId": null,
    "diskSizeGb": 128,
    "encryptionAtHost": "Disabled",
    "name": "aro-xwjww-worker-swedencentral3",
    "subnetId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/aroworkersubnet",
    "vmSize": "Standard_D4s_v3"
  }
]
```

## k8s-aro.spec.vmsize

```
# vmsize.default
az aro create -g $rg -n aro --master-subnet $masterSubnetId --worker-subnet $workerSubnetId --master-vm-size $vmsize --worker-vm-size $vmsize # (InvalidParameter) The provided master VM size 'Standard_B2ms' is invalid. Target: properties.masterProfile.vmSize
az aro create -g $rg -n aro --master-subnet $masterSubnetId --worker-subnet $workerSubnetId --worker-vm-size $vmsize # (InvalidParameter) The provided worker VM size 'Standard_B2ms' is invalid. Target: properties.workerProfiles['worker'].vmSize
az aro create -g $rg -n aro --master-subnet $masterSubnetId --worker-subnet $workerSubnetId # Automatically selects the most cost-effective SKU allowed

# vmsize.update.CLI (isn't available)
az aro update -g $rg -n aro --master-vm-size Standard_D16s_v3 # unrecognized arguments: --master-vm-size
az aro update -g $rg -n aro --worker-vm-size Standard_D16s_v3 # unrecognized arguments: --worker-vm-size

# vmsize.update.oc
tbd
```

- https://learn.microsoft.com/en-us/azure/openshift/openshift-faq#what-virtual-machine-sizes-can-i-use
- https://learn.microsoft.com/en-us/azure/openshift/support-policies-v4#supported-virtual-machine-sizes
- https://access.redhat.com/solutions/7022857: Upgrading Infrastructure and Worker Node VM Sizes in ARO.Upgrading or modifying VM sizes for worker nodes is possible within the ARO cluster. However, please be aware that this action is not applicable to the master nodes.
- https://learn.microsoft.com/en-us/answers/questions/1667965/changing-the-vm-sku-size-for-aro-master-nodes-and: az aro update -g <resource-group-name> -n <cluster-name> --worker-vm-count <new-vm-count> --worker-vm-size <new-vm-size>
- https://docs.openshift.com/container-platform/4.17/machine_management/manually-scaling-machineset.html
