TBD

```
# Replace the below with appropriate values
rgname=secureshack2
clustername=aksproxy2
vnet=myvnet2
vmname=proxyvm2
```

```
# To create the two network subnets
az network vnet create -g $rgname --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet --name akssubnet --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet --name proxysubnet --address-prefixes 10.241.0.0/16 -o none

# To create the virtual machine for the proxy
az vm create -g $rgname -n $vmname --image UbuntuLTS --vnet-name $vnet --subnet proxysubnet
# ssh azureuser@<IP> # *****Install and configure squid*****.
```

```
# To create the cluster
cat << EOF > /tmp/aks-proxy-config.json
{
  "httpProxy": "http://$vmname:3128/", 
  "httpsProxy": "https://$vmname:3128/"
}
EOF
cat /tmp/aks-proxy-config.json
az aks create -g $rgname -n $clustername --http-proxy-config /tmp/aks-proxy-config.json
```

```
# az aks show -g $rgname -n $clustername --query httpProxyConfig
{
  "effectiveNoProxy": [
    "konnectivity",
    "aksproxy2-secureshack2-8d99b0-luq23deq.hcp.swedencentral.azmk8s.io",
    "10.224.0.0/12",
    "localhost",
    "127.0.0.1",
    "169.254.169.254",
    "10.244.0.0/16",
    "10.0.0.0/16",
    "168.63.129.16"
  ],
  "httpProxy": "http://proxyvm2:3128/",
  "httpsProxy": "https://proxyvm2:3128/",
  "noProxy": [
    "konnectivity",
    "aksproxy2-secureshack2-111111-luq23deq.hcp.swedencentral.azmk8s.io",
    "10.224.0.0/12",
    "localhost",
    "127.0.0.1",
    "169.254.169.254",
    "10.244.0.0/16",
    "10.0.0.0/16",
    "168.63.129.16"
  ],
  "trustedCa": null
}
```

- https://learn.microsoft.com/en-us/azure/aks/http-proxy
