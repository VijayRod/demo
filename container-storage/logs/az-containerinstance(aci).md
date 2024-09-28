## az-containerinstance

```
rg=rgaci
dns="aci-demo$RANDOM"
az group create -g $rg -l $loc
az container create -g $rg --name mycontainer --image mcr.microsoft.com/azuredocs/aci-helloworld --dns-name-label $dns --ports 80
az container show -g $rg --name mycontainer --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table
```

```
FQDN                                   ProvisioningState
-------------------------------------  -------------------
aci-demo1012.eastus.azurecontainer.io  Succeeded

curl -I aci-demo1012.eastus.azurecontainer.io
HTTP/1.1 200 OK

az container list -g $rg -otable
Name            ResourceGroup    Status     Image                                       IP:ports          Network    CPU/Memory       OsType    Location
--------------  ---------------  ---------  ------------------------------------------  ----------------  ---------  ---------------  --------  -------------
mycontainer    rgaci            Succeeded  mcr.microsoft.com/azuredocs/aci-helloworld  4.225.36.30:80    Public     1.0 core/1.5 gb  Linux     swedencentral

az container delete -g $rg --name mycontainer -y
```

- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-quickstart
- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-troubleshooting
- https://azure.microsoft.com/en-us/updates/?query=%22Azure%20Container%20Instances%22
- https://learn.microsoft.com/en-us/azure/container-instances/

## az-containerinstance.group

- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-multi-container-yaml
- https://learn.microsoft.com/en-us/azure/container-instances/container-instances-container-groups: collection of containers that get scheduled on the same host machine
