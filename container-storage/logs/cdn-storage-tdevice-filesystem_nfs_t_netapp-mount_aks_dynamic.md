```
TBD

rg=rgnetapp
netapp=netapp
az group create -n $rg -l $loc
az netappfiles account create -g $rg -n $netapp
az netappfiles pool create -g $rg --account-name $netapp -n pool1 --size 2 --service-level Premium

vnet=vnet
filepath="filepath$RANDOM"
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n netappsubnet --address-prefixes 10.241.0.0/16 --delegations "Microsoft.Netapp/volumes" -o none 
vnetId=$(az network vnet show -g $rg --name $vnet --query id -otsv)
subnetId=$(az network vnet subnet show -g $rg --vnet-name $vnet -n akssubnet --query id -otsv)
subnetIdNetapp=$(az network vnet subnet show -g $rg --vnet-name $vnet -n netappsubnet --query id -otsv)

az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize
az aks get-credentials -g $rg -n aks --overwrite-existing

helm repo add netapp-trident https://netapp.github.io/trident-helm-chart   
helm install trident netapp-trident/trident-operator --version 23.04.0  --create-namespace --namespace trident
kubectl describe torc trident | tail

    Trident Image:        docker.io/netapp/trident:23.04.0
  Message:                Trident installed
  Namespace:              trident
  Status:                 Installed
  Version:                v23.04.0
Events:
  Type    Reason      Age   From                        Message
  ----    ------      ----  ----                        -------
  Normal  Installing  68s   trident-operator.netapp.io  Installing Trident
  Normal  Installed   32s   trident-operator.netapp.io  Trident installed
```

- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-netapp-files
- https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files
- https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-nfs
