```
az vm disk attach -g $rg --vm-name vm --name myDataDisk --new --size-gb 250 --sku Premium_LRS

az disk create -g $rg -n myDataDisk --size-gb 250 --sku Premium_LRS
diskId=$(az disk show -g vm -n myDataDisk --query 'id' -o tsv)
az vm disk attach -g $rg --vm-name vm --name $diskId
```
