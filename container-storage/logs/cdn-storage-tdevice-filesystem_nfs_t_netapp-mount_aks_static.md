```
rg=rgnetapp
netapp="netapp$RANDOM"
az group create -n $rg -l $loc
az netappfiles account create -g $rg -n $netapp
az netappfiles pool create -g $rg --account-name $netapp -n pool1 --size 2 --service-level Premium

vnet=vnet
az network vnet create -g $rg --name $vnet --address-prefixes 10.0.0.0/8 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n akssubnet --address-prefixes 10.240.0.0/16 -o none 
az network vnet subnet create -g $rg --vnet-name $vnet -n netappsubnet --address-prefixes 10.241.0.0/16 --delegations "Microsoft.Netapp/volumes" -o none # Same virtual network as AKS cluster
subnetId=$(az network vnet subnet show -g $rg --vnet-name $vnet -n akssubnet --query id -otsv)
subnetIdNetapp=$(az network vnet subnet show -g $rg --vnet-name $vnet -n netappsubnet --query id -otsv)
az netappfiles volume create -g $rg --account-name $netapp --pool-name pool1 -n volume1 --usage-threshold 100 --file-path $filepath --protocol-types NFSv3 --vnet $vnetId --subnet $subnetIdNetapp # 100 GB
creationToken=$(az netappfiles volume show -g $rg --account-name $netapp --pool-name pool1 -n volume1 --query creationToken -otsv) # filepath1543
ipAddress=$(az netappfiles volume show -g $rg --account-name $netapp --pool-name pool1 -n volume1 --query mountTargets[0].ipAddress -otsv) # 10.241.0.4

az aks create -g $rg -n aks --vnet-subnet-id $subnetId -s $vmsize
az aks get-credentials -g $rg -n aks --overwrite-existing

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
  name: nginx-nfs
spec:
  containers:
  - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
    name: nginx-nfs
    command:
    - "/bin/sh"
    - "-c"
    - while true; do echo $(date) >> /mnt/azure/outfile; sleep 1; done
    volumeMounts:
    - name: disk01
      mountPath: /mnt/azure
  volumes:
  - name: disk01
    persistentVolumeClaim:
      claimName: pvc-nfs
EOF
sleep 20
kubectl get pv,pvc
kubectl get po -owide
kubectl exec -it nginx-nfs -- df -h
```

```
Filesystem                Size      Used Available Use% Mounted on
10.241.0.4:/filepath1543
                        100.0G         0    100.0G   0% /mnt/azure

root@aks-nodepool1-38439996-vmss000002:/# df -h
10.241.0.4:/filepath1543  100G     0  100G   0% /var/lib/kubelet/pods/6161560d-09bb-4847-b9b5-1e71b3a8b663/volumes/kubernetes.io~nfs/pv-nfs

root@aks-nodepool1-38439996-vmss000002:/# cat /var/log/syslog
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 kubelet[2551]: I0927 23:00:20.086700    2551 reconciler_common.go:253] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pv-nfs\" (UniqueName: \"kubernetes.io/nfs/6161560d-09bb-4847-b9b5-1e71b3a8b663-pv-nfs\") pod \"nginx-nfs\" (UID: \"6161560d-09bb-4847-b9b5-1e71b3a8b663\") " pod="default/nginx-nfs"
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 kubelet[2551]: I0927 23:00:20.187273    2551 reconciler_common.go:228] "operationExecutor.MountVolume started for volume \"pv-nfs\" (UniqueName: \"kubernetes.io/nfs/6161560d-09bb-4847-b9b5-1e71b3a8b663-pv-nfs\") pod \"nginx-nfs\" (UID: \"6161560d-09bb-4847-b9b5-1e71b3a8b663\") " pod="default/nginx-nfs"
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Listening on RPCbind Server Activation Socket.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Starting NFS status monitor for NFSv2/3 locking....
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Starting RPC bind portmap service...
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 rpc.statd[48064]: Version 2.6.1 starting
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 rpc.statd[48064]: Flags: TI-RPC
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 rpc.statd[48064]: Failed to read /var/lib/nfs/state: Success
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 rpc.statd[48064]: Initializing NSM state
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Started RPC bind portmap service.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Started NFS status monitor for NFSv2/3 locking..
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Reached target RPC Port Mapper.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Reloading.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Configuration file /etc/systemd/system/sync-container-logs.service is marked world-inaccessible. This has no effect as configuration data is accessible via APIs without restrictions. Proceeding anyway.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Configuration file /etc/systemd/system/kubelet.service is marked world-inaccessible. This has no effect as configuration data is accessible via APIs without restrictions. Proceeding anyway.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Configuration file /etc/systemd/system/kubelet.service.d/10-tlsbootstrap.conf is marked world-inaccessible. This has no effect as configuration data is accessible via APIs without restrictions. Proceeding anyway.
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 systemd[1]: Starting Discard unused blocks on filesystems from /etc/fstab...
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 kernel: [ 1987.218468] FS-Cache: Loaded
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 kernel: [ 1987.285481] FS-Cache: Netfs 'nfs' registered for caching
Sep 27 23:00:20 aks-nodepool1-38439996-vmss000002 kubelet[2551]: I0927 23:00:20.856818    2551 operation_generator.go:740] "MountVolume.SetUp succeeded for volume \"pv-nfs\" (UniqueName: \"kubernetes.io/nfs/6161560d-09bb-4847-b9b5-1e71b3a8b663-pv-nfs\") pod \"nginx-nfs\" (UID: \"6161560d-09bb-4847-b9b5-1e71b3a8b663\") " pod="default/nginx-nfs"

kubectl describe pv
Name:            pv-nfs
Labels:          <none>
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:
Status:          Bound
Claim:           default/pvc-nfs
Reclaim Policy:  Retain
Access Modes:    RWX
VolumeMode:      Filesystem
Capacity:        100Gi
Node Affinity:   <none>
Message:
Source:
    Type:      NFS (an NFS mount that lasts the lifetime of a pod)
    Server:    10.241.0.4
    Path:      /filepath1543
    ReadOnly:  false
Events:        <none>
```

- https://learn.microsoft.com/en-us/azure/aks/azure-netapp-files-nfs#statically-configure-for-applications-that-use-nfs-volumes
