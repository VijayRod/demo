This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). After creating the storage pool, proceed to create a pod with a persistent volume that utilizes the newly created storage class.

```
# Replace values in the below.
nodepoolname_nvme=npnvme
```

```
# Create the NVMe node pool.
az aks nodepool add -g $rgname --cluster-name $clustername -n $nodepoolname_nvme -s Standard_L8s_v2 --node-count 3 --labels acstor.azure.com/io-engine=acstor --mode user ## Required minimum of three nodes, four virtual CPUs (vCPUs), and the label.
```

```
# Create the storage pool.
cat << EOF | kubectl apply -f -
apiVersion: containerstorage.azure.com/v1alpha1
kind: StoragePool
metadata:
  name: ephemeraldisk
  namespace: acstor
spec:
  poolType:
    ephemeralDisk: {}
EOF
```
