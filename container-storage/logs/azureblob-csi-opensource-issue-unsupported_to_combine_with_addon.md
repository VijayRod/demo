Installing the open-source Azure Blob CSI driver along with the Azure Blob Storage Container Storage Interface (CSI) driver add-on is <ins>not supported</ins>. This combination can lead to unexpected issues because the open-source CSI driver controller may take effect, and this controller is not present in the kube-system namespace when using the add-on version as mentioned here. This is also indicated in the CLI output message: "Please make sure there is no open-source Blob CSI driver installed before enabling". 

As indicated in [aks/azure-blob-csi#before-you-begin](https://learn.microsoft.com/en-us/azure/aks/azure-blob-csi?tabs=NFS#before-you-begin), follow the steps provided in [this link](https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-csi-driver-master.md#clean-up-blob-csi-driver) if you have previously installed the CSI Blob Storage open-source driver to access Azure Blob storage from your cluster. Remove the open-source Blob CSI driver, and then it should work as expected.

```
# Install the cluster and the open-source driver as indicated in https://github.com/VijayRod/demo/blob/master/container-storage/logs/azureblob-csi-opensource.md .

# Install the Azure blob CSI driver add-on and ignore the warning. Do this (ignore the warning) only in a TEST cluster since it is NOT SUPPORTED.
az aks update --enable-blob-driver -g $rgname -n $clustername

# Here is a sample output below.
# Please make sure there is no open-source Blob CSI driver installed before enabling. (y/N): y
# ...

# To retrieve related pods.
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below. Note the output includes csi-blob-controller pods which are not present in the add-on deployment.
# csi-blob-controller-fdf6d487c-tcxd7   4/4     Running   0          5h17m   10.224.0.5   aks-nodepool1-37173752-vmss000002   <none>           <none>
# csi-blob-controller-fdf6d487c-wfn2n   4/4     Running   0          5h17m   10.224.0.6   aks-nodepool1-37173752-vmss000001   <none>           <none>
# csi-blob-node-kgxgl                   3/3     Running   0          53s     10.224.0.7   aks-nodepool1-37173752-vmss000004   <none>           <none>
# csi-blob-node-lgtgh                   3/3     Running   0          61s     10.224.0.6   aks-nodepool1-37173752-vmss000001   <none>           <none>
# csi-blob-node-lmwls                   3/3     Running   0          71s     10.224.0.4   aks-nodepool1-37173752-vmss000000   <none>           <none>
# csi-blob-node-nh2xd                   3/3     Running   0          81s     10.224.0.5   aks-nodepool1-37173752-vmss000002   <none>           <none>

# Retrieve the image of the controller pod to confirm it is using the open-source version and not that of the add-on.
kubectl get po -n kube-system csi-blob-controller-fdf6d487c-wfn2n -oyaml | grep image | grep blob-csi

# Here is a sample output below.
    image: mcr.microsoft.com/k8s/csi/blob-csi:latest
```

```
# Remove the open-source driver.
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/deploy/uninstall-driver.sh | bash -s master --

# Here is a sample output below.
Uninstalling Azure Blob Storage CSI driver, version: master ...
deployment.apps "csi-blob-controller" deleted
daemonset.apps "csi-blob-node" deleted
csidriver.storage.k8s.io "blob.csi.azure.com" deleted
serviceaccount "csi-blob-controller-sa" deleted
clusterrole.rbac.authorization.k8s.io "blob-external-provisioner-role" deleted
clusterrolebinding.rbac.authorization.k8s.io "blob-csi-provisioner-binding" deleted
clusterrole.rbac.authorization.k8s.io "blob-external-resizer-role" deleted
clusterrolebinding.rbac.authorization.k8s.io "blob-csi-resizer-role" deleted
clusterrole.rbac.authorization.k8s.io "csi-blob-controller-secret-role" deleted
clusterrolebinding.rbac.authorization.k8s.io "csi-blob-controller-secret-binding" deleted
serviceaccount "csi-blob-node-sa" deleted
clusterrole.rbac.authorization.k8s.io "csi-blob-node-secret-role" deleted
clusterrolebinding.rbac.authorization.k8s.io "csi-blob-node-secret-binding" deleted
Uninstalled Azure Blob Storage CSI driver successfully.

# Retrieve the related pods. Note there is no controller pod.
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below.
# csi-blob-node-c6vgp                   3/3     Running   0          29s     10.224.0.5   aks-nodepool1-37173752-vmss000002   <none>           <none>
# csi-blob-node-dwnft                   3/3     Running   0          29s     10.224.0.4   aks-nodepool1-37173752-vmss000000   <none>           <none>
# csi-blob-node-lh22f                   3/3     Running   0          29s     10.224.0.6   aks-nodepool1-37173752-vmss000001   <none>           <none>
```

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-csi-driver-master.md#clean-up-blob-csi-driver
