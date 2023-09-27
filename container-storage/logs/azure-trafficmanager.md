```
trafficmanager="akstm$RANDOM$RANDOM"
az group create -n $rg -l $loc
az network traffic-manager profile create -g $rg -n $trafficmanager --routing-method Performance --unique-dns-name $trafficmanager
```

```
az network traffic-manager profile show -g $rg -n $trafficmanager --query dnsConfig.fqdn -otsv
akstm1291423391.trafficmanager.net

az network traffic-manager profile show -g $rg -n $trafficmanager --query profileStatus # "Enabled"
az network traffic-manager profile show -g $rg -n $trafficmanager --query monitorConfig.profileMonitorStatus # Initially, it is "Inactive," but it will become "Online" after adding an endpoint.
```

- https://learn.microsoft.com/en-us/azure/traffic-manager/quickstart-create-traffic-manager-profile-cli
- https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-how-it-works
- https://learn.microsoft.com/en-us/cli/azure/network/traffic-manager
