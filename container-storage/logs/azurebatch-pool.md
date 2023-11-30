```
rg=rgbatch
storage="batchstorage$RANDOM$RANDOM"
az group create -n $rg -l $loc
az storage account create -g $rg -n $storage
az batch account create -g $rg -n batch --storage-account $storage -l $loc
az batch account login -g $rg -n batch

vmSize=Standard_A1_v2
az batch pool create --id pool1 --image canonical:0001-com-ubuntu-server-focal:20_04-lts --node-agent-sku-id "batch.node.ubuntu 20.04" --vm-size $vmSize # --target-dedicated-nodes 2
az batch pool show --pool-id pool1 --query allocationState # "steady". https://batch.swedencentral.batch.azure.com/pools/pool1
```

```
az batch pool list -otable
az batch pool delete --pool-id pool1
```

- https://learn.microsoft.com/en-us/azure/batch/quick-create-cli#create-a-pool-of-compute-nodes
