```
# route
```

```
# route.vm

ip route

az vm create -g $rg -n myvm  --image Ubuntu2404 --admin-username azureuser
nicId=$(az vm show -g $rg -n myvm  --query networkProfile.networkInterfaces[0].id -otsv); echo $nicId
az network nic show-effective-route-table --ids $nicId -otable

Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.0.0.0/16       VnetLocal
Default   Active   0.0.0.0/0         Internet
Default   Active   10.0.0.0/8        None
Default   Active   127.0.0.0/8       None
Default   Active   100.64.0.0/10     None
Default   Active   172.16.0.0/12     None
Default   Active   25.176.0.0/13     None
Default   Active   25.152.0.0/14     None
Default   Active   25.184.0.0/14     None
Default   Active   25.4.0.0/14       None
Default   Active   25.148.0.0/15     None
Default   Active   198.18.0.0/15     None
Default   Active   25.150.0.0/16     None
Default   Active   25.156.0.0/16     None
Default   Active   25.159.0.0/16     None
Default   Active   40.109.0.0/16     None
Default   Active   192.168.0.0/16    None
Default   Active   104.147.0.0/16    None
Default   Active   157.59.0.0/16     None
Default   Active   40.108.0.0/17     None
Default   Active   104.146.0.0/17    None
Default   Active   23.103.0.0/18     None
Default   Active   20.35.252.0/22    None

az network nic show-effective-route-table --ids $nicId -otable --query value[].source # Default
az network nic show-effective-route-table --ids $nicId -otable --query value[].disableBgpRoutePropagation # False

az vm list-ip-addresses -g $rg -n myvm -otable

vmId="/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Compute/virtualMachines/myvm"; echo $vmId
az network watcher show-next-hop -g $rg --vm $vmId --source-ip 10.0.0.8 --dest-ip 8.8.8.8 # { "nextHopType": "Internet", "routeTableId": "System Route" }

az network watcher run-configuration-diagnostic --resource $vmId \
  --direction Outbound --protocol TCP --source 10.0.0.8 --destination 8.8.8.8 --port 80
```

```
# route.vmss
# the command 'az network nic show-effective-route-table' is not supported for vmss instances

az group create -n $rg -l $loc
az vmss create -g $rg -n myvmss --image Ubuntu2404 --admin-username azureuser --vm-sku $vmsize
az vmss nic list -g $rg --vmss-name myvmss # no rows

nicId="/subscriptions/$subId/resourceGroups/rgtag/providers/Microsoft.Network/networkInterfaces/myvms0445Nic-b0ee76b7"; echo $nicId
az network nic show-effective-route-table --ids $nicId -otable
az network nic show-effective-route-table --ids $nicId -otable --query value[].source # Default
az network nic show-effective-route-table --ids $nicId -otable --query value[].disableBgpRoutePropagation # False

Source    State    Address Prefix    Next Hop Type    Next Hop IP
--------  -------  ----------------  ---------------  -------------
Default   Active   10.0.0.0/16       VnetLocal
Default   Active   0.0.0.0/0         Internet
Default   Active   10.0.0.0/8        None
Default   Active   127.0.0.0/8       None
Default   Active   100.64.0.0/10     None
Default   Active   172.16.0.0/12     None
Default   Active   25.176.0.0/13     None
Default   Active   25.152.0.0/14     None
Default   Active   25.184.0.0/14     None
Default   Active   25.4.0.0/14       None
Default   Active   25.148.0.0/15     None
Default   Active   198.18.0.0/15     None
Default   Active   25.150.0.0/16     None
Default   Active   25.156.0.0/16     None
Default   Active   25.159.0.0/16     None
Default   Active   40.109.0.0/16     None
Default   Active   192.168.0.0/16    None
Default   Active   104.147.0.0/16    None
Default   Active   157.59.0.0/16     None
Default   Active   40.108.0.0/17     None
Default   Active   104.146.0.0/17    None
Default   Active   23.103.0.0/18     None
Default   Active   20.35.252.0/22    None

az vmss list-instances -g $rg -n myvmss  --query "[].{instanceId:instanceId, resourceId:id}" --output table

vmId="/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Compute/virtualMachineScaleSets/myvmss/virtualMachines/myvmss_8f9b10a7"; echo $vmId
az network watcher show-next-hop -g $rg --vm $vmId --source-ip 10.0.0.8 --dest-ip 8.8.8.8 # InvalidArgumentValue

az network watcher run-configuration-diagnostic --resource $vmId \
  --direction Outbound --protocol TCP --source 10.0.0.8 --destination 8.8.8.8 --port 80 # VirtualMachineNotAllocated

az vmss run-command invoke \
  --resource-group $rg \
  --name myvmss \
  --instance-id 0 \
  --command-id RunShellScript \
  --scripts "ip route get 8.8.8.8"

az vmss extension set -g $rg --vmss-name myvmss --name CustomScript --publisher Microsoft.Azure.Extensions \
  --settings '{"commandToExecute": "ip route get 8.8.8.8 > /tmp/route_output.txt"}' # file in VM instances
```

```
# route.vmss.aks.kubenet

root@aks-nodepool1-39107837-vmss000000:/# ip route
default via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100
10.224.0.0/16 dev eth0 proto kernel scope link src 10.224.0.4 metric 100
10.224.0.1 dev eth0 proto dhcp scope link src 10.224.0.4 metric 100
10.244.0.23 dev azvae819819db8 proto static
10.244.0.34 dev azv36c871ef810 proto static
10.244.0.36 dev azvf2a1a047093 proto static
10.244.0.85 dev azv5c9f1093611 proto static
10.244.0.151 dev azv0819c702331 proto static
10.244.0.204 dev azv7dbcdcc6c96 proto static
10.244.0.229 dev azv69b73055765 proto static
10.244.0.233 dev azva9eab2b4334 proto static
168.63.129.16 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100
169.254.169.254 via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100

nicId="/subscriptions/$subId/resourceGroups/MC_rgtag_aks_swedencentral/providers/Microsoft.Compute/virtualMachineScaleSets/aks-nodepool1-39107837-vmss/virtualMachines/0/networkInterfaces/aks-nodepool1-39107837-vmss"; echo $nicId
az network nic show-effective-route-table --ids $nicId -otable
az network nic show-effective-route-table --ids $nicId -otable --query value[].source # Default
az network nic show-effective-route-table --ids $nicId -otable --query value[].disableBgpRoutePropagation # False
```
