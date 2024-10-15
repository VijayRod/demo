##  k8s-csi-acstor

```
Begin with k8s-csi-acstor.storagepool.type.ephemeralDisk.TempSSD
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/install-container-storage-aks
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
az aks create -g $rg -n aksnvme -s Standard_D4s_v3 --enable-azure-container-storage ephemeralDisk --storage-pool-option NVMe
az aks get-credentials -g $rg -n akseph --overwrite-existing
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk

##  k8s-csi-acstor.storagepool.type.ephemeralDisk.NVMe.replication

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-nvme-replication

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
```

- https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-temp-ssd
