```
rg=rgbatch
storage="batchstorage$RANDOM$RANDOM"
az group create -n $rg -l $loc
az storage account create -g $rg -n $storage
az batch account create -g $rg -n batch --storage-account $storage -l $loc
az batch account login -g $rg -n batch

vmSize=Standard_A1_v2
az batch pool create --id pool1 --image canonical:0001-com-ubuntu-server-focal:20_04-lts --node-agent-sku-id "batch.node.ubuntu 20.04" --vm-size $vmSize

az batch job create --id job1 --pool-id pool1

for i in {1..4}
do
   az batch task create --task-id task$i --job-id job1 --command-line "/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'"
done
```

```
az batch task list --job-id job1 -otable
CommandLine                                         CreationTime                      ETag               LastModified                      RequiredSlots    State    StateTransitionTime               Url
--------------------------------------------------  --------------------------------  -----------------  --------------------------------  ---------------  -------  --------------------------------  -----------------------------------------------------------------
/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'  2023-11-27T19:54:09.247160+00:00  0x8DBEF6117C15D35  2023-11-27T19:54:09.247160+00:00  1                active   2023-11-27T19:54:09.247160+00:00  https://batch.swedencentral.batch.azure.com/jobs/job1/tasks/task1
/bin/bash -c 'printenv | grep AZ_BATCH; sleep 90s'  2023-11-27T19:54:10.007125+00:00  0x8DBEF6118355359  2023-11-27T19:54:10.007125+00:00  1                active   2023-11-27T19:54:10.007125+00:00  https://batch.swedencentral.batch.azure.com/jobs/job1/tasks/task2
```
