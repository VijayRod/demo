## ip.Azure.IpRanges

```
# See the section on service tag
```

- https://www.azurespeed.com/Azure/IPLookup
- https://www.microsoft.com/en-us/download/details.aspx?id=56519: Azure IP Ranges and Service Tags – Public Cloud (This link has IP ranges, so you might not be able to search for an IP directly)
- https://azservicetags.azurewebsites.net/iplookup
- https://azservicetags.azurewebsites.net/servicetag/azurecloud
- https://azservicetags.azurewebsites.net/servicetag/azurecloud.swedencentral

## ip.Azure.IpRanges.Latency

- https://www.azurespeed.com/Azure/Latency

## ip.Azure.types.ca

```
# Customer address (CA)
# See the section on PA
```

## ip.Azure.types.lb.dip

```
# DIP (Dynamic IP)
```

- https://www.itprotoday.com/azure-cloud/correct-terms-for-vip-and-dip-and-more-in-azure-resource-manager
- https://shabiryusuf.wordpress.com/2016/03/15/example-of-dip-pip-ilpip-and-vip-on-microsoft-azure/
- https://petri.com/understanding-ip-addressing-microsoft-azure/
- https://techcommunity.microsoft.com/blog/azuredevcommunityblog/azure-api-management-networking-explained/3274323
- https://www.microsoftpressstore.com/articles/article.aspx?p=2358300&seqNum=2

## ip.Azure.types.lb.ilpip

```
# PIP or ILPIP= Instance Level Public IP
# See the section on DIP
```

## ip.Azure.types.lb.vip

```
# VIP (virtual IP)
# See the section on DIP
```

## ip.Azure.types.pa

```
Provider address (PA)
```

- https://learn.microsoft.com/en-us/azure/azure-government/azure-secure-isolation-guidance: Provider address (PA) is the Azure assigned internal fabric address that isn't visible to users and is also referred to as Dynamic IP (DIP). No traffic goes directly from the Internet to a server; all traffic from the Internet must go through a Software Load Balancer (SLB) and be encapsulated to protect the internal Azure address space by only routing packets to valid Azure internal IP addresses and ports
  - Customer address (CA)
- https://learn.microsoft.com/en-us/windows-server/networking/sdn/technologies/hyper-v-network-virtualization/hyperv-network-virtualization-technical-details-windows-server#packet-encapsulation
- https://learn.microsoft.com/en-us/troubleshoot/windows-server/software-defined-networking/troubleshoot-sdn-guidance: If provider addresses (PA) are not present or customer address (CA) connectivity is broken, check to make sure that network policy has been received.

## ip.virtualPublicIp

```
azureVip="168.63.129.16"

aks-nodepool1-14217322-vmss000001   Ready    <none>   31h   v1.29.7   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1
wireshark ip.addr==168.63.129.16
324	10.224.0.5	168.63.129.16	TCP	80	48018 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=612374547 TSecr=0 WS=128
325	168.63.129.16	10.224.0.5	TCP	80	80 ? 48018 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=256 SACK_PERM TSval=1292316171 TSecr=612374547
326	10.224.0.5	168.63.129.16	TCP	72	48018 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=612374547 TSecr=1292316171
327	10.224.0.5	168.63.129.16	HTTP	273	GET /machine/?comp=goalstate HTTP/1.1 
328	168.63.129.16	10.224.0.5	HTTP/XML	2508	HTTP/1.1 200 OK 
329	10.224.0.5	168.63.129.16	TCP	72	48018 ? 80 [ACK] Seq=202 Ack=2438 Win=64128 Len=0 TSval=612374549 TSecr=1292316173
330	10.224.0.5	168.63.129.16	TCP	72	48018 ? 80 [FIN, ACK] Seq=202 Ack=2438 Win=64128 Len=0 TSval=612374549 TSecr=1292316173

327	10.224.0.5	168.63.129.16	HTTP	273	GET /machine/?comp=goalstate HTTP/1.1 
328	168.63.129.16	10.224.0.5	HTTP/XML	2508	HTTP/1.1 200 OK 

335	10.224.0.5	168.63.129.16	HTTP	532	GET /vmSettings HTTP/1.1 
336	168.63.129.16	10.224.0.5	HTTP	217	HTTP/1.1 304 Not Modified 

343	10.224.0.5	168.63.129.16	HTTP/JSON	662	PUT /status HTTP/1.1 , JSON (application/json)
345	168.63.129.16	10.224.0.5	HTTP	226	HTTP/1.1 200 OK 

350	10.224.0.5	168.63.129.16	HTTP/JSON	261	POST /HealthService HTTP/1.1 , JSON (application/json)
352	168.63.129.16	10.224.0.5	HTTP	222	HTTP/1.1 200 OK  (text/plain)

387	168.63.129.16	10.224.0.5	HTTP	253	GET /healthz HTTP/1.1 
388	10.224.0.5	168.63.129.16	HTTP/JSON	366	HTTP/1.1 200 OK , JSON (application/json)

1012	10.224.0.5	168.63.129.16	HTTP	273	GET /machine/?comp=goalstate HTTP/1.1 
1013	168.63.129.16	10.224.0.5	HTTP/XML	2508	HTTP/1.1 200 OK 
```

- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16
- https://microsoft.github.io/AzureTipsAndTricks/blog/tip242.html#what-is-ip-address-168-63-129-16

## ip.virtualPublicIp.wireserver

- https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16: The VM Agent requires outbound communication over ports 80/tcp and 32526/tcp with WireServer (168.63.129.16).

## ip.virtualPublicIp.wireserver.aks

```
wireshark port==32526
aks-nodepool1-12914153-vmss000000:/# iptables -vnL
Chain FORWARD (policy ACCEPT 276 packets, 32187 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DROP       tcp  --  *      *       0.0.0.0/0            168.63.129.16        tcp dpt:32526
```

- https://github.com/Azure/AKS/releases/tag/2024-08-27: For non-host network pods running on AKS nodes, they cannot access wireserver(168.63.129.16) port 32526. Before this change user cannot access wireserver port 80, but port 32526 is accessible.
- https://cloud.google.com/blog/topics/threat-intelligence/escalating-privileges-azure-kubernetes-services

## ip.virtualPublicIp.wireserver.VMAgent

- https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/linux/linux-azure-guest-agent: Make sure the VM can connect to the Fabric Controller. Use a tool such as curl to test whether the VM can connect to 168.63.129.16 on ports 80, 443, and 32526.

## ip.IMDS

```
http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01&format=json
```

```
root@aks-nodepool1-22790412-vmss000000:/# curl -I http://169.254.169.254
HTTP/1.1 400 Bad Request
Content-Length: 323
Content-Type: text/xml; charset=utf-8
Server: Microsoft-IIS/10.0
Date: Tue, 04 Feb 2025 18:19:59 GMT

root@aks-nodepool1-22790412-vmss000000:/# curl -Iv http://169.254.169.254
*   Trying 169.254.169.254:80...
* Connected to 169.254.169.254 (169.254.169.254) port 80 (#0)
> HEAD / HTTP/1.1
> Host: 169.254.169.254
> User-Agent: curl/7.81.0
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 400 Bad Request
HTTP/1.1 400 Bad Request
< Content-Length: 323
Content-Length: 323
< Content-Type: text/xml; charset=utf-8
Content-Type: text/xml; charset=utf-8
< Server: Microsoft-IIS/10.0
Server: Microsoft-IIS/10.0
< Date: Tue, 04 Feb 2025 18:20:10 GMT
Date: Tue, 04 Feb 2025 18:20:10 GMT

<
* Connection #0 to host 169.254.169.254 left intact

root@aks-nodepool1-22790412-vmss000000:/# curl -I https://169.254.169.254
^C

root@aks-nodepool1-22790412-vmss000000:/# curl -I http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01&format=json
[1] 12060
root@aks-nodepool1-22790412-vmss000000:/# HTTP/1.1 400 Bad Request
Content-Length: 323
Content-Type: text/xml; charset=utf-8
Server: Microsoft-IIS/10.0
Date: Tue, 04 Feb 2025 18:20:21 GMT
^C
[1]+  Done                    curl -I http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01

root@aks-nodepool1-22790412-vmss000000:/# curl http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01&format=json
[1] 12261
root@aks-nodepool1-22790412-vmss000000:/# { "error": "Bad request: . Required metadata header not specified" }
[1]+  Done                    curl http://169.254.169.254/metadata/instance/compute?api-version=2021-01-01

root@aks-nodepool1-22790412-vmss000000:/# curl -s -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | jq
{
  "compute": {
    "azEnvironment": "AzurePublicCloud",
    "customData": "",
    "evictionPolicy": "",
    "isHostCompatibilityLayerVm": "false",
    "licenseType": "",
    "location": "SwedenCentral",
    "name": "aks-nodepool1-22790412-vmss_0",
    "offer": "",
    "osProfile": {
      "adminUsername": "azureuser",
      "computerName": "aks-nodepool1-22790412-vmss000000",
      "disablePasswordAuthentication": "true"
    },
    "osType": "Linux",
    "placementGroupId": "28483844-a164-463b-a69e-9c5960a3011f",
    "plan": {
      "name": "",
      "product": "",
      "publisher": ""
    },
    "platformFaultDomain": "0",
    "platformUpdateDomain": "0",
    "priority": "",
    "provider": "Microsoft.Compute",
    "publicKeys": [
      {
        "keyData": "ssh-rsa AAAAB3NzaC1y...34L6H8S+Z",
        "path": "/home/azureuser/.ssh/authorized_keys"
      }
    ],
    "publisher": "",
    "resourceGroupName": "MC_rg_aks_swedencentral",
    "resourceId": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-22790412-vmss/virtualMachines/0",
    "securityProfile": {
      "secureBootEnabled": "false",
      "virtualTpmEnabled": "false"
    },
    "sku": "",
    "storageProfile": {
      "dataDisks": [],
      "imageReference": {
        "id": "/subscriptions/109a5e88-1111-1111-1111-111111111111/resourceGroups/AKS-Ubuntu/providers/Microsoft.Compute/galleries/AKSUbuntu/images/2204gen2containerd/versions/202501.22.0",
        "offer": "",
        "publisher": "",
        "sku": "",
        "version": ""
      },
      "osDisk": {
        "caching": "ReadOnly",
        "createOption": "FromImage",
        "diffDiskSettings": {
          "option": ""
        },
        "diskSizeGB": "128",
        "encryptionSettings": {
          "enabled": "false"
        },
        "image": {
          "uri": ""
        },
        "managedDisk": {
          "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Compute/disks/aks-nodepool1-227904aks-nodepool1-2279041OS__1_3a7055da87954d7ca0025136347cbcbb",
          "storageAccountType": "Premium_LRS"
        },
        "name": "aks-nodepool1-227904aks-nodepool1-2279041OS__1_3a7055da87954d7ca0025136347cbcbb",
        "osType": "Linux",
        "vhd": {
          "uri": ""
        },
        "writeAcceleratorEnabled": "false"
      },
      "resourceDisk": {
        "size": "50688"
      }
    },
    "subscriptionId": "redacts-1111-1111-1111-111111111111",
    "tags": "aks-managed-azure-cni-overlay:true;aks-managed-consolidated-additional-properties:0f926372-e302-11ef-8204-bacf181c0fef;aks-managed-coordination:true;aks-managed-createOperationID:f5c12aa3-bd67-45b2-968b-4cae3c00c277;aks-managed-creationSource:vmssclient-aks-nodepool1-22790412-vmss;aks-managed-enable-imds-restriction:false;aks-managed-kubeletIdentityClientID:a417d22a-2289-4f69-9a9e-a95fec7c1d50;aks-managed-orchestrator:Kubernetes:1.30.7;aks-managed-poolName:nodepool1;aks-managed-resourceNameSuffix:92427521;aks-managed-ssh-access:LocalUser",
    "tagsList": [
      {
        "name": "aks-managed-azure-cni-overlay",
        "value": "true"
      },
      {
        "name": "aks-managed-consolidated-additional-properties",
        "value": "0f926372-e302-11ef-8204-bacf181c0fef"
      },
      {
        "name": "aks-managed-coordination",
        "value": "true"
      },
      {
        "name": "aks-managed-createOperationID",
        "value": "f5c12aa3-bd67-45b2-968b-4cae3c00c277"
      },
      {
        "name": "aks-managed-creationSource",
        "value": "vmssclient-aks-nodepool1-22790412-vmss"
      },
      {
        "name": "aks-managed-enable-imds-restriction",
        "value": "false"
      },
      {
        "name": "aks-managed-kubeletIdentityClientID",
        "value": "a417d22a-2289-4f69-9a9e-a95fec7c1d50"
      },
      {
        "name": "aks-managed-orchestrator",
        "value": "Kubernetes:1.30.7"
      },
      {
        "name": "aks-managed-poolName",
        "value": "nodepool1"
      },
      {
        "name": "aks-managed-resourceNameSuffix",
        "value": "92427521"
      },
      {
        "name": "aks-managed-ssh-access",
        "value": "LocalUser"
      }
    ],
    "userData": "",
    "version": "202501.22.0",
    "vmId": "d89dcaf9-bd2e-45f9-8435-a778a750d9ba",
    "vmScaleSetName": "aks-nodepool1-22790412-vmss",
    "vmSize": "Standard_B2ms",
    "zone": ""
  },
  "network": {
    "interface": [
      {
        "ipv4": {
          "ipAddress": [
            {
              "privateIpAddress": "10.224.0.5",
              "publicIpAddress": ""
            }
          ],
          "subnet": [
            {
              "address": "10.224.0.0",
              "prefix": "16"
            }
          ]
        },
        "ipv6": {
          "ipAddress": []
        },
        "macAddress": "6045BDC89987"
      }
    ]
  }
}
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/instance-metadata-service?tabs=linux
  
## ip.IMDS.scheduledEvents

```
aks-nodepool1-14217322-vmss000001   Ready    <none>   31h   v1.29.7   10.224.0.5    <none>        Ubuntu 22.04.4 LTS   5.15.0-1071-azure   containerd://1.7.20-1
wireshark ip.addr==169.254.169.254
1997	10.224.0.5	169.254.169.254	TCP	80	44384 ? 80 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=3347151662 TSecr=0 WS=128
1998	169.254.169.254	10.224.0.5	TCP	80	80 ? 44384 [SYN, ACK] Seq=0 Ack=1 Win=65535 Len=0 MSS=1460 WS=256 SACK_PERM TSval=1292333927 TSecr=3347151662
1999	10.224.0.5	169.254.169.254	TCP	72	44384 ? 80 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=3347151663 TSecr=1292333927
2000	10.224.0.5	169.254.169.254	HTTP	213	GET /metadata/scheduledevents?api-version=2020-07-01 HTTP/1.1 
2001	169.254.169.254	10.224.0.5	HTTP/JSON	325	HTTP/1.1 200 OK , JSON (application/json)
2002	10.224.0.5	169.254.169.254	TCP	72	44384 ? 80 [ACK] Seq=142 Ack=254 Win=64128 Len=0 TSval=3347151671 TSecr=1292333933
2003	10.224.0.5	169.254.169.254	TCP	72	44384 ? 80 [FIN, ACK] Seq=142 Ack=254 Win=64128 Len=0 TSval=3347151671 TSecr=1292333933
2004	169.254.169.254	10.224.0.5	TCP	72	80 ? 44384 [FIN, ACK] Seq=254 Ack=143 Win=12583168 Len=0 TSval=1292333933 TSecr=3347151671
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/linux/scheduled-events

## ip.lb.healthprobe

- https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-custom-probe-overview: Don't configure your virtual network with the Microsoft owned IP address range that contains 168.63.129.16. The configuration collides with the IP address of the health probe and can cause your scenario to fail.
  - For Azure Load Balancer's health probe to mark up your instance, you must allow 168.63.129.16 IP address in any Azure network security groups and local firewall policies. The AzureLoadBalancer service tag identifies this source IP address in your network security groups and permits health probe traffic by default.
  - All IPv4 Load Balancer health probes originate from the IP address 168.63.129.16 as their source. IPv6 probes use a link-local address (fe80::1234:5678:9abc) as their source.  
