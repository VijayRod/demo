TBD 

```
rg=rgnfs
storage="storage$RANDOM"
az group create -n $rg -l $loc
az network vnet create -g $rg --name vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none
subnetId=$(az network vnet subnet show -g $rg --vnet-name vnet -n akssubnet --query id -otsv)
az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize -c 1

az storage account create --kind FileStorage --sku Premium_LRS --https-only false -g $rg -n $storage
az storage share-rm create -g $rg --storage-account $storage -n fileshare --enabled-protocols nfs

az network private-dns link vnet create -g $rg -v vnet -n dnslink -z privatelink.file.core.windows.net -e false
```

- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#use-a-persistent-volume-with-private-azure-files-storage-private-endpoint
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-file-share: If the storage account is configured privately with a private link, endpoint, or DNS zone, the hostname will be <storage-account-name>.privatelink.file.core.windows.net.
- TBD https://medium.com/cooking-with-azure/nfsv4-with-azure-files-and-azure-kubernetes-service-141ee8258fd2
