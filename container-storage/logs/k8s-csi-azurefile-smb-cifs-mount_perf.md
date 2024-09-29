```
kubectl delete po fiopod
kubectl delete pvc pvc-azurefile
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-csi # Standard_LRS
  resources:
    requests:
      storage: 100Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  containers:
  - name: fio
    image: nixery.dev/shell/fio
    args:
      - sleep
      - "1000000"
    volumeMounts:
    - mountPath: /mnt/data
      name: azurefile
  volumes:
  - name: azurefile
    persistentVolumeClaim:
      claimName: pvc-azurefile
EOF
sleep 10
kubectl get pv,pvc
kubectl get po -owide
```

```
# To find the associated storage account name

kubectl describe persistentvolume/pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d | grep VolumeH
    VolumeHandle:      mc_rg_aks_swedencentral#f5fec18f1094a4c1d9c9058#pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d###default
    
root@aks-nodepool1-16524978-vmss000006:/# df -h | grep pvc-
//f5fec18f1094a4c1d9c9058.file.core.windows.net/pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d  100G     0  100G   0% /var/lib/kubelet/pods/265655bb-d6a6-4c19-bd4d-763eb82b5b65/volumes/kubernetes.io~csi/pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d/mount

kubectl exec -it mypod-perf -- df -h | grep pvc-
//f5fec18f1094a4c1d9c9058.file.core.windows.net/pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d  100G     0  100G   0% /mnt/azure

# Identify the required properties of the storage account

storage=f5fec18f1094a4c1d9c9058
subId=$(az account show --query id -otsv)
noderg=$(az aks show -g $rg -n aks  --query nodeResourceGroup -o tsv)
storageUri=/subscriptions/$subId/resourceGroups/$noderg/providers/Microsoft.Storage/storageAccounts/$storage
az storage account show --ids $storageUri | grep -e name -e largeFile -e tier
  "largeFileSharesState": null,
    "name": "Standard_LRS",
    "tier": "Standard"
    
# Reproduce the issue and review metrics

kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/data/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60
date
  write: IOPS=981, BW=3927KiB/s (4021kB/s)(230MiB/60093msec); 0 zone resets
    slat (usec): min=7, max=706, avg=18.34, stdev=10.10
    clat (msec): min=2, max=760, avg=16.27, stdev=39.69
     lat (msec): min=2, max=760, avg=16.29, stdev=39.69
    clat percentiles (msec):
     |  1.00th=[    3],  5.00th=[    3], 10.00th=[    3], 20.00th=[    3],
     | 30.00th=[    3], 40.00th=[    3], 50.00th=[    4], 60.00th=[    4],
     | 70.00th=[    4], 80.00th=[    4], 90.00th=[   71], 95.00th=[   95],
     | 99.00th=[  201], 99.50th=[  228], 99.90th=[  330], 99.95th=[  397],
     | 99.99th=[  523]
   bw (  KiB/s): min= 3416, max= 4432, per=100.00%, avg=3932.27, stdev=293.19, samples=120
   iops        : min=  854, max= 1108, avg=983.07, stdev=73.30, samples=120
  lat (msec)   : 4=82.46%, 10=4.02%, 20=0.14%, 50=1.16%, 100=8.34%
  lat (msec)   : 250=3.48%, 500=0.38%, 750=0.01%, 1000=0.01%
  cpu          : usr=0.39%, sys=1.99%, ctx=48102, majf=0, minf=11
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=100.0%, 32=0.0%, >=64=0.0%

root@aks-nodepool1-16524978-vmss000006:/# cifsiostat -h -t -m 1
09/22/23 18:30:01
        rMB/s        wMB/s    rops/s    wops/s         fo/s         fc/s         fd/s Filesystem
         0.0B         3.8M      0.00    964.00         0.00         0.00         0.00 \\f5fec18f1094a4c1d9c9058.file.core.windows.net\pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d
09/22/23 18:30:01
        rMB/s        wMB/s    rops/s    wops/s         fo/s         fc/s         fd/s Filesystem
         0.0B         3.8M      0.00    964.00         0.00         0.00         0.00 \\f5fec18f1094a4c1d9c9058.file.core.windows.net\pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d
09/22/23 18:30:02
        rMB/s        wMB/s    rops/s    wops/s         fo/s         fc/s         fd/s Filesystem
         0.0B         3.8M      0.00    962.00         0.00         0.00         0.00 \\f5fec18f1094a4c1d9c9058.file.core.windows.net\pvc-5ab68046-c9b7-41af-94cb-b0b877ca463d
...

starttime=2023-09-22T18:30:00Z
endtime=2023-09-22T18:35:00Z
## az monitor metrics list-definitions --resource $storageUri -otable
az monitor metrics list --resource $storageUri --metric Transactions --start-time $starttime --end-time $endtime -otable # Default --interval is PT1M (1 minute)
Timestamp            Name          Total
-------------------  ------------  -------
2023-09-22 18:30:00  Transactions  19581.0
2023-09-22 18:31:00  Transactions  39432.0

az monitor metrics list --resource $storageUri --metric Transactions --dimension ResponseType --start-time $starttime --end-time $endtime -otable
2023-09-22 18:30:00  Transactions  Success                         17006.0
2023-09-22 18:31:00  Transactions  Success                         34137.0
2023-09-22 18:32:00  Transactions  Success                         6.0
2023-09-22 18:33:00  Transactions  Success                         0.0
2023-09-22 18:34:00  Transactions  Success                         6.0
2023-09-22 18:30:00  Transactions  SuccessWithShareIopsThrottling  2575.0
2023-09-22 18:31:00  Transactions  SuccessWithShareIopsThrottling  5295.0
2023-09-22 18:32:00  Transactions  SuccessWithShareIopsThrottling  0.0
2023-09-22 18:33:00  Transactions  SuccessWithShareIopsThrottling  0.0
2023-09-22 18:34:00  Transactions  SuccessWithShareIopsThrottling  0.0
2023-09-22 18:30:00  Transactions  ClientOtherError                0.0
2023-09-22 18:31:00  Transactions  ClientOtherError                0.0
2023-09-22 18:32:00  Transactions  ClientOtherError                0.0
2023-09-22 18:33:00  Transactions  ClientOtherError                0.0
2023-09-22 18:34:00  Transactions  ClientOtherError                0.0

az monitor metrics list --resource $storageUri --metric Transactions --dimension ApiName --start-time $starttime --end-time $endtime -otable
Timestamp            Name          Apiname             Total
-------------------  ------------  ------------------  -------
2023-09-22 18:30:00  Transactions  Write               19574.0
2023-09-22 18:31:00  Transactions  Write               39425.0
2023-09-22 18:30:00  Transactions  Close               2.0
2023-09-22 18:31:00  Transactions  Close               3.0
2023-09-22 18:30:00  Transactions  Create              3.0
2023-09-22 18:31:00  Transactions  Create              2.0
2023-09-22 18:30:00  Transactions  QueryInfo           2.0
2023-09-22 18:31:00  Transactions  QueryInfo           2.0
2023-09-22 18:30:00  Transactions  SetShareProperties  0.0
2023-09-22 18:31:00  Transactions  SetShareProperties  0.0
2023-09-22 18:30:00  Transactions  SetShareMetadata    0.0
2023-09-22 18:31:00  Transactions  SetShareMetadata    0.0
2023-09-22 18:30:00  Transactions  TreeDisconnect      0.0
2023-09-22 18:31:00  Transactions  TreeDisconnect      0.0
2023-09-22 18:30:00  Transactions  CreateShare         0.0
2023-09-22 18:31:00  Transactions  CreateShare         0.0
2023-09-22 18:30:00  Transactions  SessionSetup        0.0
2023-09-22 18:31:00  Transactions  SessionSetup        0.0
2023-09-22 18:30:00  Transactions  TreeConnect         0.0
2023-09-22 18:31:00  Transactions  TreeConnect         0.0

az monitor metrics list --resource $storageUri --metric SuccessE2ELatency --start-time $starttime --end-time $endtime -otable
Timestamp            Name                 Average
-------------------  -------------------  ------------------
2023-09-22 18:29:00  Success E2E Latency  30.0
2023-09-22 18:30:00  Success E2E Latency  16.20412644910883
2023-09-22 18:31:00  Success E2E Latency  16.300491986204097
2023-09-22 18:32:00  Success E2E Latency  29.5

az monitor metrics list --resource $storageUri --metric SuccessServerLatency --start-time $starttime --end-time $endtime -otable
Timestamp            Name                    Average
-------------------  ----------------------  ------------------
2023-09-22 18:30:00  Success Server Latency  15.134255949341231
2023-09-22 18:31:00  Success Server Latency  15.206791610661663
2023-09-22 18:32:00  Success Server Latency  2.8333333333333335
2023-09-22 18:33:00  Success Server Latency
2023-09-22 18:34:00  Success Server Latency  2.5

az monitor metrics list --resource $storageUri --metric "UsedCapacity" --start-time $starttime --end-time $endtime -otable --interval PT1H
Timestamp            Name
-------------------  -------------
2023-09-22 18:30:00  Used capacity

az monitor metrics list --resource $storageUri --metric "Availability" --start-time $starttime --end-time $endtime -otable --interval PT1H
Timestamp            Name          Average
-------------------  ------------  ---------
2023-09-22 18:30:00  Availability  100.0
2023-09-22 18:31:00  Availability  100.0
2023-09-22 18:32:00  Availability  100.0
2023-09-22 18:33:00  Availability
2023-09-22 18:34:00  Availability  100.0
```

- https://learn.microsoft.com/en-us/azure/storage/files/storage-files-scale-targets#azure-file-share-scale-targets: Standard file shares. Maximum request rate (Max IOPS). 1,000 or 100 requests per 100 ms, default (20,000, with large file share feature enabled)
- https://learn.microsoft.com/en-us/azure/storage/files/storage-files-monitoring-reference: ResponseType. SuccessWithThrottling, SuccessWithShareIopsThrottling, ClientShareIopsThrottlingError
