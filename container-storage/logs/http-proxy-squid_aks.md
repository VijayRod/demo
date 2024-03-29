TBD

```
# Replace the below with appropriate values
rgname=testshack
loc=swedencentral
clustername=aksproxy
vnet=myvnet
vm=proxyvm

# To create the two network subnets
az group create -g $rgname -l $loc
az network vnet create -g $rgname --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet --name nodesubnet --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create -g $rgname --vnet-name $vnet --name proxysubnet --address-prefixes 10.241.0.0/16 -o none
subnetId=$(az network vnet subnet show -g $rgname --vnet-name $vnet -n nodesubnet --query id -otsv)

# To create the virtual machine for the proxy
az vm create -g $rgname -n $vm --image UbuntuLTS --vnet-name $vnet --subnet proxysubnet
ip=$(az vm show --show-details -g $rgname -n $vm --query publicIps --output tsv)
# ssh azureuser@$ip # *****Install and configure squid*****. This should be done before creating the cluster.
```

```
# To create the cluster
cat << EOF > /tmp/aks-proxy-config.json
{
  "httpProxy": "http://$vm:3128/", 
  "httpsProxy": "https://$vm:3128/"
}
EOF
cat /tmp/aks-proxy-config.json
az aks create -g $rgname -n $clustername --http-proxy-config /tmp/aks-proxy-config.json --vnet-subnet-id $subnetId
```

```
# az aks show -g $rgname -n $clustername --query httpProxyConfig
{
  "effectiveNoProxy": [
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
