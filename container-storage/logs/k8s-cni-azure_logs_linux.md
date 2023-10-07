```
filev=$(hostname)-azurevnet-$(date -u +%Y%m%d%H%M%S)Z
/opt/cni/bin/azure-vnet --version > /tmp/$filev
cat /etc/cni/net.d/10-azure.conflist >> /tmp/$filev
cat /var/run/azure-vnet.json  >> /tmp/$filev
ls -l /tmp/*azurevnet*
# cat /tmp/$filev
# /tmp/aks-nodepool1-17884086-vmss000000-azurevnet-20231006192235Z

cd /tmp
filel=$(hostname)-varlog-$(date -u +%Y%m%d%H%M%S)Z
echo "Target file: /tmp/$filel.tar.gz"
tar -czvf $filel.tar.gz /var/log 
ls -l /tmp/*varlog*
# /tmp/aks-nodepool1-17884086-vmss000000-varlog-20231006191746Z.tar.gz
```

```
Azure CNI Version v1.4.43.1
{
   "cniVersion":"0.3.0",
   "name":"azure",
   "plugins":[
      {
         "type":"azure-vnet",
         "mode":"transparent",
         "ipsToRouteViaHost":["169.254.20.10"],
         "ipam":{
            "type":"azure-vnet-ipam"
         }
      },
      {
         "type":"portmap",
         "capabilities":{
            "portMappings":true
         },
         "snat":true
      }
   ]
}
{
        "Network": {
                "Version": "v1.4.43.1",
                "TimeStamp": "2023-10-06T11:20:52.317294826Z",
                "ExternalInterfaces": {
...
```
