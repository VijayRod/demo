```
kubectl delete po fiopod
kubectl delete pvc pvc-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: managed-csi-premium
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - name: azuredisk01
          mountPath: /mnt/data
  volumes:
    - name: azuredisk01
      persistentVolumeClaim:
        claimName: pvc-azuredisk
EOF
sleep 30
kubectl get pv,pvc
kubectl get po -owide
```

```
# To find the associated storage account name

kubectl describe persistentvolume/pvc-4beb23cd-23b2-4809-bfd9-874cbf2c9e58 | grep VolumeH
    VolumeHandle:      /subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/mc_rgnginx_aks_swedencentral/providers/Microsoft.Compute/disks/pvc-4beb23cd-23b2-4809-bfd9-874cbf2c9e58
    
root@aks-nodepool1-88846437-vmss000000:/# df -h | grep pvc-
/dev/sdb                                             98G   24K   98G   1% /var/lib/kubelet/pods/a6a56aa5-b1a4-40b8-9cae-a676e990534f/volumes/kubernetes.io~csi/pvc-4beb23cd-23b2-4809-bfd9-874cbf2c9e58/mount

kubectl exec -it fiopod -- df -h | grep pvc-
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb         98G   24K   98G   1% /mnt/data

# Identify the required properties of the storage account

TBD
storage=fdb45a26ccc354afd94979f
subId=$(az account show --query id -otsv)
noderg=$(az aks show -g $rg -n aks  --query nodeResourceGroup -o tsv)
storageUri=/subscriptions/$subId/resourceGroups/$noderg/providers/Microsoft.Storage/storageAccounts/$storage
az storage account show --ids $storageUri | grep -e name -e largeFile -e tier
az storage account show -n $storage --query networkRuleSet
root@aks-nodepool1-88846437-vmss000002:/# az storage file list --account-name $storage -s pvcn-bb90a1bf-4f83-4e6e-ac4d-18a5c4a152ea ## ShareNotFound
root@aks-nodepool1-88846437-vmss000002:/# az storage file show --account-name $storage -s pvcn-bb90a1bf-4f83-4e6e-ac4d-18a5c4a152ea -p default
Used capacity	:	0 B
Provisioned capacity	:	250 GiB
Maximum IO/s	:	3250
Burst IO/s	:	10000
Throughput rate	:	125.0 MiB / s
    
# Reproduce the issue and review metrics (like in SMB)

kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/data/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60
date
  write: IOPS=3535, BW=13.8MiB/s (14.5MB/s)(829MiB/60005msec); 0 zone resets
    slat (nsec): min=1756, max=1080.4k, avg=5043.35, stdev=4805.33
    clat (usec): min=565, max=193217, avg=4519.50, stdev=11409.13
     lat (usec): min=569, max=193220, avg=4524.55, stdev=11409.00
    clat percentiles (usec):
     |  1.00th=[   652],  5.00th=[   693], 10.00th=[   725], 20.00th=[   766],
     | 30.00th=[   807], 40.00th=[   848], 50.00th=[   898], 60.00th=[   955],
     | 70.00th=[  1029], 80.00th=[  1188], 90.00th=[  5997], 95.00th=[ 38011],
     | 99.00th=[ 52691], 99.50th=[ 54264], 99.90th=[ 55313], 99.95th=[ 56361],
     | 99.99th=[183501]
   bw (  KiB/s): min=11280, max=15448, per=100.00%, avg=14164.64, stdev=623.57, samples=119
   iops        : min= 2820, max= 3862, avg=3541.16, stdev=155.89, samples=119
  lat (usec)   : 750=16.32%, 1000=50.32%
  lat (msec)   : 2=19.09%, 4=3.09%, 10=2.31%, 20=0.26%, 50=7.46%
  lat (msec)   : 100=1.13%, 250=0.02%
  cpu          : usr=0.47%, sys=2.49%, ctx=161058, majf=0, minf=11
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=100.0%, 32=0.0%, >=64=0.0%

## w/s represents the IOPS, w_await represents the latency in milliseconds for write requests, and aqu-sz represents the queue depth.
root@aks-nodepool1-88846437-vmss000000:/# iostat -dxctm 1 /dev/sdb | tee -a /tmp/sdb
root@aks-nodepool1-88846437-vmss000000:/# cat /tmp/sdb
Linux 5.15.0-1041-azure (aks-nodepool1-88846437-vmss000000)     09/25/23        _x86_64_        (4 CPU)
09/24/23 13:00:39
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           1.75    0.00    2.00    0.25    0.00   96.00
Device            r/s     rMB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wMB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dMB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
sdb              0.00      0.00     0.00   0.00    0.00     0.00 3490.00     13.63     0.00   0.00    4.36     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   15.23  95.60
09/24/23 13:00:40
avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.51    0.00    2.02    0.00    0.00   97.47
Device            r/s     rMB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wMB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dMB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
sdb              0.00      0.00     0.00   0.00    0.00     0.00 3560.00     13.91     0.00   0.00    4.53     4.00    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00   16.14 101.60

noderg=$(az aks show -g $rg -n aks  --query nodeResourceGroup -o tsv)
az disk show -g $noderg -n pvc-4beb23cd-23b2-4809-bfd9-874cbf2c9e58 | grep tier
  "tier": "P10",
```  
  
- Max IOPS in https://learn.microsoft.com/en-us/azure/virtual-machines/sizes: Max cached and temp storage throughput: IOPS/MBps; Max uncached disk throughput: IOPS/MBps; Max burst uncached data disk throughput (IOPs/MBps), if any e.g. LSv2
- Max IOPS in https://azure.microsoft.com/en-us/pricing/details/managed-disks/: Max IOPS (Max IOPS w/ bursting), Max throughput (Max throughput w/ bursting)
