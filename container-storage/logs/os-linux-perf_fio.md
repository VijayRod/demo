```
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: lrs
provisioner: disk.csi.azure.com
parameters:
  cachingMode: None
  skuName: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: lrs
  resources:
    requests:
      storage: 250Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  nodeSelector:
    kubernetes.azure.com/agentpool: d4s3
  volumes:
    - name: azuredisk
      persistentVolumeClaim:
        claimName: pvc-azuredisk
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: /mnt/data
          name: azuredisk
EOF
k get po,pvc
```

```
# To benchmark the OS disk:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/tmp/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60

# To benchmark the temporary storage disk:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60

# To benchmark the attached volume:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/data --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60
```

```
kubectl exec -it fiopod -- bash

cat << EOF > /tmp/fio.conf
[global]
directory=/mnt/data
filesize=32000m
bs=4k                                # 4KB block size
pre_read=1                           # pre-read data to warm up the page cache.
ioengine=libaio                      # Use the psync IO engine to mirror Kafka's IO pattern.
#buffered=1                           # Use buffered IO to mirror Kafka's IO pattern.
rw=readwrite                         # Use sequential reads/writes.
iodepth=32                           # An IO depth of 32.
                                     # Run 4 jobs, each targeting a different file
[file1]
size=25%
[file2]
size=25%
[file3]
size=25%
[file4]
size=25%
EOF
fio /tmp/fio.conf
```

- https://cloud.google.com/compute/docs/disks/benchmarking-pd-performance
- https://docs.oracle.com/en-us/iaas/Content/Block/References/samplefiocommandslinux.htm
- https://fio.readthedocs.io/en/latest/fio_doc.html
- https://github.com/Azure/AKS/issues/1373
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-benchmarks#fio
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-performance
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#premium-ssd-size
- https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssd-size
- https://learn.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series
- https://microsoft.github.io/VirtualClient/docs/workloads/fio/fio-profiles/
- https://stian.tech/disk-performance-on-aks-part-1/
