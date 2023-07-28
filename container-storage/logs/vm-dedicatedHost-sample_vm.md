```
# Replace the below with appropriate values.
rgname=secureshack2
hostgroupname="myHostGroup"
host1name="myHost"
host2name="myHost2"
vnet1="vnet$RANDOM"
vnet2="vnet$RANDOM"
```

```
# To create the host group
az vm host group create -g $rgname --name $hostgroupname --platform-fault-domain 2 --automatic-placement true

# To create the dedicated hosts
az vm host create -g $rgname --host-group $hostgroupname --name $host1name --sku DSv4-Type2 --platform-fault-domain 0
az vm host create -g $rgname --host-group $hostgroupname --name $host2name --sku DSv4-Type2 --platform-fault-domain 1

# To create a VM in a host group. This works due to host group --automatic-placement true.
az vm create -g $rgname --host-group $hostgroupname -n myVM --size Standard_D4s_v4 --image debian --vnet-name vnet1

# TBD To create a VM in a dedicated host
# hostId=$(az vm host show -g $rgname --host-group $hostgroupname --name $host1name --query id)
# az vm create -g $rgname --host $hostId -n myVM2 --size Standard_D4s_v3 --image debian --vnet-name vnet2	
```	

```
# az vm show -g $rgname -n myVM --query host
(null)

# az vm show -g $rgname -n myVM --query hostGroup
{
  "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/hostGroups/myHostGroup",
  "resourceGroup": "SECURESHACK2"
}

# az vm host get-instance-view -g $rgname --host-group $hostgroupname --name $host1name --query virtualMachines
[
  {
    "id": "/subscriptions/dummys-1111-1111-1111-111111111111/resourceGroups/SECURESHACK2/providers/Microsoft.Compute/virtualMachines/MYVM",
    "resourceGroup": "SECURESHACK2"
  }
]
```

```
# To cleanup
az vm delete -g $rgname -n myVM -y --no-wait
az vm delete -g $rgname -n myVM2 -y
az network vnet delete -g $rgname -n $vnet1 --no-wait
az network vnet delete -g $rgname -n $vnet2 --no-wait
az vm host delete -g $rgname --host-group $hostgroupname --name $host1name -y --no-wait
az vm host delete -g $rgname --host-group $hostgroupname --name $host2name -y
az vm host group delete -g $rgname --name $hostgroupname -y
```

- https://learn.microsoft.com/en-us/azure/virtual-machines/dedicated-hosts-how-to
