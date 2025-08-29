```
# refer to datapath
```

## nic.azure

```
az network nic list -g $rg -otable
az network nic show -g $rg -n myVMVMNic
az network nic list-effective-nsg -g $rg -n myVmVMNic
```

## nic.azure.azurevm

- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface
