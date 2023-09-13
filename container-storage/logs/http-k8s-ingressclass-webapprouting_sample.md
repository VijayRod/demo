```
mkdir /tmp/tls
cd /tmp/tls
rm *
ls

rg=rgapprouting
az group create -n $rg -l $loc
az aks create -g $rg -n aks --enable-addons azure-keyvault-secrets-provider,web_application_routing --enable-secret-rotation -s $vmsize
az aks get-credentials -g $rg -n aks --overwrite-existing

TBD
```

- https://learn.microsoft.com/en-us/azure/aks/app-routing?tabs=without-osm
