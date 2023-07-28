```
# Replace the below with appropriate values.
rgname=secureshack2
hostgroupname="myHostGroup"
host1name="myHost"
host2name="myHost2"
```

```
# To create the host group
az vm host group create -g $rgname --name $hostgroupname --platform-fault-domain 2

# To create the dedicated hosts
az vm host create -g $rgname --host-group $hostgroupname --name $host1name --sku DSv4-Type2 --platform-fault-domain 0 # -l japaneast
az vm host create -g $rgname --host-group $hostgroupname --name $host2name --sku DSv4-Type2 --platform-fault-domain 1
```

```
# az vm host show -g $rgname --host-group $hostgroupname --name $host1name
{
  "autoReplaceOnFailure": true,
  "hostId": "c4e0ba15-4b13-4f7d-b268-6f8ff7cfbb4b",
  "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/secureshack2/providers/Microsoft.Compute/hostGroups/myHostGroup/hosts/myHost",
  "location": "swedencentral",
  "name": "myHost",
  "platformFaultDomain": 0,
  "provisioningState": "Succeeded",
  "provisioningTime": "2023-07-27T22:56:59.6673301+00:00",
  "resourceGroup": "secureshack2",
  "sku": {
    "name": "DSv4-Type2"
  },
  "timeCreated": "2023-07-27T22:56:57.0422497+00:00",
  "type": "Microsoft.Compute/hostGroups/hosts",
  "virtualMachines": []
}

# az vm host get-instance-view -g $rgname --host-group $hostgroupname --name $host1name. This retrieves the resource Ids of the virtualMachines deployed to this dedicated host.
{
  "autoReplaceOnFailure": true,
  "hostId": "c4e0ba15-4b13-4f7d-b268-6f8ff7cfbb4b",
  "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/secureshack2/providers/Microsoft.Compute/hostGroups/myHostGroup/hosts/myHost",
  "instanceView": {
    "assetId": "dc51dc5f-0bea-d57d-173b-c8c2b6d534f5",
    "availableCapacity": {
      "allocatableVMs": [
        {
          "count": 32.0,
          "vmSize": "Standard_D2s_v4"
        },
        {
          "count": 26.0,
          "vmSize": "Standard_D4s_v4"
        },
        {
          "count": 13.0,
          "vmSize": "Standard_D8s_v4"
        },
        {
          "count": 6.0,
          "vmSize": "Standard_D16s_v4"
        },
        {
          "count": 3.0,
          "vmSize": "Standard_D32s_v4"
        },
        {
          "count": 2.0,
          "vmSize": "Standard_D48s_v4"
        },
        {
          "count": 1.0,
          "vmSize": "Standard_D64s_v4"
        }
      ]
    },
    "statuses": [
      {
        "code": "ProvisioningState/succeeded",
        "displayStatus": "Provisioning succeeded",
        "level": "Info",
        "message": null,
        "time": "2023-07-27T22:56:59.682911+00:00"
      },
      {
        "code": "HealthState/available",
        "displayStatus": "Host available",
        "level": "Info",
        "message": null,
        "time": null
      }
    ]
  },
  "licenseType": null,
  "location": "swedencentral",
  "name": "myHost",
  "platformFaultDomain": 0,
  "provisioningState": "Succeeded",
  "provisioningTime": "2023-07-27T22:56:59.667330+00:00",
  "resourceGroup": "secureshack2",
  "sku": {
    "capacity": null,
    "name": "DSv4-Type2",
    "tier": null
  },
  "tags": null,
  "timeCreated": "2023-07-27T22:56:57.042249+00:00",
  "type": "Microsoft.Compute/hostGroups/hosts",
  "virtualMachines": []
}
```

```
# To cleanup
az vm host delete -g $rgname --host-group $hostgroupname --name $host1name -y --no-wait
az vm host delete -g $rgname --host-group $hostgroupname --name $host2name -y
az vm host group delete -g $rgname --name $hostgroupname -y
```
