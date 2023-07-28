```
# Replace the below with appropriate values.
rgname=secureshack2
hostgroupname="myHostGroup"
```

```
# To create the host group
az vm host group create -g $rgname --name $hostgroupname --platform-fault-domain 2 # -l japaneast -z 1
```

```
# az vm host group show -g $rgname --name $hostgroupname
{
  "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup",
  "location": "swedencentral",
  "name": "myHostGroup",
  "platformFaultDomainCount": 2,
  "resourceGroup": "SECURESHACK2",
  "type": "Microsoft.Compute/hostGroups"
}
```

```
# To cleanup
az vm host group delete -g $rgname --name $hostgroupname -y
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/dedicated-hosts-how-to
