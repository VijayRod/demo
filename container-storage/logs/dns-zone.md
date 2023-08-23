```
# Replace the below with appropriate values
rgname=testshack
vnet=myvnet
subnet=backendSubnet
privatezone="private.contoso.com"
```

```
# To create a virtual network
az group create -n $rgname -l swedencentral
az network vnet create -g $rgname -n $vnet --address-prefix 10.2.0.0/16 --subnet-name $subnet --subnet-prefixes 10.2.0.0/24

# To create a private DNS zone and link it
az network private-dns zone create -g $rgname -n $privatezone
az network private-dns link vnet create -g $rgname -n MyDNSLink -z $privatezone -v $vnet -e true
```

```
# To retrieve the properties of the private zone
privatezoneUri=$(az network private-dns zone show -g $rgname -n $privatezone --query id -otsv)

# az network private-dns zone list -g $rgname | grep State
[
  {
    "etag": "797753cc-b20d-45c0-9f4f-d291b5777a85",
    "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/testshack/providers/Microsoft.Network/privateDnsZones/private.contoso.com",
    "location": "global",
    "maxNumberOfRecordSets": 25000,
    "maxNumberOfVirtualNetworkLinks": 1000,
    "maxNumberOfVirtualNetworkLinksWithRegistration": 100,
    "name": "private.contoso.com",
    "numberOfRecordSets": 1,
    "numberOfVirtualNetworkLinks": 0,
    "numberOfVirtualNetworkLinksWithRegistration": 0,
    "provisioningState": "Succeeded",
    "resourceGroup": "testshack",
    "tags": null,
    "type": "Microsoft.Network/privateDnsZones"
  }
]

# az network private-dns zone list
[
  {
    "etag": "797753cc-b20d-45c0-9f4f-d291b5777a85",
    "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/testshack/providers/Microsoft.Network/privateDnsZones/private.contoso.com",
    "location": "global",
    "maxNumberOfRecordSets": 25000,
    "maxNumberOfVirtualNetworkLinks": 1000,
    "maxNumberOfVirtualNetworkLinksWithRegistration": 100,
    "name": "private.contoso.com",
    "numberOfRecordSets": 1,
    "numberOfVirtualNetworkLinks": 0,
    "numberOfVirtualNetworkLinksWithRegistration": 0,
    "provisioningState": "Succeeded",
    "resourceGroup": "testshack",
    "tags": null,
    "type": "Microsoft.Network/privateDnsZones"
  }
]
```

```
vm=myvm
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n $subnet --query id -otsv)
az vm create -g $rgname -n $vm --image=Ubuntu2204 --subnet $subnetId
ssh azureuser@4.225.162.71
# azureuser@myvm:~$ dig private.contoso.com

; <<>> DiG 9.11.3-1ubuntu1.18-Ubuntu <<>> private.contoso.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 34018
;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;private.contoso.com.           IN      A

;; Query time: 12 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Wed Aug 22 22:09:27 UTC 2023
;; MSG SIZE  rcvd: 48
```

```
# To cleanup
# az network private-dns link vnet delete -g $rgname -n MyDNSLink -z private.contoso.com -y
# az network private-dns zone delete -g $rgname -n private.contoso.com -y
az group delete -n $rgname -y --no-wait
```

- https://learn.microsoft.com/en-us/azure/dns/private-dns-getstarted-cli
