```
aks-nodepool1-38494683-vmss000000:/# ip route
default via 10.224.0.1 dev eth0 proto dhcp src 10.224.0.4 metric 100
...

aks-nodepool1-38494683-vmss000000   Ready    agent   3m50s   v1.28.10   10.224.0.4    <none>        Ubuntu 22.04.4 LTS   5.15.0-1067-azure   containerd://1.7.15-1

az network vnet subnet show -g MC_rg_aks_swedencentral --vnet-name aks-vnet-92427521 -n aks-subnet --query addressPrefix -otsv # 10.224.0.0/16
az network vnet show -g MC_rg_aks_swedencentral -n aks-vnet-92427521 --query addressSpace.addressPrefixes[0] -otsv # 10.224.0.0/12
```

- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#are-there-any-restrictions-on-using-ip-addresses-within-these-subnets: .1: Reserved by Azure for the default gateway.
- https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq#can-i-ping-a-default-gateway-in-a-virtual-network: No.
