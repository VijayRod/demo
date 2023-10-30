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
