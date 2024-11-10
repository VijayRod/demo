```
kubectl delete po nginx-nfs
kubectl deleve pv pv-nfs
kubectl deleve pvc pvc-nfs
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 100Gi
  accessModes:
  - ReadWriteMany
  mountOptions:
  - vers=3
  nfs:
    server: $ipAddress #
    path: /$creationToken #
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: ""
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
  - image: nixery.dev/shell/fio
    name: fio
    args:
      - sleep
      - "1000000"
    volumeMounts:
    - name: disk01
      mountPath: /mnt/data
  volumes:
  - name: disk01
    persistentVolumeClaim:
      claimName: pvc-nfs
EOF
sleep 20
kubectl get pv,pvc
kubectl get po -owide
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/data/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60
date
```

```
  write: IOPS=1613, BW=6454KiB/s (6609kB/s)(378MiB/60007msec); 0 zone resets
    slat (usec): min=2, max=10263, avg=16.25, stdev=53.73
    clat (usec): min=42, max=60652, avg=9898.32, stdev=5458.56
     lat (usec): min=659, max=60663, avg=9914.57, stdev=5455.66
    clat percentiles (usec):
     |  1.00th=[  709],  5.00th=[  775], 10.00th=[  840], 20.00th=[ 9896],
     | 30.00th=[10552], 40.00th=[10683], 50.00th=[10814], 60.00th=[10945],
     | 70.00th=[10945], 80.00th=[11076], 90.00th=[12256], 95.00th=[20579],
     | 99.00th=[21103], 99.50th=[30016], 99.90th=[31065], 99.95th=[31327],
     | 99.99th=[50070]
   bw (  KiB/s): min= 6296, max=12696, per=100.00%, avg=6456.54, stdev=578.32, samples=119
   iops        : min= 1574, max= 3174, avg=1614.13, stdev=144.58, samples=119
  lat (usec)   : 50=0.01%, 250=0.01%, 500=0.01%, 750=3.54%, 1000=13.01%
  lat (msec)   : 2=2.86%, 4=0.13%, 10=1.10%, 20=70.26%, 50=9.09%
  lat (msec)   : 100=0.01%
  cpu          : usr=0.50%, sys=1.73%, ctx=84187, majf=0, minf=10
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=100.0%, 32=0.0%, >=64=0.0%
```
