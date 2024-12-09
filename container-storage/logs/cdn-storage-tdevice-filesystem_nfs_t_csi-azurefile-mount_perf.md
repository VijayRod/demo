```
kubectl delete po fiopod
kubectl delete pvc pvc-azurefile-nfs
kubectl delete sc azurefile-csi-nfs
# To create the resources
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi-nfs
provisioner: file.csi.azure.com
allowVolumeExpansion: true
parameters:
  protocol: nfs
mountOptions:
  - nconnect=4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-nfs
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: azurefile-csi-nfs
  resources:
    requests:
      storage: 100Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  volumes:
    - name: azurefile
      persistentVolumeClaim:
        claimName: pvc-azurefile-nfs
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: /mnt/data
          name: azurefile
EOF
sleep 10
kubectl get pv,pvc,sc
kubectl get po -owide
```

```
# To find the associated storage account name

kubectl describe persistentvolume/pvc-d267b683-3625-435c-9b8c-d6a756a5fcc6 | grep VolumeH
    VolumeHandle:      mc_rgnginx_aks_swedencentral#fdb45a26ccc354afd94979f#pvcn-d267b683-3625-435c-9b8c-d6a756a5fcc6###default
    
root@aks-nodepool1-16524978-vmss000006:/# df -h | grep pvc-
fdb45a26ccc354afd94979f.file.core.windows.net:/fdb45a26ccc354afd94979f/pvcn-d267b683-3625-435c-9b8c-d6a756a5fcc6  100G     0  100G   0% /var/lib/kubelet/pods/8544b38f-9c6c-4cd0-943a-561b64f1d436/volumes/kubernetes.io~csi/pvc-d267b683-3625-435c-9b8c-d6a756a5fcc6/mount

kubectl exec -it fiopod -- df -h | grep pvc-
Filesystem                                                                                                        Size  Used Avail Use% Mounted on
fdb45a26ccc354afd94979f.file.core.windows.net:/fdb45a26ccc354afd94979f/pvcn-d267b683-3625-435c-9b8c-d6a756a5fcc6  100G     0  100G   0% /volume /mnt/data

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
  write: IOPS=6177, BW=24.1MiB/s (25.3MB/s)(1449MiB/60043msec); 0 zone resets
    slat (nsec): min=1314, max=133744, avg=5845.80, stdev=2502.76
    clat (usec): min=1444, max=4506.0k, avg=2582.90, stdev=28530.89
     lat (usec): min=1449, max=4506.0k, avg=2588.75, stdev=28530.89
    clat percentiles (usec):
     |  1.00th=[ 1598],  5.00th=[ 1680], 10.00th=[ 1745], 20.00th=[ 1876],
     | 30.00th=[ 2147], 40.00th=[ 2245], 50.00th=[ 2442], 60.00th=[ 2540],
     | 70.00th=[ 2671], 80.00th=[ 2802], 90.00th=[ 2933], 95.00th=[ 3064],
     | 99.00th=[ 3458], 99.50th=[ 3785], 99.90th=[ 6325], 99.95th=[ 8848],
     | 99.99th=[22676]
   bw (  KiB/s): min=  272, max=32336, per=100.00%, avg=26258.69, stdev=4772.47, samples=113
   iops        : min=   68, max= 8084, avg=6564.67, stdev=1193.12, samples=113
  lat (msec)   : 2=24.95%, 4=74.70%, 10=0.31%, 20=0.02%, 50=0.01%
  lat (msec)   : >=2000=0.01%
  cpu          : usr=1.67%, sys=5.59%, ctx=336122, majf=0, minf=11
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=100.0%, 32=0.0%, >=64=0.0%
```
