Here are the commands to benchmark the available IOPS.

```
# To benchmark the OS disk:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/tmp/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60

# To benchmark the temporary storage disk:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/mnt/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60

# To benchmark the attached volume:
kubectl exec -it fiopod -- fio --name=benchtest --size=800m --filename=/volume/test --direct=1 --rw=write --ioengine=libaio --bs=4k --iodepth=16 --numjobs=1 --time_based --runtime=60
```

```
# Create the storage class and the pod.
cat << EOF | kubectl create -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: managed-premium-nocache
provisioner: kubernetes.io/azure-disk
reclaimPolicy: Delete
parameters:
  storageaccounttype: Premium_LRS
  kind: Managed
  cachingmode: None
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurediskpvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-premium-nocache
  resources:
    requests:
      storage: 250Gi # P15
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  #nodeSelector:
    #kubernetes.azure.com/agentpool: nodepool1
    #kubernetes.io/hostname: aks-nodepool1-85027187-vmss000002
  volumes:
    - name: azurediskpv
      persistentVolumeClaim:
        claimName: azurediskpvc
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: azurediskpv
EOF
```

Here are some related links:
- [AKS/issues/1373](https://github.com/Azure/AKS/issues/1373)
- [virtual-machines/disks-benchmarks#fio](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-benchmarks#fio)
- [virtual-machines/disks-performance](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-performance)
- [virtual-machines/disks-types#premium-ssd-size](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#premium-ssd-size)
- [virtual-machines/disks-types#standard-ssd-size](https://learn.microsoft.com/en-us/azure/virtual-machines/disks-types#standard-ssd-size)
- [virtual-machines/dv2-dsv2-series](https://learn.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series)
- [stian.tech/disk-performance-on-aks-part-1](https://stian.tech/disk-performance-on-aks-part-1/).
