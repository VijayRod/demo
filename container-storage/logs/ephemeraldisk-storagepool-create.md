This uses the steps mentioned in https://learn.microsoft.com/en-us/azure/storage/container-storage/use-container-storage-with-local-disk after adding the container storage extension mentioned [here](storagepool-containerstorage_extension-create.md). After creating the storage pool, proceed to create a pod with a persistent volume that utilizes the newly created storage class.

```
# Replace values in the below.
nodepoolname_nvme=npnvme
```

```
# Create the NVMe node pool.
az aks nodepool add -g $rgname --cluster-name $clustername -n $nodepoolname_nvme -s Standard_L8s_v2 --node-count 3 --labels acstor.azure.com/io-engine=acstor --mode user ## Required minimum of three nodes, four virtual CPUs (vCPUs), and the label.

# Optionally, verify the creation.
kubectl get no --selector acstor.azure.com/io-engine=acstor,kubernetes.azure.com/agentpool=npnvme

# Here is a sample output below.
# NAME                             STATUS   ROLES   AGE     VERSION
# aks-npnvme-18978270-vmss000000   Ready    agent   5m7s    v1.25.6
# aks-npnvme-18978270-vmss000001   Ready    agent   5m18s   v1.25.6
# aks-npnvme-18978270-vmss000002   Ready    agent   5m16s   v1.25.6
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
