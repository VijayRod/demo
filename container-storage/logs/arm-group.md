```
rgname=testshack2
loc=swedencentral

az group create -n $rgname --location $loc
```

```
az group delete -n $rgname -y --no-wait
```
