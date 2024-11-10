```
rg=rgnetapp
netapp=netapp
az group create -n $rg -l $loc
az netappfiles account create -g $rg -n $netapp
az netappfiles account show -g $rg -n $netapp --query id -otsv
# /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.NetApp/netAppAccounts/netapp

az netappfiles pool create -g $rg --account-name $netapp -n pool1 --size 2 --service-level Premium # size in TiB, service-level is Standard, Premium or Ultra
az netappfiles pool show -g $rg --account-name $netapp -n pool1

vnet=vnet
filepath="filepath$RANDOM"
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n netappsubnet --address-prefixes 10.241.0.0/16 --delegations "Microsoft.Netapp/volumes" -o none
vnetId=$(az network vnet show -g $rg --name $vnet --query id -otsv)
subnetIdNetapp=$(az network vnet subnet show -g $rg --vnet-name $vnet -n netappsubnet --query id -otsv)
az netappfiles volume create -g $rg --account-name $netapp --pool-name pool1 -n volume1 --usage-threshold 100 --file-path $filepath --protocol-types NFSv3 --vnet $vnetId --subnet $subnetId # 100 GB
az netappfiles volume show -g $rg --account-name $netapp --pool-name pool1 -n volume1 --query id -otsv
# /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/rg/providers/Microsoft.NetApp/netAppAccounts/netapp/capacityPools/pool1/volumes/volume1
```
