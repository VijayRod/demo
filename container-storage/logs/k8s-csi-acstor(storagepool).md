##  k8s-csi-acstor

```
# Begin with k8s-csi-acstor.storagepool.type.ephemeralDisk.TempSSD
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/install-container-storage-aks
- https://learn.microsoft.com/en-us/azure/storage/container-storage/container-storage-introduction
- https://github.com/Azure-Samples/azure-container-storage-samples
- https://azure.microsoft.com/en-us/updates/public-preview-azure-container-storage/
- https://azure.microsoft.com/en-us/blog/transforming-containerized-applications-with-azure-container-storage-now-in-preview/
- https://learn.microsoft.com/en-us/azure/storage/container-storage/troubleshoot-container-storage
  
### earlier
```
rg=rgcsi
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

az aks nodepool add -g $rg --cluster-name aks -n npacstor -s Standard_D4s_v5 --node-count 3 --mode user ## Required minimum of three nodes, four virtual CPUs (vCPUs). Or -s Standard_D8s_v5 --node-osdisk-type Ephemeral

cd /tmp
rm acstor-install.sh
wget https://raw.githubusercontent.com/Azure-Samples/azure-container-storage-samples/main/acstor-install.sh
chmod +x acstor-install.sh 
bash ./acstor-install.sh -g $rg -c aks -n npacstor
```

```
kubectl get no -l acstor.azure.com/io-engine=acstor
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/install-container-storage-aks?tabs=portal
- https://github.com/Azure-Samples/azure-container-storage-samples/blob/main/acstor-install.sh

##  k8s-csi-acstor.storagepool.type.azureDisk

```
az extension add --upgrade --name k8s-extension
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksdisk -s Standard_D4s_v3 --enable-azure-container-storage azureDisk
az aks get-credentials -g $rg -n aksdisk --overwrite-existing
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-managed-disks

##  k8s-csi-acstor.storagepool.type.elasticSan

```
az extension add --upgrade --name k8s-extension
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n akssan -s Standard_D4s_v3 --enable-azure-container-storage elasticSan
az aks get-credentials -g $rg -n akssan --overwrite-existing
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-elastic-san

##  k8s-csi-acstor.storagepool.type.ephemeralDisk.NVMe

```
az extension add --upgrade --name k8s-extension
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksnvme -s standard_l8s_v3 --enable-azure-container-storage ephemeralDisk --storage-pool-option NVMe # Alternatively, you can use the same command with Standard_D4s_v3 if you're running tests without NVMe
az aks get-credentials -g $rg -n akseph --overwrite-existing
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk

##  k8s-csi-acstor.storagepool.type.ephemeralDisk.NVMe.replication

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-nvme-replication
- tbd https://learn.microsoft.com/en-us/azure/virtual-machines/nvme-overview
- tbd https://learn.microsoft.com/en-us/azure/virtual-machines/enable-nvme-faqs

##  k8s-csi-acstor.storagepool.type.ephemeralDisk.TempSSD

```
az extension add --upgrade --name k8s-extension
rg=rg
az group create -n $rg -l $loc
az aks create -g $rg -n aksssd -s Standard_D4s_v3 --enable-azure-container-storage ephemeralDisk --storage-pool-option Temp
az aks get-credentials -g $rg -n aksssd --overwrite-existing

az aks show -g $rg -n aksssd --query agentPoolProfiles[0].nodeLabels
{
  "acstor.azure.com/io-engine": "acstor"
}

k describe no
Name:               aks-nodepool1-31095945-vmss000002
Labels:             acstor.azure.com/io-engine=acstor
                    topology.containerstorage.csi.azure.com/region=swedencentral
                    topology.containerstorage.csi.azure.com/zone=

kubectl get no -l acstor.azure.com/io-engine=acstor
                    
k get crd | grep stor
billingstorages.clusterconfig.azure.com                 2024-10-15T18:46:25Z
capacityprovisionerconfigs.containerstorage.azure.com   2024-10-15T18:47:25Z
diskpools.containerstorage.azure.com                    2024-10-15T18:47:25Z
etcdrecoveries.containerstorage.azure.com               2024-10-15T18:47:25Z
storagepools.containerstorage.azure.com                 2024-10-15T18:47:25Z

k api-resources | grep stor
billingstorages                                         clusterconfig.azure.com/v1             true         BillingStorage
capacityprovisionerconfigs                              containerstorage.azure.com/v1          true         CapacityProvisionerConfig
diskpools                           dp                  containerstorage.azure.com/v1          true         DiskPool
etcdrecoveries                      er                  containerstorage.azure.com/v1          true         EtcdRecovery
storagepools                        sp                  containerstorage.azure.com/v1          true         StoragePool

k get csidrivers
NAME                             ATTACHREQUIRED   PODINFOONMOUNT   STORAGECAPACITY   TOKENREQUESTS                REQUIRESREPUBLISH   MODES                  AGE
containerstorage.csi.azure.com   true             false            false             <unset>                      false               Persistent             3h4m
disk.csi.azure.com               true             false            false             <unset>                      false               Persistent             3h14m
file.csi.azure.com               false            true             false             api://AzureADTokenExchange   false               Persistent,Ephemeral   3h14m

k get sc
NAME                        PROVISIONER                      RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
acstor-azuredisk-internal   disk.csi.azure.com               Retain          WaitForFirstConsumer   true       3h4m
acstor-ephemeraldisk-temp   containerstorage.csi.azure.com   Delete          WaitForFirstConsumer   true       3h
azurefile                   file.csi.azure.com               Delete          Immediate              true       3h14m
azurefile-csi               file.csi.azure.com               Delete          Immediate              true       3h14m
azurefile-csi-premium       file.csi.azure.com               Delete          Immediate              true       3h14m
azurefile-premium           file.csi.azure.com               Delete          Immediate              true       3h14m
default (default)           disk.csi.azure.com               Delete          WaitForFirstConsumer   true       3h14m
managed                     disk.csi.azure.com               Delete          WaitForFirstConsumer   true       3h14m
managed-csi                 disk.csi.azure.com               Delete          WaitForFirstConsumer   true       3h14m
managed-csi-premium         disk.csi.azure.com               Delete          WaitForFirstConsumer   true       3h14m
managed-premium             disk.csi.azure.com               Delete          WaitForFirstConsumer   true       3h14m

k describe sc acstor-azuredisk-internal
Name:                  acstor-azuredisk-internal
IsDefaultClass:        No
Annotations:           meta.helm.sh/release-name=azurecontainerstorage,meta.helm.sh/release-namespace=acstor
Provisioner:           disk.csi.azure.com
Parameters:            skuName=Premium_LRS
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Retain
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>

k describe sc acstor-ephemeraldisk-temp
Name:                  acstor-ephemeraldisk-temp
IsDefaultClass:        No
Annotations:           <none>
Provisioner:           containerstorage.csi.azure.com
Parameters:            acstor.azure.com/storagepool=ephemeraldisk-temp,hyperconverged=true,ioTimeout=60,proto=nvmf,repl=1
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-temp-ssd

## k8s-csi-acstor.misc.pods

```
k get po -A
NAMESPACE                       NAME                                                            READY   STATUS    RESTARTS       AGE
acstor                          azurecontainerstorage-agent-core-65578c78c8-8vj2r               3/3     Running   1 (134m ago)   136m
acstor                          azurecontainerstorage-agent-core-65578c78c8-tvzln               3/3     Running   1 (134m ago)   136m
acstor                          azurecontainerstorage-api-rest-c49cb88f8-lqvxl                  1/1     Running   0              136m
acstor                          azurecontainerstorage-api-rest-c49cb88f8-xlf69                  1/1     Running   0              136m
acstor                          azurecontainerstorage-arc-logs-4g9kn                            3/3     Running   2 (129m ago)   136m
acstor                          azurecontainerstorage-arc-logs-cbsjm                            3/3     Running   1 (132m ago)   136m
acstor                          azurecontainerstorage-arc-logs-jb2pb                            3/3     Running   1 (132m ago)   136m
acstor                          azurecontainerstorage-arc-metrics-5d56846cd-ttswz               3/3     Running   0              136m
acstor                          azurecontainerstorage-capacity-provisioner-5dc7c846f5-846fc     1/1     Running   0              136m
acstor                          azurecontainerstorage-capacity-provisioner-5dc7c846f5-ct9rj     1/1     Running   0              136m
acstor                          azurecontainerstorage-cert-manager-6c4dc6b86d-tltm6             1/1     Running   0              136m
acstor                          azurecontainerstorage-cert-manager-cainjector-95474c97b-czqln   1/1     Running   0              136m
acstor                          azurecontainerstorage-cert-manager-webhook-5bf9fbfb7d-gg9nn     1/1     Running   0              136m
acstor                          azurecontainerstorage-csi-controller-76999c75cd-5vgmq           5/5     Running   5 (134m ago)   136m
acstor                          azurecontainerstorage-csi-controller-76999c75cd-kxpvv           5/5     Running   2 (134m ago)   136m
acstor                          azurecontainerstorage-csi-node-7mtjh                            2/2     Running   0              136m
acstor                          azurecontainerstorage-csi-node-kspbh                            2/2     Running   0              136m
acstor                          azurecontainerstorage-csi-node-s5nw4                            2/2     Running   0              136m
acstor                          azurecontainerstorage-dmesg-logger-9zbhm                        1/1     Running   0              136m
acstor                          azurecontainerstorage-dmesg-logger-cmphl                        1/1     Running   0              136m
acstor                          azurecontainerstorage-dmesg-logger-zkxkv                        1/1     Running   0              136m
acstor                          azurecontainerstorage-etcd-operator-5b876d8fbf-nltzb            1/1     Running   0              136m
acstor                          azurecontainerstorage-io-engine-gkg88                           1/1     Running   0              136m
acstor                          azurecontainerstorage-io-engine-m6p5k                           1/1     Running   0              136m
acstor                          azurecontainerstorage-io-engine-rzdvh                           1/1     Running   0              136m
acstor                          azurecontainerstorage-kube-operator-746ffb4f4-5bvmb             1/1     Running   0              136m
acstor                          azurecontainerstorage-metrics-exporter-9cft5                    1/1     Running   0              136m
acstor                          azurecontainerstorage-metrics-exporter-v6rpk                    1/1     Running   0              136m
acstor                          azurecontainerstorage-metrics-exporter-z7ncn                    1/1     Running   0              136m
acstor                          azurecontainerstorage-ndm-7zqxk                                 1/1     Running   0              136m
acstor                          azurecontainerstorage-ndm-fvmx9                                 1/1     Running   0              136m
acstor                          azurecontainerstorage-ndm-kjnbv                                 1/1     Running   0              136m
acstor                          azurecontainerstorage-ndm-operator-85c9bcd4f-ln9z9              1/1     Running   0              136m
acstor                          azurecontainerstorage-operator-diskpool-59546b4c7-d2gp7         1/1     Running   0              136m
acstor                          azurecontainerstorage-operator-diskpool-59546b4c7-pggch         1/1     Running   0              136m
acstor                          azurecontainerstorage-prereq-b4dj5                              1/1     Running   0              136m
acstor                          azurecontainerstorage-prereq-dv8w7                              1/1     Running   0              136m
acstor                          azurecontainerstorage-prereq-m7dp9                              1/1     Running   0              136m
acstor                          diskpool-worker-local-9j2tj                                     1/1     Running   0              132m
acstor                          diskpool-worker-local-wxcn7                                     1/1     Running   0              132m
acstor                          diskpool-worker-local-zq5qq                                     1/1     Running   0              132m
acstor                          etcd-azurecontainerstorage-backup-sidecar-5bb65b59f9-f6p4m      1/1     Running   0              136m
acstor                          etcd-azurecontainerstorage-dpl2v9mqqh                           1/1     Running   0              135m
acstor                          etcd-azurecontainerstorage-gmjjwdsx8d                           1/1     Running   0              133m
acstor                          etcd-azurecontainerstorage-rkdzgqjqgj                           1/1     Running   0              134m
acstor                          prometheus-azurecontainerstorage-prometheus-0                   2/2     Running   0              135m
azure-extensions-usage-system   billing-operator-7875f7fb8f-w4qvb                               5/5     Running   0              139m
kube-system                     extension-agent-7bc85fbfc5-lmxvs                                2/2     Running   0              144m
kube-system                     extension-operator-f5bdcf9d7-cnpbs                              2/2     Running   0              144m

k get all -n acstor --show-labels
NAME                                                                 READY   STATUS    RESTARTS       AGE    LABELS
pod/azurecontainerstorage-agent-core-569c4bc4c4-74qhj                3/3     Running   1 (3h4m ago)   3h6m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=agent-core,openebs.io/logging=true,pod-template-hash=569c4bc4c4
pod/azurecontainerstorage-agent-core-569c4bc4c4-95gg9                3/3     Running   1 (3h4m ago)   3h6m   acstor.azure.com/leader=true,app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=agent-core,openebs.io/logging=true,pod-template-hash=569c4bc4c4
pod/azurecontainerstorage-api-rest-5b4988bc76-cqt4z                  1/1     Running   0              3h6m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=api-rest,openebs.io/logging=true,pod-template-hash=5b4988bc76
pod/azurecontainerstorage-api-rest-5b4988bc76-p5h2t                  1/1     Running   0              3h6m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=api-rest,openebs.io/logging=true,pod-template-hash=5b4988bc76
pod/azurecontainerstorage-arc-logs-b6h2g                             3/3     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-logs,controller-revision-hash=58c4c94cf8,pod-template-generation=1
pod/azurecontainerstorage-arc-logs-fffgg                             3/3     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-logs,controller-revision-hash=58c4c94cf8,pod-template-generation=1
pod/azurecontainerstorage-arc-logs-nj8x4                             3/3     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-logs,controller-revision-hash=58c4c94cf8,pod-template-generation=1
pod/azurecontainerstorage-arc-metrics-559759755c-bgr9m               3/3     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-metrics,pod-template-hash=559759755c
pod/azurecontainerstorage-capacity-provisioner-dfd5b9f9-m42gn        1/1     Running   0              3h6m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=capacity-provisioner,pod-template-hash=dfd5b9f9
pod/azurecontainerstorage-capacity-provisioner-dfd5b9f9-r4zd8        1/1     Running   0              3h6m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=capacity-provisioner,pod-template-hash=dfd5b9f9
pod/azurecontainerstorage-cert-manager-cainjector-64dd6776c5-sgj5z   1/1     Running   0              3h6m   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cainjector,app.kubernetes.io/version=v1.12.10,app=cainjector,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=64dd6776c5
pod/azurecontainerstorage-cert-manager-fbb994f48-gd8h8               1/1     Running   0              3h6m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=fbb994f48
pod/azurecontainerstorage-cert-manager-webhook-f4b66d8b4-6w97d       1/1     Running   0              3h6m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=f4b66d8b4
pod/azurecontainerstorage-csi-controller-6bdb6d5b48-cr6ns            5/5     Running   2 (3h4m ago)   3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-controller,openebs.io/logging=true,pod-template-hash=6bdb6d5b48
pod/azurecontainerstorage-csi-controller-6bdb6d5b48-mt8wt            5/5     Running   4 (3h4m ago)   3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-controller,openebs.io/logging=true,pod-template-hash=6bdb6d5b48
pod/azurecontainerstorage-csi-node-8l7zs                             2/2     Running   0              3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-node,controller-revision-hash=b4fd54969,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-csi-node-bjbml                             2/2     Running   0              3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-node,controller-revision-hash=b4fd54969,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-csi-node-ggb5j                             2/2     Running   0              3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-node,controller-revision-hash=b4fd54969,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-dmesg-logger-65rkn                         1/1     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=dmesg-logger,controller-revision-hash=855c4f6c6f,pod-template-generation=1
pod/azurecontainerstorage-dmesg-logger-9b7ff                         1/1     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=dmesg-logger,controller-revision-hash=855c4f6c6f,pod-template-generation=1
pod/azurecontainerstorage-dmesg-logger-zv4mp                         1/1     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=dmesg-logger,controller-revision-hash=855c4f6c6f,pod-template-generation=1
pod/azurecontainerstorage-etcd-operator-855fc4cc96-hx75q             1/1     Running   0              3h6m   app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.5.1,heritage=Helm,kubernetes.azure.com/mdsd-tag=customer.etcdoperator,overlay-app=etcd-operator,pod-template-hash=855fc4cc96,release=azurecontainerstorage
pod/azurecontainerstorage-etcd-operator-855fc4cc96-rvlrr             1/1     Running   0              3h6m   app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.5.1,heritage=Helm,kubernetes.azure.com/mdsd-tag=customer.etcdoperator,overlay-app=etcd-operator,pod-template-hash=855fc4cc96,release=azurecontainerstorage
pod/azurecontainerstorage-io-engine-8rwdp                            1/1     Running   0              3h6m   app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=io-engine,controller-revision-hash=7bd4f57c5,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-io-engine-f4rpb                            1/1     Running   0              3h6m   app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=io-engine,controller-revision-hash=7bd4f57c5,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-io-engine-jtx44                            1/1     Running   0              3h6m   app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=io-engine,controller-revision-hash=7bd4f57c5,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-kube-operator-87968f768-z2q6t              1/1     Running   0              3h6m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,pod-template-hash=87968f768,release=azurecontainerstorage
pod/azurecontainerstorage-metrics-exporter-5xxjj                     1/1     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=metrics-exporter,controller-revision-hash=7685c84df8,pod-template-generation=1
pod/azurecontainerstorage-metrics-exporter-vxjpf                     1/1     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=metrics-exporter,controller-revision-hash=7685c84df8,pod-template-generation=1
pod/azurecontainerstorage-metrics-exporter-wbxcn                     1/1     Running   0              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=metrics-exporter,controller-revision-hash=7685c84df8,pod-template-generation=1
pod/azurecontainerstorage-ndm-6tz2k                                  1/1     Running   0              3h6m   app=ndm,chart=openebs-ndm-1.2.0,component=ndm,controller-revision-hash=7f8967857,heritage=Helm,name=openebs-ndm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,pod-template-generation=1,release=azurecontainerstorage
pod/azurecontainerstorage-ndm-fn552                                  1/1     Running   0              3h6m   app=ndm,chart=openebs-ndm-1.2.0,component=ndm,controller-revision-hash=7f8967857,heritage=Helm,name=openebs-ndm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,pod-template-generation=1,release=azurecontainerstorage
pod/azurecontainerstorage-ndm-operator-6b466dd7c4-skq75              1/1     Running   0              3h6m   app=ndm-operator-operator,chart=openebs-ndm-1.2.0,component=ndm-operator-operator,heritage=Helm,name=openebs-ndm-operator,openebs.io/component-name=ndm-operator-operator,openebs.io/version=2.2.0,pod-template-hash=6b466dd7c4,release=azurecontainerstorage
pod/azurecontainerstorage-ndm-qfkw8                                  1/1     Running   0              3h6m   app=ndm,chart=openebs-ndm-1.2.0,component=ndm,controller-revision-hash=7f8967857,heritage=Helm,name=openebs-ndm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,pod-template-generation=1,release=azurecontainerstorage
pod/azurecontainerstorage-operator-diskpool-58f7fcb6bf-5vn6g         1/1     Running   0              3h6m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=operator-diskpool,openebs.io/logging=true,pod-template-hash=58f7fcb6bf
pod/azurecontainerstorage-operator-diskpool-58f7fcb6bf-plgpt         1/1     Running   0              3h6m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=operator-diskpool,openebs.io/logging=true,pod-template-hash=58f7fcb6bf
pod/azurecontainerstorage-prereq-bq5d7                               1/1     Running   0              3h6m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=azurecontainerstorage-prereq,controller-revision-hash=9cc487499,pod-template-generation=1
pod/azurecontainerstorage-prereq-v7862                               1/1     Running   0              3h6m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=azurecontainerstorage-prereq,controller-revision-hash=9cc487499,pod-template-generation=1
pod/azurecontainerstorage-prereq-x4k47                               1/1     Running   0              3h6m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=azurecontainerstorage-prereq,controller-revision-hash=9cc487499,pod-template-generation=1
pod/diskpool-worker-local-kz9cf                                      1/1     Running   0              3h2m   acstor.azure.com/diskpool-type=ephemeralDisk,acstor.azure.com/diskpool=ephemeraldisk-temp-diskpool-rxalr,acstor.azure.com/managedby=capacity-provisioner,acstor.azure.com/mount-option=nodiscard,acstor.azure.com/skip-validation-check=true,acstor.azure.com/storagepool=ephemeraldisk-temp,app.kubernetes.io/component=storage-pool,app.kubernetes.io/instance=azurecontainerstorage-diskpool-worker,app.kubernetes.io/managed-by=capacity-provisioner,app.kubernetes.io/name=diskpool-worker,app.kubernetes.io/part-of=acstor
pod/diskpool-worker-local-ss6mj                                      1/1     Running   0              3h2m   acstor.azure.com/diskpool-type=ephemeralDisk,acstor.azure.com/diskpool=ephemeraldisk-temp-diskpool-jfbqz,acstor.azure.com/managedby=capacity-provisioner,acstor.azure.com/mount-option=nodiscard,acstor.azure.com/skip-validation-check=true,acstor.azure.com/storagepool=ephemeraldisk-temp,app.kubernetes.io/component=storage-pool,app.kubernetes.io/instance=azurecontainerstorage-diskpool-worker,app.kubernetes.io/managed-by=capacity-provisioner,app.kubernetes.io/name=diskpool-worker,app.kubernetes.io/part-of=acstor
pod/diskpool-worker-local-td2d2                                      1/1     Running   0              3h2m   acstor.azure.com/diskpool-type=ephemeralDisk,acstor.azure.com/diskpool=ephemeraldisk-temp-diskpool-xntoi,acstor.azure.com/managedby=capacity-provisioner,acstor.azure.com/mount-option=nodiscard,acstor.azure.com/skip-validation-check=true,acstor.azure.com/storagepool=ephemeraldisk-temp,app.kubernetes.io/component=storage-pool,app.kubernetes.io/instance=azurecontainerstorage-diskpool-worker,app.kubernetes.io/managed-by=capacity-provisioner,app.kubernetes.io/name=diskpool-worker,app.kubernetes.io/part-of=acstor
pod/etcd-azurecontainerstorage-backup-sidecar-5c85c98868-cb42z       1/1     Running   0              3h6m   app=etcd_backup_tool,etcd_cluster=etcd-azurecontainerstorage,kubernetes.azure.com/mdsd-tag=customer.etcdbackup,pod-template-hash=5c85c98868
pod/etcd-azurecontainerstorage-q8xr4crjh8                            1/1     Running   0              3h4m   app=etcd,etcd_cluster=etcd-azurecontainerstorage,etcd_member_id=16187c1f39d87c15,etcd_node=etcd-azurecontainerstorage-q8xr4crjh8
pod/etcd-azurecontainerstorage-qxxmgp8n9z                            1/1     Running   0              3h4m   app=etcd,etcd_cluster=etcd-azurecontainerstorage,etcd_member_id=76312252c11a3dd7,etcd_node=etcd-azurecontainerstorage-qxxmgp8n9z
pod/etcd-azurecontainerstorage-vn4gdjkdj6                            1/1     Running   0              3h5m   app=etcd,etcd_cluster=etcd-azurecontainerstorage,etcd_member_id=c9cdb6292cf3dbdd,etcd_node=etcd-azurecontainerstorage-vn4gdjkdj6
pod/prometheus-azurecontainerstorage-prometheus-0                    2/2     Running   0              3h5m   app.kubernetes.io/instance=azurecontainerstorage-prometheus,app.kubernetes.io/managed-by=prometheus-operator,app.kubernetes.io/name=prometheus,app.kubernetes.io/version=2.39.0,apps.kubernetes.io/pod-index=0,controller-revision-hash=prometheus-azurecontainerstorage-prometheus-866964cc67,operator.prometheus.io/name=azurecontainerstorage-prometheus,operator.prometheus.io/shard=0,prometheus=azurecontainerstorage-prometheus,statefulset.kubernetes.io/pod-name=prometheus-azurecontainerstorage-prometheus-0

NAME                                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)
            AGE    LABELS
service/azurecontainerstorage-agent-core               ClusterIP   10.0.198.229   <none>        50051/TCP
            3h6m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=agent-core
service/azurecontainerstorage-agent-elector            ClusterIP   None           <none>        9443/TCP
            3h6m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=agent-core
service/azurecontainerstorage-api-rest                 NodePort    10.0.58.178    <none>        8080:30010/TCP,8081:30011/TCP   3h6m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=api-rest
service/azurecontainerstorage-arc-prom-mdm-converter   ClusterIP   10.0.138.163   <none>        80/TCP
            3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-metrics
service/azurecontainerstorage-cert-manager             ClusterIP   10.0.42.252    <none>        9402/TCP
            3h6m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10
service/azurecontainerstorage-cert-manager-webhook     ClusterIP   10.0.223.213   <none>        443/TCP
            3h6m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10
service/azurecontainerstorage-kube-operator            ClusterIP   10.0.70.1      <none>        443/TCP
            3h6m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,release=azurecontainerstorage
service/capacity-provisioner-service                   ClusterIP   10.0.117.63    <none>        29604/TCP
            3h6m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=capacity-provisioner
service/etcd-azurecontainerstorage                     ClusterIP   None           <none>        2379/TCP,2380/TCP               3h6m   app=etcd,etcd_cluster=etcd-azurecontainerstorage
service/etcd-azurecontainerstorage-backup-sidecar      ClusterIP   10.0.188.141   <none>        19999/TCP,29999/TCP,39999/TCP   3h6m   app=etcd,etcd_cluster=etcd-azurecontainerstorage
service/etcd-azurecontainerstorage-client              ClusterIP   10.0.111.162   <none>        2379/TCP
            3h6m   app=etcd,etcd_cluster=etcd-azurecontainerstorage
service/etcdr-azurecontainerstorage                    ClusterIP   None           <none>        2379/TCP,2380/TCP               3h6m   app=etcd,etcd_cluster=etcdr-azurecontainerstorage
service/etcdr-azurecontainerstorage-client             ClusterIP   10.0.92.182    <none>        2379/TCP
            3h6m   app=etcd,etcd_cluster=etcdr-azurecontainerstorage
service/geneva-services                                ClusterIP   10.0.213.127   <none>        8130/TCP
            3h6m   app.kubernetes.io/managed-by=Helm,app=geneva-services
service/prometheus-operated                            ClusterIP   None           <none>        9090/TCP
            3h5m   operated-prometheus=true
service/webhook-service                                ClusterIP   10.0.28.118    <none>        443/TCP
            3h6m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=capacity-provisioner

NAME                                                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                                       AGE    LABELS
daemonset.apps/azurecontainerstorage-arc-logs           3         3         3       3            3           <none>                                                                              3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-logs
daemonset.apps/azurecontainerstorage-csi-node           3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   3h6m   acstor.azure.com/io-engine=acstor,app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-node
daemonset.apps/azurecontainerstorage-dmesg-logger       3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=dmesg-logger
daemonset.apps/azurecontainerstorage-io-engine          3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   3h6m   acstor.azure.com/io-engine=acstor,app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=io-engine
daemonset.apps/azurecontainerstorage-metrics-exporter   3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=metrics-exporter
daemonset.apps/azurecontainerstorage-ndm                3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   3h6m   app.kubernetes.io/managed-by=Helm,app=ndm,chart=openebs-ndm-1.2.0,component=ndm,heritage=Helm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,release=azurecontainerstorage
daemonset.apps/azurecontainerstorage-prereq             3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   3h6m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=azurecontainerstorage-prereq

NAME                                                            READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
deployment.apps/azurecontainerstorage-agent-core                2/2     2            2           3h6m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=agent-core
deployment.apps/azurecontainerstorage-api-rest                  2/2     2            2           3h6m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=api-rest
deployment.apps/azurecontainerstorage-arc-metrics               1/1     1            1           3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-metrics
deployment.apps/azurecontainerstorage-capacity-provisioner      2/2     2            2           3h6m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=capacity-provisioner
deployment.apps/azurecontainerstorage-cert-manager              1/1     1            1           3h6m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10
deployment.apps/azurecontainerstorage-cert-manager-cainjector   1/1     1            1           3h6m   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cainjector,app.kubernetes.io/version=v1.12.10,app=cainjector,helm.sh/chart=cert-manager-v1.12.10
deployment.apps/azurecontainerstorage-cert-manager-webhook      1/1     1            1           3h6m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10
deployment.apps/azurecontainerstorage-csi-controller            2/2     2            2           3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-controller
deployment.apps/azurecontainerstorage-etcd-operator             2/2     2            2           3h6m   app.kubernetes.io/managed-by=Helm,app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.0.0-12bcfed9d39583debf8e4ec104cf990507464459,heritage=Helm,release=azurecontainerstorage
deployment.apps/azurecontainerstorage-kube-operator             1/1     1            1           3h6m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,release=azurecontainerstorage
deployment.apps/azurecontainerstorage-ndm-operator              1/1     1            1           3h6m   app.kubernetes.io/managed-by=Helm,app=ndm-operator-operator,chart=openebs-ndm-1.2.0,component=ndm-operator-operator,heritage=Helm,openebs.io/component-name=ndm-operator-operator,openebs.io/version=2.2.0,release=azurecontainerstorage
deployment.apps/azurecontainerstorage-operator-diskpool         2/2     2            2           3h6m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=operator-diskpool
deployment.apps/etcd-azurecontainerstorage-backup-sidecar       1/1     1            1           3h6m   app=etcd,etcd_cluster=etcd-azurecontainerstorage

NAME                                                                       DESIRED   CURRENT   READY   AGE    LABELS
replicaset.apps/azurecontainerstorage-agent-core-569c4bc4c4                2         2         2       3h6m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=agent-core,openebs.io/logging=true,pod-template-hash=569c4bc4c4
replicaset.apps/azurecontainerstorage-api-rest-5b4988bc76                  2         2         2       3h6m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=api-rest,openebs.io/logging=true,pod-template-hash=5b4988bc76
replicaset.apps/azurecontainerstorage-arc-metrics-559759755c               1         1         1       3h6m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=arc-metrics,pod-template-hash=559759755c
replicaset.apps/azurecontainerstorage-capacity-provisioner-dfd5b9f9        2         2         2       3h6m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=capacity-provisioner,pod-template-hash=dfd5b9f9
replicaset.apps/azurecontainerstorage-cert-manager-cainjector-64dd6776c5   1         1         1       3h6m   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cainjector,app.kubernetes.io/version=v1.12.10,app=cainjector,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=64dd6776c5
replicaset.apps/azurecontainerstorage-cert-manager-fbb994f48               1         1         1       3h6m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=fbb994f48
replicaset.apps/azurecontainerstorage-cert-manager-webhook-f4b66d8b4       1         1         1       3h6m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=f4b66d8b4
replicaset.apps/azurecontainerstorage-csi-controller-6bdb6d5b48            2         2         2       3h6m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=csi-controller,openebs.io/logging=true,pod-template-hash=6bdb6d5b48
replicaset.apps/azurecontainerstorage-etcd-operator-855fc4cc96             2         2         2       3h6m   app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.5.1,heritage=Helm,kubernetes.azure.com/mdsd-tag=customer.etcdoperator,overlay-app=etcd-operator,pod-template-hash=855fc4cc96,release=azurecontainerstorage
replicaset.apps/azurecontainerstorage-kube-operator-87968f768              1         1         1       3h6m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,pod-template-hash=87968f768,release=azurecontainerstorage
replicaset.apps/azurecontainerstorage-ndm-operator-6b466dd7c4              1         1         1       3h6m   app=ndm-operator-operator,chart=openebs-ndm-1.2.0,component=ndm-operator-operator,heritage=Helm,name=openebs-ndm-operator,openebs.io/component-name=ndm-operator-operator,openebs.io/version=2.2.0,pod-template-hash=6b466dd7c4,release=azurecontainerstorage
replicaset.apps/azurecontainerstorage-operator-diskpool-58f7fcb6bf         2         2         2       3h6m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=operator-diskpool,openebs.io/logging=true,pod-template-hash=58f7fcb6bf
replicaset.apps/etcd-azurecontainerstorage-backup-sidecar-5c85c98868       1         1         1       3h6m   app=etcd_backup_tool,etcd_cluster=etcd-azurecontainerstorage,kubernetes.azure.com/mdsd-tag=customer.etcdbackup,pod-template-hash=5c85c98868

NAME                                                           READY   AGE    LABELS
statefulset.apps/prometheus-azurecontainerstorage-prometheus   1/1     3h5m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-prometheus,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prometheus,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.2.0,app=prometheus,operator.prometheus.io/name=azurecontainerstorage-prometheus,operator.prometheus.io/shard=0,prometheus=acstor
```

## k8s-csi-acstor.misc.pods.extension

```
# Refer to k8s-aks-extension(arc)
# These pods are also created when you use the command az aks create --enable-azure-container-storage

k get po -n kube-system --show-labels | grep ext
extension-agent-7bc85fbfc5-lmxvs      2/2     Running   0          135m   app.kubernetes.io/component=extension-agent,app.kubernetes.io/name=extension-manager,control-plane=extension-agent,kubernetes.azure.com/managedby=aks,pod-template-hash=7bc85fbfc5
extension-operator-f5bdcf9d7-cnpbs    2/2     Running   0          135m   app.kubernetes.io/component=extension-operator,app.kubernetes.io/name=extension-manager,control-plane=extension-operator,kubernetes.azure.com/managedby=aks,pod-template-hash=f5bdcf9d7

k describe po -n kube-system extension-operator-f5bdcf9d7-cnpbs | grep Image:
    Image:          mcr.microsoft.com/azurearck8s/aks/stable/extensionoperator:1.20.1
    Image:          mcr.microsoft.com/azurearck8s/aks/stable/fluent-bit-collector:1.20.1
```

```
k get all -n azure-extensions-usage-system --show-labels
NAME                                    READY   STATUS    RESTARTS   AGE    LABELS
pod/billing-operator-7875f7fb8f-w4qvb   5/5     Running   0          138m   app.kubernetes.io/component=billing-operator,app.kubernetes.io/name=extensionsusage,pod-template-hash=7875f7fb8f

NAME                               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE    LABELS
service/billing-operator-webhook   ClusterIP   10.0.117.45   <none>        443/TCP   138m   app.kubernetes.io/component=billing-operator,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=extensionsusage

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
deployment.apps/billing-operator   1/1     1            1           138m   app.kubernetes.io/component=billing-operator,app.kubernetes.io/instance=systemextension.microsoft.extensionsusage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=microsoft.extensionsusage,app.kubernetes.io/part-of=extensionsusage,app.kubernetes.io/version=1.9.24,clusterconfig.azure.com/extension-version=1.9.24

NAME                                          DESIRED   CURRENT   READY   AGE    LABELS
replicaset.apps/billing-operator-7875f7fb8f   1         1         1       138m   app.kubernetes.io/component=billing-operator,app.kubernetes.io/name=extensionsusage,pod-template-hash=7875f7fb8f
```
- https://learn.microsoft.com/en-us/azure/aks/cluster-extensions#currently-available-extensions

## k8s-csi-acstor.misc.pods.extension.acstor

```
k get all -n acstor --show-labels
NAME                                                                READY   STATUS    RESTARTS       AGE    LABELS
pod/azurecontainerstorage-agent-core-65578c78c8-8vj2r               3/3     Running   1 (133m ago)   135m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=agent-core,openebs.io/logging=true,pod-template-hash=65578c78c8
pod/azurecontainerstorage-agent-core-65578c78c8-tvzln               3/3     Running   1 (133m ago)   135m   acstor.azure.com/leader=true,app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=agent-core,openebs.io/logging=true,pod-template-hash=65578c78c8
pod/azurecontainerstorage-api-rest-c49cb88f8-lqvxl                  1/1     Running   0              135m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=api-rest,openebs.io/logging=true,pod-template-hash=c49cb88f8
pod/azurecontainerstorage-api-rest-c49cb88f8-xlf69                  1/1     Running   0              135m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=api-rest,openebs.io/logging=true,pod-template-hash=c49cb88f8
pod/azurecontainerstorage-arc-logs-4g9kn                            3/3     Running   2 (128m ago)   135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-logs,controller-revision-hash=69dfb5c598,pod-template-generation=1
pod/azurecontainerstorage-arc-logs-cbsjm                            3/3     Running   1 (131m ago)   135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-logs,controller-revision-hash=69dfb5c598,pod-template-generation=1
pod/azurecontainerstorage-arc-logs-jb2pb                            3/3     Running   1 (131m ago)   135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-logs,controller-revision-hash=69dfb5c598,pod-template-generation=1
pod/azurecontainerstorage-arc-metrics-5d56846cd-ttswz               3/3     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-metrics,pod-template-hash=5d56846cd
pod/azurecontainerstorage-capacity-provisioner-5dc7c846f5-846fc     1/1     Running   0              135m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=capacity-provisioner,pod-template-hash=5dc7c846f5
pod/azurecontainerstorage-capacity-provisioner-5dc7c846f5-ct9rj     1/1     Running   0              135m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=capacity-provisioner,pod-template-hash=5dc7c846f5
pod/azurecontainerstorage-cert-manager-6c4dc6b86d-tltm6             1/1     Running   0              135m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=6c4dc6b86d
pod/azurecontainerstorage-cert-manager-cainjector-95474c97b-czqln   1/1     Running   0              135m   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cainjector,app.kubernetes.io/version=v1.12.10,app=cainjector,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=95474c97b
pod/azurecontainerstorage-cert-manager-webhook-5bf9fbfb7d-gg9nn     1/1     Running   0              135m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=5bf9fbfb7d
pod/azurecontainerstorage-csi-controller-76999c75cd-5vgmq           5/5     Running   5 (133m ago)   135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-controller,openebs.io/logging=true,pod-template-hash=76999c75cd
pod/azurecontainerstorage-csi-controller-76999c75cd-kxpvv           5/5     Running   2 (133m ago)   135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-controller,openebs.io/logging=true,pod-template-hash=76999c75cd
pod/azurecontainerstorage-csi-node-7mtjh                            2/2     Running   0              135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-node,controller-revision-hash=74d6b6c67f,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-csi-node-kspbh                            2/2     Running   0              135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-node,controller-revision-hash=74d6b6c67f,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-csi-node-s5nw4                            2/2     Running   0              135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-node,controller-revision-hash=74d6b6c67f,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-dmesg-logger-9zbhm                        1/1     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=dmesg-logger,controller-revision-hash=c97f9cff6,pod-template-generation=1
pod/azurecontainerstorage-dmesg-logger-cmphl                        1/1     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=dmesg-logger,controller-revision-hash=c97f9cff6,pod-template-generation=1
pod/azurecontainerstorage-dmesg-logger-zkxkv                        1/1     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=dmesg-logger,controller-revision-hash=c97f9cff6,pod-template-generation=1
pod/azurecontainerstorage-etcd-operator-5b876d8fbf-nltzb            1/1     Running   0              135m   app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.5.1,heritage=Helm,kubernetes.azure.com/mdsd-tag=customer.etcdoperator,overlay-app=etcd-operator,pod-template-hash=5b876d8fbf,release=azurecontainerstorage
pod/azurecontainerstorage-io-engine-gkg88                           1/1     Running   0              135m   app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=io-engine,controller-revision-hash=5b56d8fdb7,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-io-engine-m6p5k                           1/1     Running   0              135m   app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=io-engine,controller-revision-hash=5b56d8fdb7,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-io-engine-rzdvh                           1/1     Running   0              135m   app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=io-engine,controller-revision-hash=5b56d8fdb7,openebs.io/logging=true,pod-template-generation=1
pod/azurecontainerstorage-kube-operator-746ffb4f4-5bvmb             1/1     Running   0              135m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,pod-template-hash=746ffb4f4,release=azurecontainerstorage
pod/azurecontainerstorage-metrics-exporter-9cft5                    1/1     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=metrics-exporter,controller-revision-hash=65c994c568,pod-template-generation=1
pod/azurecontainerstorage-metrics-exporter-v6rpk                    1/1     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=metrics-exporter,controller-revision-hash=65c994c568,pod-template-generation=1
pod/azurecontainerstorage-metrics-exporter-z7ncn                    1/1     Running   0              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=metrics-exporter,controller-revision-hash=65c994c568,pod-template-generation=1
pod/azurecontainerstorage-ndm-7zqxk                                 1/1     Running   0              135m   app=ndm,chart=openebs-ndm-1.1.1,component=ndm,controller-revision-hash=564b998697,heritage=Helm,name=openebs-ndm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,pod-template-generation=1,release=azurecontainerstorage
pod/azurecontainerstorage-ndm-fvmx9                                 1/1     Running   0              135m   app=ndm,chart=openebs-ndm-1.1.1,component=ndm,controller-revision-hash=564b998697,heritage=Helm,name=openebs-ndm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,pod-template-generation=1,release=azurecontainerstorage
pod/azurecontainerstorage-ndm-kjnbv                                 1/1     Running   0              135m   app=ndm,chart=openebs-ndm-1.1.1,component=ndm,controller-revision-hash=564b998697,heritage=Helm,name=openebs-ndm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,pod-template-generation=1,release=azurecontainerstorage
pod/azurecontainerstorage-ndm-operator-85c9bcd4f-ln9z9              1/1     Running   0              135m   app=ndm-operator-operator,chart=openebs-ndm-1.1.1,component=ndm-operator-operator,heritage=Helm,name=openebs-ndm-operator,openebs.io/component-name=ndm-operator-operator,openebs.io/version=2.2.0,pod-template-hash=85c9bcd4f,release=azurecontainerstorage
pod/azurecontainerstorage-operator-diskpool-59546b4c7-d2gp7         1/1     Running   0              135m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=operator-diskpool,openebs.io/logging=true,pod-template-hash=59546b4c7
pod/azurecontainerstorage-operator-diskpool-59546b4c7-pggch         1/1     Running   0              135m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=operator-diskpool,openebs.io/logging=true,pod-template-hash=59546b4c7
pod/azurecontainerstorage-prereq-b4dj5                              1/1     Running   0              135m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=azurecontainerstorage-prereq,controller-revision-hash=5f5889557,pod-template-generation=1
pod/azurecontainerstorage-prereq-dv8w7                              1/1     Running   0              135m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=azurecontainerstorage-prereq,controller-revision-hash=5f5889557,pod-template-generation=1
pod/azurecontainerstorage-prereq-m7dp9                              1/1     Running   0              135m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=azurecontainerstorage-prereq,controller-revision-hash=5f5889557,pod-template-generation=1
pod/diskpool-worker-local-9j2tj                                     1/1     Running   0              131m   acstor.azure.com/diskpool-type=ephemeralDisk,acstor.azure.com/diskpool=ephemeraldisk-temp-diskpool-siqcl,acstor.azure.com/managedby=capacity-provisioner,acstor.azure.com/mount-option=nodiscard,acstor.azure.com/skip-validation-check=true,acstor.azure.com/storagepool=ephemeraldisk-temp,app.kubernetes.io/component=storage-pool,app.kubernetes.io/instance=azurecontainerstorage-diskpool-worker,app.kubernetes.io/managed-by=capacity-provisioner,app.kubernetes.io/name=diskpool-worker,app.kubernetes.io/part-of=acstor
pod/diskpool-worker-local-wxcn7                                     1/1     Running   0              131m   acstor.azure.com/diskpool-type=ephemeralDisk,acstor.azure.com/diskpool=ephemeraldisk-temp-diskpool-gagxz,acstor.azure.com/managedby=capacity-provisioner,acstor.azure.com/mount-option=nodiscard,acstor.azure.com/skip-validation-check=true,acstor.azure.com/storagepool=ephemeraldisk-temp,app.kubernetes.io/component=storage-pool,app.kubernetes.io/instance=azurecontainerstorage-diskpool-worker,app.kubernetes.io/managed-by=capacity-provisioner,app.kubernetes.io/name=diskpool-worker,app.kubernetes.io/part-of=acstor
pod/diskpool-worker-local-zq5qq                                     1/1     Running   0              131m   acstor.azure.com/diskpool-type=ephemeralDisk,acstor.azure.com/diskpool=ephemeraldisk-temp-diskpool-qnyvl,acstor.azure.com/managedby=capacity-provisioner,acstor.azure.com/mount-option=nodiscard,acstor.azure.com/skip-validation-check=true,acstor.azure.com/storagepool=ephemeraldisk-temp,app.kubernetes.io/component=storage-pool,app.kubernetes.io/instance=azurecontainerstorage-diskpool-worker,app.kubernetes.io/managed-by=capacity-provisioner,app.kubernetes.io/name=diskpool-worker,app.kubernetes.io/part-of=acstor
pod/etcd-azurecontainerstorage-backup-sidecar-5bb65b59f9-f6p4m      1/1     Running   0              134m   app=etcd_backup_tool,etcd_cluster=etcd-azurecontainerstorage,kubernetes.azure.com/mdsd-tag=customer.etcdbackup,pod-template-hash=5bb65b59f9
pod/etcd-azurecontainerstorage-dpl2v9mqqh                           1/1     Running   0              134m   app=etcd,etcd_cluster=etcd-azurecontainerstorage,etcd_member_id=82c3d42939d17a49,etcd_node=etcd-azurecontainerstorage-dpl2v9mqqh
pod/etcd-azurecontainerstorage-gmjjwdsx8d                           1/1     Running   0              132m   app=etcd,etcd_cluster=etcd-azurecontainerstorage,etcd_member_id=1f5ce858878ab43,etcd_node=etcd-azurecontainerstorage-gmjjwdsx8d
pod/etcd-azurecontainerstorage-rkdzgqjqgj                           1/1     Running   0              133m   app=etcd,etcd_cluster=etcd-azurecontainerstorage,etcd_member_id=a4007c6a05873338,etcd_node=etcd-azurecontainerstorage-rkdzgqjqgj
pod/prometheus-azurecontainerstorage-prometheus-0                   2/2     Running   0              134m   app.kubernetes.io/instance=azurecontainerstorage-prometheus,app.kubernetes.io/managed-by=prometheus-operator,app.kubernetes.io/name=prometheus,app.kubernetes.io/version=2.39.0,apps.kubernetes.io/pod-index=0,controller-revision-hash=prometheus-azurecontainerstorage-prometheus-866964cc67,operator.prometheus.io/name=azurecontainerstorage-prometheus,operator.prometheus.io/shard=0,prometheus=azurecontainerstorage-prometheus,statefulset.kubernetes.io/pod-name=prometheus-azurecontainerstorage-prometheus-0

NAME                                                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)
            AGE    LABELS
service/azurecontainerstorage-agent-core               ClusterIP   10.0.58.243    <none>        50051/TCP
            135m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=agent-core
service/azurecontainerstorage-agent-elector            ClusterIP   None           <none>        9443/TCP
            135m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=agent-core
service/azurecontainerstorage-api-rest                 NodePort    10.0.114.34    <none>        8080:30010/TCP,8081:30011/TCP   135m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=api-rest
service/azurecontainerstorage-arc-prom-mdm-converter   ClusterIP   10.0.118.100   <none>        80/TCP
            135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-metrics
service/azurecontainerstorage-cert-manager             ClusterIP   10.0.243.5     <none>        9402/TCP
            135m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10
service/azurecontainerstorage-cert-manager-webhook     ClusterIP   10.0.227.138   <none>        443/TCP
            135m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10
service/azurecontainerstorage-kube-operator            ClusterIP   10.0.162.162   <none>        443/TCP
            135m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,release=azurecontainerstorage
service/capacity-provisioner-service                   ClusterIP   10.0.10.148    <none>        29604/TCP
            135m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=capacity-provisioner
service/etcd-azurecontainerstorage                     ClusterIP   None           <none>        2379/TCP,2380/TCP               134m   app=etcd,etcd_cluster=etcd-azurecontainerstorage
service/etcd-azurecontainerstorage-backup-sidecar      ClusterIP   10.0.55.194    <none>        19999/TCP,29999/TCP,39999/TCP   134m   app=etcd,etcd_cluster=etcd-azurecontainerstorage
service/etcd-azurecontainerstorage-client              ClusterIP   10.0.81.208    <none>        2379/TCP
            134m   app=etcd,etcd_cluster=etcd-azurecontainerstorage
service/etcdr-azurecontainerstorage                    ClusterIP   None           <none>        2379/TCP,2380/TCP               134m   app=etcd,etcd_cluster=etcdr-azurecontainerstorage
service/etcdr-azurecontainerstorage-client             ClusterIP   10.0.176.43    <none>        2379/TCP
            134m   app=etcd,etcd_cluster=etcdr-azurecontainerstorage
service/geneva-services                                ClusterIP   10.0.61.212    <none>        8130/TCP
            135m   app.kubernetes.io/managed-by=Helm,app=geneva-services
service/prometheus-operated                            ClusterIP   None           <none>        9090/TCP
            134m   operated-prometheus=true
service/webhook-service                                ClusterIP   10.0.22.196    <none>        443/TCP
            135m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=capacity-provisioner

NAME                                                    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                                                                       AGE    LABELS
daemonset.apps/azurecontainerstorage-arc-logs           3         3         3       3            3           <none>                                                                              135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-logs,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-logs,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-logs
daemonset.apps/azurecontainerstorage-csi-node           3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   135m   acstor.azure.com/io-engine=acstor,app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-node,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-node,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-node
daemonset.apps/azurecontainerstorage-dmesg-logger       3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-dmesg-logger,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=dmesg-logger,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=dmesg-logger
daemonset.apps/azurecontainerstorage-io-engine          3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   135m   acstor.azure.com/io-engine=acstor,app.kubernetes.io/component=io-engine,app.kubernetes.io/instance=azurecontainerstorage-io-engine,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=io-engine,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=io-engine
daemonset.apps/azurecontainerstorage-metrics-exporter   3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-metrics-exporter,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=metrics-exporter,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=metrics-exporter
daemonset.apps/azurecontainerstorage-ndm                3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   135m   app.kubernetes.io/managed-by=Helm,app=ndm,chart=openebs-ndm-1.1.1,component=ndm,heritage=Helm,openebs.io/component-name=ndm,openebs.io/version=2.2.0,release=azurecontainerstorage
daemonset.apps/azurecontainerstorage-prereq             3         3         3       3            3           acstor.azure.com/io-engine=acstor,kubernetes.io/arch=amd64,kubernetes.io/os=linux   135m   app.kubernetes.io/component=setup,app.kubernetes.io/instance=azurecontainerstorage-prereq,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prereq,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=azurecontainerstorage-prereq

NAME                                                            READY   UP-TO-DATE   AVAILABLE   AGE    LABELS
deployment.apps/azurecontainerstorage-agent-core                2/2     2            2           135m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=agent-core
deployment.apps/azurecontainerstorage-api-rest                  2/2     2            2           135m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=api-rest
deployment.apps/azurecontainerstorage-arc-metrics               1/1     1            1           135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-metrics
deployment.apps/azurecontainerstorage-capacity-provisioner      2/2     2            2           135m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=capacity-provisioner
deployment.apps/azurecontainerstorage-cert-manager              1/1     1            1           135m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10
deployment.apps/azurecontainerstorage-cert-manager-cainjector   1/1     1            1           135m   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cainjector,app.kubernetes.io/version=v1.12.10,app=cainjector,helm.sh/chart=cert-manager-v1.12.10
deployment.apps/azurecontainerstorage-cert-manager-webhook      1/1     1            1           135m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10
deployment.apps/azurecontainerstorage-csi-controller            2/2     2            2           135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-controller
deployment.apps/azurecontainerstorage-etcd-operator             1/1     1            1           135m   app.kubernetes.io/managed-by=Helm,app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.0.0-4d8ca343a539b77815d2f0152f13d9fc48a916ed,heritage=Helm,release=azurecontainerstorage
deployment.apps/azurecontainerstorage-kube-operator             1/1     1            1           135m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,release=azurecontainerstorage
deployment.apps/azurecontainerstorage-ndm-operator              1/1     1            1           135m   app.kubernetes.io/managed-by=Helm,app=ndm-operator-operator,chart=openebs-ndm-1.1.1,component=ndm-operator-operator,heritage=Helm,openebs.io/component-name=ndm-operator-operator,openebs.io/version=2.2.0,release=azurecontainerstorage
deployment.apps/azurecontainerstorage-operator-diskpool         2/2     2            2           135m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=operator-diskpool
deployment.apps/etcd-azurecontainerstorage-backup-sidecar       1/1     1            1           134m   app=etcd,etcd_cluster=etcd-azurecontainerstorage

NAME                                                                      DESIRED   CURRENT   READY   AGE    LABELS
replicaset.apps/azurecontainerstorage-agent-core-65578c78c8               2         2         2       135m   app.kubernetes.io/component=orchestrator,app.kubernetes.io/instance=azurecontainerstorage-agent-core,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=agent-core,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=agent-core,openebs.io/logging=true,pod-template-hash=65578c78c8
replicaset.apps/azurecontainerstorage-api-rest-c49cb88f8                  2         2         2       135m   app.kubernetes.io/component=api-server,app.kubernetes.io/instance=azurecontainerstorage-api-rest,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=api-rest,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=api-rest,openebs.io/logging=true,pod-template-hash=c49cb88f8
replicaset.apps/azurecontainerstorage-arc-metrics-5d56846cd               1         1         1       135m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-arc-metrics,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=arc-metrics,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=arc-metrics,pod-template-hash=5d56846cd
replicaset.apps/azurecontainerstorage-capacity-provisioner-5dc7c846f5     2         2         2       135m   app.kubernetes.io/component=capacity-provisoner,app.kubernetes.io/instance=azurecontainerstorage-capacity-provisioner,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=capacity-provisioner,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=capacity-provisioner,pod-template-hash=5dc7c846f5
replicaset.apps/azurecontainerstorage-cert-manager-6c4dc6b86d             1         1         1       135m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cert-manager,app.kubernetes.io/version=v1.12.10,app=cert-manager,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=6c4dc6b86d
replicaset.apps/azurecontainerstorage-cert-manager-cainjector-95474c97b   1         1         1       135m   app.kubernetes.io/component=cainjector,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=cainjector,app.kubernetes.io/version=v1.12.10,app=cainjector,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=95474c97b
replicaset.apps/azurecontainerstorage-cert-manager-webhook-5bf9fbfb7d     1         1         1       135m   app.kubernetes.io/component=webhook,app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=webhook,app.kubernetes.io/version=v1.12.10,app=webhook,helm.sh/chart=cert-manager-v1.12.10,pod-template-hash=5bf9fbfb7d
replicaset.apps/azurecontainerstorage-csi-controller-76999c75cd           2         2         2       135m   app.kubernetes.io/component=csi-driver,app.kubernetes.io/instance=azurecontainerstorage-csi-controller,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=csi-controller,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=csi-controller,openebs.io/logging=true,pod-template-hash=76999c75cd
replicaset.apps/azurecontainerstorage-etcd-operator-5b876d8fbf            1         1         1       135m   app=azurecontainerstorage-etcd-operator,chart=etcd-operator-0.5.1,heritage=Helm,kubernetes.azure.com/mdsd-tag=customer.etcdoperator,overlay-app=etcd-operator,pod-template-hash=5b876d8fbf,release=azurecontainerstorage
replicaset.apps/azurecontainerstorage-kube-operator-746ffb4f4             1         1         1       135m   app.kubernetes.io/instance=azurecontainerstorage,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/part-of=kube-prometheus-stack,app.kubernetes.io/version=42.2.1,app=kube-prometheus-stack-operator,chart=kube-prometheus-stack-42.2.1,heritage=Helm,pod-template-hash=746ffb4f4,release=azurecontainerstorage
replicaset.apps/azurecontainerstorage-ndm-operator-85c9bcd4f              1         1         1       135m   app=ndm-operator-operator,chart=openebs-ndm-1.1.1,component=ndm-operator-operator,heritage=Helm,name=openebs-ndm-operator,openebs.io/component-name=ndm-operator-operator,openebs.io/version=2.2.0,pod-template-hash=85c9bcd4f,release=azurecontainerstorage
replicaset.apps/azurecontainerstorage-operator-diskpool-59546b4c7         2         2         2       135m   app.kubernetes.io/component=operator,app.kubernetes.io/instance=azurecontainerstorage-operator-diskpool,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=operator-diskpool,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=operator-diskpool,openebs.io/logging=true,pod-template-hash=59546b4c7
replicaset.apps/etcd-azurecontainerstorage-backup-sidecar-5bb65b59f9      1         1         1       134m   app=etcd_backup_tool,etcd_cluster=etcd-azurecontainerstorage,kubernetes.azure.com/mdsd-tag=customer.etcdbackup,pod-template-hash=5bb65b59f9

NAME                                                           READY   AGE    LABELS
statefulset.apps/prometheus-azurecontainerstorage-prometheus   1/1     134m   app.kubernetes.io/component=monitor,app.kubernetes.io/instance=azurecontainerstorage-prometheus,app.kubernetes.io/managed-by=Helm,app.kubernetes.io/name=prometheus,app.kubernetes.io/part-of=azurecontainerstorage,app.kubernetes.io/version=1.1.1,app=prometheus,operator.prometheus.io/name=azurecontainerstorage-prometheus,operator.prometheus.io/shard=0,prometheus=acstor
```
