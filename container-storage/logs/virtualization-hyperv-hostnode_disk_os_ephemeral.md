## ephemeraldisk-os

Here are the commands to create a cluster with an ephemeral OS disk.

```
# aks
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aks --node-osdisk-type Ephemeral -s $vmsize -c 2
az aks get-credentials -g $rg -n $aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n np2 --node-osdisk-type Ephemeral # --node-osdisk-size 128

kubectl describe no
Capacity:
  ephemeral-storage:  129886128Ki
Allocatable:
  ephemeral-storage:  119703055367
Allocated resources:
  Resource           Requests     Limits
  --------           --------     ------
  ephemeral-storage  0 (0%)       0 (0%)
```

- [aks/cluster-configuration#ephemeral-os](https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#ephemeral-os)
- [azure-samples/aks-ephemeral-os-disk](https://learn.microsoft.com/en-us/samples/azure-samples/aks-ephemeral-os-disk/aks-ephemeral-os-disk/), also at [Azure-Samples/aks-ephemeral-os-disk](https://github.com/Azure-Samples/aks-ephemeral-os-disk)
  - [fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/everything-you-want-to-know-about-ephemeral-os-disks-and-azure/ba-p/3565605)
    
```
# vm
az vm create -g $rg -n vm --image Ubuntu2204 --ephemeral-os-disk # --admin-username azureuser --public-ip-sku Standard --ephemeral-placement CacheDisk or ResourceDisk

TBD (No ephemeral property in the below)
az vm show -g $rg -n vm --query storageProfile.osDisk.managedDisk.id -otsv
az disk show -id 
az vm get-instance-view -g $rg -n vm
```

- [virtual-machines/ephemeral-os-disks](https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks).

## ephemeraldisk-os.iops

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
