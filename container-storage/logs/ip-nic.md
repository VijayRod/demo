```
az network nic list -g $rg -otable
az network nic show -g $rg -n myVMVMNic
az network nic list-effective-nsg -g $rg -n myVmVMNic
```
