Here are steps from https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi to install this driver.
      
```
# Replace the below with appropriate values.
rgname=resourceGroupName
clustername=aksblob
```

```
# Install the cluster. Optionally, run az aks show for an existing cluster.
az aks create -g secureshack2 -n aksblob

# Here is a sample output below.
#   "storageProfile": {
#     "blobCsiDriver": null,

# Enable the Azure blob CSI driver.
az aks update --enable-blob-driver -g secureshack2 -n aks

# Here is a sample output below.
# Please make sure there is no open-source Blob CSI driver installed before enabling. (y/N): y
# ...
#   "storageProfile": {
#     "blobCsiDriver": {
#       "enabled": true
```

```
# To get credentials for running commands further below.
az aks get-credentials -g secureshack2 -n aksblob

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
