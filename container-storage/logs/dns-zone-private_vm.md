```
# Replace the below with appropriate values
vm1name=myvm01
vm2name=myvm02
```

```
# To create VMs
az vm create -g $rgname -n $vm1name --image UbuntuLTS --vnet-name $vnet --subnet $subnet
az vm create -g $rgname -n $vm2name --image UbuntuLTS --vnet-name $vnet --subnet $subnet
```

```
# az network private-dns record-set a add-record -g $rgname -z $privatezone -n db -a 10.2.0.4 # IP of the first VM
{
  "aRecords": [
    {
      "ipv4Address": "10.2.0.4"
    }
  ],
  "etag": "5fd874d7-9ca7-4768-b014-ea7b99333377",
  "fqdn": "db.private.contoso.com.",
  "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/testshack/providers/Microsoft.Network/privateDnsZones/private.contoso.com/A/db",
  "isAutoRegistered": false,
  "metadata": null,
  "name": "db",
  "resourceGroup": "testshack",
  "ttl": 3600,
  "type": "Microsoft.Network/privateDnsZones/A"
}

# az network private-dns record-set list -g $rgname -z $privatezone
...
```

```
# ssh azureuser@<public IP of VM2>
azureuser@myvm02:~$ ping myvm01.private.contoso.com
PING myvm01.private.contoso.com (10.2.0.4) 56(84) bytes of data.
64 bytes from myvm01.internal.cloudapp.net (10.2.0.4): icmp_seq=1 ttl=64 time=1.94 ms
64 bytes from myvm01.internal.cloudapp.net (10.2.0.4): icmp_seq=2 ttl=64 time=0.693 ms
```
