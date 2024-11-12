```
az network watcher test-ip-flow --direction outbound --protocol tcp --local '10.0.0.4:60000' --remote 8.8.8.8:443 -g $rg --vm $vm --nic myVmVMNic --out table
# TBD (vmss) az network watcher test-ip-flow --direction outbound --protocol tcp --local '10.0.0.4:60000' --remote 8.8.8.8:443 -g $rg --vm aks-default-24553791-vmss_6 --nic myVmVMNic --out table
Access    RuleName
--------  ------------------------------------------
Allow     defaultSecurityRules/AllowInternetOutBound
```

```
az network nic list-effective-nsg -g $rg -n myVmVMNic
```

- https://learn.microsoft.com/en-us/azure/network-watcher/diagnose-vm-network-traffic-filtering-problem-cli
