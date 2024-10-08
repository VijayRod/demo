## azureblob-fuse

Here are steps from https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi to install this driver.
      
```
rg=rgblob
az group create -g $rg -l swedencentral
az aks create -g $rg -n aks --enable-blob-driver -s $vmsize -c 2

az aks show -g $rg -n aks --query storageProfile.blobCsiDriver -otsv
True
```

```
# Alternate installation
az aks create -g $rg -n aks

# Here is a sample output below.
#   "storageProfile": {
#     "blobCsiDriver": null,

# To enable the Azure blob CSI driver.
az aks update --enable-blob-driver -g $rg -n aks

# Here is a sample output below.
# Please make sure there is no open-source Blob CSI driver installed before enabling. (y/N): y
# ...
#   "storageProfile": {
#     "blobCsiDriver": {
#       "enabled": true
```

```
# To get credentials for running commands further below.
az aks get-credentials -g $rg -n aks --overwrite-existing

kubectl get sc
NAME                     PROVISIONER          RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
azureblob-fuse-premium   blob.csi.azure.com   Delete          Immediate              true                   74s
azureblob-nfs-premium    blob.csi.azure.com   Delete          Immediate              true                   74s

kubectl get ds -n kube-system
NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
csi-blob-node                1         1         1       1            1           <none>          44m

# To retrieve related pods.
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below. Each node has a csi-blob-node pod. This does not include controller pods unlike the open source version.
csi-blob-node-wvn8q                   3/3     Running   0          104m   10.224.0.4    aks-nodepool1-14487815-vmss000002   <none>           <none>
csi-blob-node-zlvql                   3/3     Running   0          104m   10.224.0.5    aks-nodepool1-14487815-vmss000000   <none>           <none>
csi-blob-node-zp2rl                   3/3     Running   0          104m   10.224.0.6    aks-nodepool1-14487815-vmss000001   <none>           <none>

# To know the image. 
kubectl get po -n kube-system csi-blob-node-wvn8q -oyaml | grep image: | grep blob

# Here is a sample output below.
#    image: mcr.microsoft.com/oss/kubernetes-csi/blob-csi:v1.19.5
```

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/nodeserver.go
- https://github.com/kubernetes-sigs/blob-csi-driver#usage (features)
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/csi-debug.md
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/design.md: To prevent possible regression issues, Azure Blob Storage CSI driver use azure cloud provider library. Thus, all bug fixes in the built-in blobfuse plugin would be incorporated into this driver.
- https://github.com/kubernetes-sigs/blob-csi-driver/tree/master/deploy/example
- https://github.com/Azure/AKS/tree/master/vhd-notes
- https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/app-platform/aks/storage: (Volume refers to a) blob storage container
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-blob-storage
- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi
- https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi#azure-blob-storage-csi-driver-features
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/storage/mounting-azure-blob-storage-container-fail
- https://github.com/Azure/azure-storage-fuse/blob/main/TSG.md
- https://github.com/Seagate/cloudfuse: Cloudfuse is a fork of blobfuse2, and adds S3 support, a GUI, and Windows support

## azureblob-fuse.debug

```
k get po -A -owide | grep blob
kube-system   csi-blob-node-4zzxn                   4/4     Running   0          30m   10.224.0.4   aks-nodepool1-18418801-vmss000001   <none>           <none>
kube-system   csi-blob-node-bnrss                   4/4     Running   0          30m   10.224.0.5   aks-nodepool1-18418801-vmss000000   <none>           <none>

kubectl logs -n kube-system csi-blob-node-zd69f -c blob
```

```
# k exec -it -n kube-system csi-blob-node-4zzxn -c blob -- /bin/bash

ps -ef | grep csi # Or ps aux | grep csi
...
root        6480    4765  0 08:40 ?        00:00:00 /blobplugin --v=5 --endpoint=unix:///csi/csi.sock --blobfuse-proxy-endpoint=unix:///csi/blobfuse-proxy.sock --enable-blobfuse-proxy=true --nodeid=aks-nodepool1-18418801-vmss000001 --user-agent-suffix=AKS --enable-aznfs-mount=true

/blobplugin -h

# Streaming logs
/blobplugin --v=5 --endpoint=unix:///csi/csi.sock --blobfuse-proxy-endpoint=unix:///csi/blobfuse-proxy.sock --enable-blobfuse-proxy=true --nodeid=aks-nodepool1-18418801-vmss000001 --user-agent-suffix=AKS --enable-aznfs-mount=true
I1008 09:39:51.392013   86532 main.go:74] driver userAgent: blob.csi.azure.com/v1.23.7 AKS
...
Streaming logs below:
^C

# /blobplugin --v=7 with round_trippers GET
root@aks-nodepool1-18418801-vmss000001:/# /blobplugin --v=7 --endpoint=unix:///csi/csi.sock --blobfuse-proxy-endpoint=unix:///csi/blobfuse-proxy.sock --enable-blobfuse-proxy=true>
I1008 19:44:10.364913   93125 main.go:74] driver userAgent: blob.csi.azure.com/v1.23.7 AKS
W1008 19:44:10.364950   93125 client_config.go:618] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
I1008 19:44:10.365276   93125 util.go:339] set QPS(25.000000) and QPS Burst(50) for driver kubeClient
I1008 19:44:10.365757   93125 azure.go:62] reading cloud config from secret kube-system/azure-cloud-provider
I1008 19:44:10.366188   93125 round_trippers.go:463] GET https://aks-rgblob-efec8e-l5w3h6rx.hcp.swedencentral.azmk8s.io:443/api/v1/namespaces/kube-system/secrets/azure-cloud-provider
I1008 19:44:10.366499   93125 round_trippers.go:469] Request Headers:
I1008 19:44:10.366763   93125 round_trippers.go:473]     Authorization: Bearer <masked>
I1008 19:44:10.367031   93125 round_trippers.go:473]     Accept: application/json, */*
I1008 19:44:10.367294   93125 round_trippers.go:473]     User-Agent: blob.csi.azure.com/v1.23.7 AKS
I1008 19:44:10.403193   93125 round_trippers.go:574] Response Status: 404 Not Found in 35 milliseconds

ss
Netid    State     Recv-Q    Send-Q                                                                            Local Address:Port                   Peer Address:Port     Process
u_dgr    ESTAB     0         0                                                                           /run/systemd/notify 13780                             * 0
u_dgr    ESTAB     0         0                                                                  /run/systemd/journal/dev-log 13808                             * 0
u_dgr    ESTAB     0         0                                                                   /run/systemd/journal/socket 13810                             * 0
u_dgr    ESTAB     0         0                                                                      /run/chrony/chronyd.sock 18009                             * 0
u_str    ESTAB     0         0            /run/containerd/s/a63fe07dfc068c5b6720e9188eb39bdfcbbc0e6f2399165683de01c4c2e605cc 32601                             * 33574

ping 10.224.0.4
bash: ping: command not found
netstat -atunp | grep -E "10.224.0.4|10.224.0.5"
bash: netstat: command not found
strace
bash: strace: command not found

apt-get update -y && apt-get install net-tools strace -y
ping 10.224.0.4
PING 10.224.0.4 (10.224.0.4) 56(84) bytes of data.
64 bytes from 10.224.0.4: icmp_seq=1 ttl=64 time=0.033 ms
64 bytes from 10.224.0.4: icmp_seq=2 ttl=64 time=0.044 ms
netstat -atunp | grep -E "10.224.0.4|10.224.0.5"
tcp        0      0 10.224.0.4:19100        0.0.0.0:*               LISTEN      8302/node-exporter
tcp        0      0 10.224.0.4:49854        169.254.169.254:80      TIME_WAIT   -
tcp        0      0 10.224.0.4:49826        169.254.169.254:80      TIME_WAIT   -

strace -s 99 -ffp 8302
strace: Process 8302 attached with 5 threads
[pid  8306] futex(0xc000061948, FUTEX_WAIT_PRIVATE, 0, NULL <unfinished ...>
[pid  8305] futex(0xc000061148, FUTEX_WAIT_PRIVATE, 0, NULL <unfinished ...>
[pid  8304] futex(0xc000060948, FUTEX_WAIT_PRIVATE, 0, NULL <unfinished ...>
[pid  8303] restart_syscall(<... resuming interrupted read ...> <unfinished ...>
[pid  8302] epoll_pwait(4, [{events=EPOLLIN|EPOLLOUT, data={u32=759693314, u64=9179953998470840322}}], 128, -1, NULL, 0) = 1
[pid  8302] futex(0x1171da0, FUTEX_WAKE_PRIVATE, 1 <unfinished ...>
[pid  8303] <... restart_syscall resumed>) = 0
```

## azureblob-fuse.driver.parameter
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#storage-class-parameters-for-dynamic-persistent-volumes

## azureblob-fuse.driver.parameter.isHnsEnabled
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: enable Hierarchical namespace for Azure DataLake storage account
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-nfs%2Csecret#before-you-begin: To support an Azure DataLake Gen2 storage account when using blobfuse mount...
  - https://github.com/Azure/AKS/issues/4274#issuecomment-2102486680: ADLS (Azure DataLake Gen2 storage account). isHnsEnabled: "true" in the storage class parameters. mount option --use-adls=true in the persistent volume. If you are going to enable a storage account with Hierarchical Namespace, existing persistent volumes should be remounted with --use-adls=true mount option.

## azureblob-fuse.driver.parameter.protocol.fuse

```
kubectl describe sc azureblob-fuse-premium
Name:                  azureblob-fuse-premium
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           blob.csi.azure.com
Parameters:            skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:
  -o allow_other
  --file-cache-timeout-in-seconds=120
  --use-attr-cache=true
  --cancel-list-on-mount-seconds=10
  -o attr_timeout=120
  -o entry_timeout=120
  -o negative_timeout=120
  --log-level=LOG_WARNING
  --cache-size-mb=1000
ReclaimPolicy:      Delete
VolumeBindingMode:  Immediate
Events:             <none>
```

```
kubectl delete statefulset statefulset-blob
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: statefulset-blob
  labels:
    app: nginx
spec:
  serviceName: statefulset-blob
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
        - name: statefulset-blob
          image: nginx
          volumeMounts:
            - name: persistent-storage
              mountPath: /mnt/blob
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app: nginx
  volumeClaimTemplates:
    - metadata:
        name: persistent-storage
      spec:
        storageClassName: azureblob-fuse-premium
        accessModes: ["ReadWriteMany"]
        resources:
          requests:
            storage: 100Gi
EOF
kubectl get po -w
```

```
kubectl delete po mypod
kubectl delete pvc pvc-azureblob-fuse
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-premium
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
EOF
kubectl get po -w

kubectl get secret
NAME                                                   TYPE     DATA   AGE
azure-storage-account-fused6a211cbd37d4469a72-secret   Opaque   2      28m

kubectl describe secret
Name:         azure-storage-account-fused6a211cbd37d4469a72-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
azurestorageaccountkey:   88 bytes
azurestorageaccountname:  23 bytes

kubectl logs -n kube-system csi-blob-node-zd69f -c blob
I1004 18:04:17.352023    5991 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
I1004 18:04:17.352040    5991 utils.go:105] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["-o allow_other","--file-cache-timeout-in-seconds=120","--use-attr-cache=true","--cancel-list-on-mount-seconds=10","-o attr_timeout=120","-o entry_timeout=120","-o negative_timeout=120","--log-level=LOG_WARNING","--cache-size-mb=1000"]}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/pv/name":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/pvc/name":"pvc-azureblob-fuse","csi.storage.k8s.io/pvc/namespace":"default","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1728056647464-33-blob.csi.azure.com"},"volume_id":"MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#"}
I1004 18:04:17.352392    5991 blob.go:504] volumeID(MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#) authEnv: []
I1004 18:04:17.414838    5991 blob.go:911] got storage account(fused6a211cbd37d4469a72) from secret(azure-storage-account-fused6a211cbd37d4469a72-secret) namespace(default)
I1004 18:04:17.414887    5991 nodeserver.go:386] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount
protocol

volumeId MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#
mountflags [-o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000]
mountOptions [-o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384
serverAddress fused6a211cbd37d4469a72.blob.core.windows.net
I1004 18:04:17.414905    5991 nodeserver.go:166] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384
I1004 18:04:17.415364    5991 nodeserver.go:175] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount -o allow_other --file-cache-timeout-in-seconds=120 --use-attr-cache=true --cancel-list-on-mount-seconds=10 -o attr_timeout=120 -o entry_timeout=120 -o negative_timeout=120 --log-level=LOG_WARNING --cache-size-mb=1000 --pre-mount-validate=true --use-https=true --empty-dir-check=false --tmp-path=/mnt/MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# --container-name=pvc-5428d94a-923c-4d42-8496-6038f9ac8384
I1004 18:04:18.645913    5991 mount_linux.go:282] Detected umount with safe 'not mounted' behavior
I1004 18:04:18.646050    5991 nodeserver.go:645] blobfuse mount at /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount success
I1004 18:04:18.646073    5991 nodeserver.go:444] volume(MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#) mount on "/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount" succeeded
I1004 18:04:18.646095    5991 utils.go:111] GRPC response: {}
I1004 18:04:18.666667    5991 utils.go:104] GRPC call: /csi.v1.Node/NodePublishVolume
I1004 18:04:18.666682    5991 utils.go:105] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount","target_path":"/var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["-o allow_other","--file-cache-timeout-in-seconds=120","--use-attr-cache=true","--cancel-list-on-mount-seconds=10","-o attr_timeout=120","-o entry_timeout=120","-o negative_timeout=120","--log-level=LOG_WARNING","--cache-size-mb=1000"]}},"access_mode":{"mode":5}},"volume_context":{"containername":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"4bbce626-894d-4896-bc38-718c4aaec726","csi.storage.k8s.io/pv/name":"pvc-5428d94a-923c-4d42-8496-6038f9ac8384","csi.storage.k8s.io/pvc/name":"pvc-azureblob-fuse","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","csi.storage.k8s.io/serviceAccount.tokens":"***stripped***","secretnamespace":"default","skuName":"Premium_LRS","storage.kubernetes.io/csiProvisionerIdentity":"1728056647464-33-blob.csi.azure.com"},"volume_id":"MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default#"}
I1004 18:04:18.667074    5991 nodeserver.go:139] NodePublishVolume: volume MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# mounting /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount at /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount with mountOptions: [bind]
I1004 18:04:18.667092    5991 mount_linux.go:218] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount)
I1004 18:04:18.671368    5991 mount_linux.go:218] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount)
I1004 18:04:18.672538    5991 nodeserver.go:155] NodePublishVolume: volume MC_rgblob_aks_swedencentral#fused6a211cbd37d4469a72#pvc-5428d94a-923c-4d42-8496-6038f9ac8384##default# mount /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/5d741b144cd1f0f31ab1abf1ad8b1e2b5a6614e14e68dbf6429182c5dc7623b6/globalmount at /var/lib/kubelet/pods/4bbce626-894d-4896-bc38-718c4aaec726/volumes/kubernetes.io~csi/pvc-5428d94a-923c-4d42-8496-6038f9ac8384/mount successfully
I1004 18:04:18.672553    5991 utils.go:111] GRPC response: {}
```

## azureblob-fuse.driver.parameter.protocol.fuse.nfs

```
kubectl describe sc azureblob-nfs-premium
Name:                  azureblob-nfs-premium
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           blob.csi.azure.com
Parameters:            protocol=nfs,skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

## azureblob-fuse.driver.parameter.nodeStageSecretRef

```
echo rg: $rg
storage="storage$RANDOM"
container="microservices"
noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)
az storage account create -g $noderg -n $storage -o none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $noderg -n $storage -o tsv)
key=$(az storage account keys list -g $noderg --account-name $storage --query "[0].value" -o tsv)
echo Storage account key: $key
az storage container create --account-name $storage -n $container --auth-mode login

kubectl delete secret azure-secret
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storage --from-literal=azurestorageaccountkey=$key

kubectl delete po mypod
kubectl delete pvc pvc-blobmodels
kubectl delete pv pv-blobmodels
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-blobmodels
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  csi:
    driver: blob.csi.azure.com
    readOnly: true
    volumeHandle: pv-blobmodels
    volumeAttributes:
      containerName: $container
    nodeStageSecretRef:
      name: azure-secret
      namespace: default
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-blobmodels
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 10Gi
  volumeName: pv-blobmodels
  storageClassName: ""
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: /mnt/blob
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-blobmodels
EOF
kubectl get po,pv,pvc
sleep 10
```

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: secret name that stores...
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/pv-blobfuse-auth.yaml
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/pv-blobfuse-csi.yaml

## azureblob-fuse.driver.parameter.skuName.GRS

```
kubectl delete po mypod
kubectl delete pvc pvc-azureblob-fuse
kubectl delete sc azureblob-fuse-my
cat << EOF | k create -f -
allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  labels:
    kubernetes.io/cluster-service: "true"
  name: azureblob-fuse-my
mountOptions:
- -o allow_other
- --file-cache-timeout-in-seconds=120
- --use-attr-cache=true
- --cancel-list-on-mount-seconds=10
- -o attr_timeout=120
- -o entry_timeout=120
- -o negative_timeout=120
- --log-level=LOG_WARNING
- --cache-size-mb=1000
parameters:
  skuName: Standard_GRS
provisioner: blob.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azureblob-fuse
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azureblob-fuse-my
  resources:
    requests:
      storage: 5Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/blob"
      name: volume
  volumes:
    - name: volume
      persistentVolumeClaim:
        claimName: pvc-azureblob-fuse
EOF
kubectl get po -w
# kubectl describe pv

az storage account list -g MC_rgcni_akseadsv5_swedencentral | grep -E 'id|"name"'
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fuse414dbe20ef224a7a9ae",
    "name": "fuse414dbe20ef224a7a9ae",
      "name": "Premium_LRS",
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fusec76e7488ea2047c9a2b",
    "name": "fusec76e7488ea2047c9a2b",
      "name": "Standard_GRS",
```

## azureblob-fuse.driver.parameter.skuName.LRS

```
kubectl describe sc azureblob-fuse-premium
Parameters:            skuName=Premium_LRS

az storage account list -g MC_rgcni_akseadsv5_swedencentral | grep -E 'id|"name"'
    "id": "/subscriptions/redacts-1111-1111-1111-111111111111/resourceGroups/MC_rg_aks_swedencentral/providers/Microsoft.Storage/storageAccounts/fuse414dbe20ef224a7a9ae",
    "name": "fuse414dbe20ef224a7a9ae",
      "name": "Premium_LRS",
```

## azureblob-fuse.driver.parameter.useDataPlaneAPI aka storage account firewall: 

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/driver-parameters.md: specify whether use data plane API for blob container create/delete, this could solve the SRP API throttling issue since data plane API has almost no limit, while it would fail when there is firewall or vnet setting on storage account i.e. make sure the storage account is not set to "Check Allow Access From (All Networks / Selected Networks)" "Selected Networks" i.e. set "Enabled from all networks" in the specified storage account
- https://learn.microsoft.com/en-us/answers/questions/1166011/getting-a-403-error-when-connecting-to-a-blob-cont: "Selected Networks" - It means the storage account is firewall enabled.
- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/pkg/blob/controllerserver.go: if len(secrets) == 0 && useDataPlaneAPI {... "failed to GetStorageAccesskey on account

## azureblob-fuse.error

### azureblob-fuse.error parsing volumeID(pv-blobmodels) return with error: error parsing volume id: "pv-blobmodels", should at least contain two #

```
# scenario involing a harmless error
# steps in azureblob-fuse.driver.parameter.nodeStageSecretRef

k logs -n kube-system csi-blob-node-bnrss -c blob | tail -n 50
I1008 18:13:40.594330    6512 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
I1008 18:13:40.594344    6512 utils.go:105] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":3}},"volume_context":{"containerName":"microservices"},"volume_id":"pv-blobmodels"}
I1008 18:13:40.594663    6512 blob.go:423] parsing volumeID(pv-blobmodels) return with error: error parsing volume id: "pv-blobmodels", should at least contain two #
I1008 18:13:40.594681    6512 blob.go:504] volumeID(pv-blobmodels) authEnv: []
I1008 18:13:40.594711    6512 nodeserver.go:386] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount
protocol
volumeId pv-blobmodels
mountflags []
mountOptions [--pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
serverAddress storage3116.blob.core.windows.net
I1008 18:13:40.594769    6512 nodeserver.go:166] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
I1008 18:13:40.595242    6512 nodeserver.go:175] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
I1008 18:13:41.840872    6512 mount_linux.go:282] Detected umount with safe 'not mounted' behavior
I1008 18:13:41.841046    6512 nodeserver.go:645] blobfuse mount at /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount success
I1008 18:13:41.841076    6512 nodeserver.go:444] volume(pv-blobmodels) mount on "/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount" succeeded
I1008 18:13:41.841088    6512 utils.go:111] GRPC response: {}

kubectl get po,pv,pvc
NAME        READY   STATUS    RESTARTS   AGE
pod/mypod   1/1     Running   0          17s
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pv-blobmodels   10Gi       ROX            Retain           Bound    default/pvc-blobmodels                  <unset>                          18s
NAME                                   STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-blobmodels   Bound    pv-blobmodels   10Gi       ROX                           <unset>                 17s
```

### azureblob-fuse.error code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [config error in azstorage [account name not provided]]

```
# scenario where $storage2 does not exist
# steps in azureblob-fuse.driver.parameter.nodeStageSecretRef
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storage2 --from-literal=azurestorageaccountkey=$key

# azurestorageaccountname:  0 bytes
kubectl describe secret
Name:         azure-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>
Type:  Opaque
Data
====
azurestorageaccountkey:   88 bytes
azurestorageaccountname:  0 bytes

# serverAddress .blob.core.windows.net, code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [config error in azstorage [account name not provided]]
k logs -n kube-system csi-blob-node-bnrss -c blob
I1008 18:04:48.444845    6512 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
I1008 18:04:48.444863    6512 utils.go:105] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":3}},"volume_context":{"containerName":"microservices"},"volume_id":"pv-blobmodels"}
I1008 18:04:48.445263    6512 blob.go:423] parsing volumeID(pv-blobmodels) return with error: error parsing volume id: "pv-blobmodels", should at least contain two #
I1008 18:04:48.445280    6512 blob.go:504] volumeID(pv-blobmodels) authEnv: []
I1008 18:04:48.445351    6512 nodeserver.go:386] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount
protocol
volumeId pv-blobmodels
mountflags []
mountOptions [--pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
serverAddress .blob.core.windows.net
I1008 18:04:48.445387    6512 nodeserver.go:166] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
I1008 18:04:48.445957    6512 nodeserver.go:175] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
E1008 18:04:49.015328    6512 nodeserver.go:178] GRPC call returned with an error:rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [config error in azstorage [account name not provided]]
E1008 18:04:49.015366    6512 nodeserver.go:412] rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [config error in azstorage [account name not provided]]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.

k get po,pvc,pv
NAME        READY   STATUS              RESTARTS   AGE
pod/mypod   0/1     ContainerCreating   0          78s
NAME                                   STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-blobmodels   Bound    pv-blobmodels   10Gi       ROX                           <unset>                 78s
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pv-blobmodels   10Gi       ROX            Retain           Bound    default/pvc-blobmodels                  <unset>                          78s
```

### azureblob-fuse.error code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [decode account key: illegal base64 data at input byte 8]

```
# scenario where the key is "incorrect"
# steps in azureblob-fuse.driver.parameter.nodeStageSecretRef
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storage --from-literal=azurestorageaccountkey="incorrect"

k logs -n kube-system csi-blob-node-bnrss -c blob | tail -n 50
I1008 18:42:57.300266    6512 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
I1008 18:42:57.300281    6512 utils.go:105] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":3}},"volume_context":{"containerName":"microservices"},"volume_id":"pv-blobmodels"}
I1008 18:42:57.300538    6512 blob.go:423] parsing volumeID(pv-blobmodels) return with error: error parsing volume id: "pv-blobmodels", should at least contain two #
I1008 18:42:57.300549    6512 blob.go:504] volumeID(pv-blobmodels) authEnv: []
I1008 18:42:57.300575    6512 nodeserver.go:386] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount
protocol
volumeId pv-blobmodels
mountflags []
mountOptions [--pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
serverAddress storage13696.blob.core.windows.net
I1008 18:42:57.300586    6512 nodeserver.go:166] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
I1008 18:42:57.300975    6512 nodeserver.go:175] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
E1008 18:42:57.891878    6512 nodeserver.go:178] GRPC call returned with an error:rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [decode account key: illegal base64 data at input byte 8]
E1008 18:42:57.891924    6512 nodeserver.go:412] rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [decode account key: illegal base64 data at input byte 8]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.
E1008 18:42:57.891995    6512 utils.go:109] GRPC error: rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [decode account key: illegal base64 data at input byte 8]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.

k describe po
  Type     Reason       Age                   From     Message
  ----     ------       ----                  ----     -------
  Warning  FailedMount  2m55s (x48 over 84m)  kubelet  MountVolume.MountDevice failed for volume "pv-blobmodels" : rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [decode account key: illegal base64 data at input byte 8]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.

k get po,pvc,pv
NAME        READY   STATUS              RESTARTS   AGE
pod/mypod   0/1     ContainerCreating   0          78s
NAME                                   STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-blobmodels   Bound    pv-blobmodels   10Gi       ROX                           <unset>                 78s
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pv-blobmodels   10Gi       ROX            Retain           Bound    default/pvc-blobmodels                  <unset>                          78s
```

### azureblob-fuse.error code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [failed to authenticate credentials for azstorage]

```
# scenario where the storage account key is regenerated after creating a secret
# steps in azureblob-fuse.driver.parameter.nodeStageSecretRef
az storage account keys renew -g $noderg -n $storage --key primary

k logs -n kube-system csi-blob-node-bnrss -c blob | tail -n 50

k describe po
  Warning  FailedMount  13s (x6 over 32s)  kubelet            MountVolume.MountDevice failed for volume "pv-blobmodels" : rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [failed to authenticate credentials for azstorage]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.

k logs -n kube-system csi-blob-node-bnrss -c blob | tail -n 50
I1008 18:55:56.065741    6512 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
I1008 18:55:56.065758    6512 utils.go:105] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":3}},"volume_context":{"containerName":"microservices"},"volume_id":"pv-blobmodels"}
I1008 18:55:56.066031    6512 blob.go:423] parsing volumeID(pv-blobmodels) return with error: error parsing volume id: "pv-blobmodels", should at least contain two #
I1008 18:55:56.066046    6512 blob.go:504] volumeID(pv-blobmodels) authEnv: []
I1008 18:55:56.066074    6512 nodeserver.go:386] target /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount
protocol
volumeId pv-blobmodels
mountflags []
mountOptions [--pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices]
args /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
serverAddress storage1216.blob.core.windows.net
I1008 18:55:56.066091    6512 nodeserver.go:166] start connecting to blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
I1008 18:55:56.066482    6512 nodeserver.go:175] begin to mount with blobfuse proxy, protocol: , args: /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/dd3330e4623d772350df7f53cdeb02c81107e08a91a860d86adf2d4985ed1143/globalmount --pre-mount-validate=true --use-https=true --cancel-list-on-mount-seconds=10 --empty-dir-check=false --tmp-path=/mnt/pv-blobmodels --container-name=microservices
E1008 18:55:56.697781    6512 nodeserver.go:178] GRPC call returned with an error:rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [failed to authenticate credentials for azstorage]
E1008 18:55:56.697837    6512 nodeserver.go:412] rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [failed to authenticate credentials for azstorage]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.
E1008 18:55:56.697907    6512 utils.go:109] GRPC error: rpc error: code = Internal desc = Mount failed with error: rpc error: code = Unknown desc = exit status 1 Error: failed to initialize new pipeline [failed to authenticate credentials for azstorage]
, output:
Please refer to http://aka.ms/blobmounterror for possible causes and solutions for mount errors.

k get po,pvc,pv
NAME        READY   STATUS              RESTARTS   AGE
pod/mypod   0/1     ContainerCreating   0          78s
NAME                                   STATUS   VOLUME          CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/pvc-blobmodels   Bound    pv-blobmodels   10Gi       ROX                           <unset>                 78s
NAME                             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pv-blobmodels   10Gi       ROX            Retain           Bound    default/pvc-blobmodels                  <unset>                          78s
```

## azureblob-fuse.provision.dynamic

```
# azureblob-fuse.driver.parameter.protocol.fuse
```
- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-blobfuse%2Csecret#dynamically-provision-a-volume

## azureblob-fuse.provision.static

```
# azureblob-fuse.driver.parameter.nodeStageSecretRef
```

- https://learn.microsoft.com/en-us/azure/aks/azure-csi-blob-storage-provision?tabs=mount-blobfuse%2Csecret#statically-provision-a-volume
