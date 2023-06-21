Here are steps from https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-csi-driver-master.md to install the <ins>open-source</ins> Azure Blob Storage CSI driver. The support policy can be found [here](https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/support.md).

```
# Replace the below with appropriate values.
rgname=resourceGroupName
clustername=aksblobpopen
```

```
# Install the cluster. Optionally, run az aks show for an existing cluster.
az aks create -g secureshack2 -n aksblobpopen

# To get credentials for running commands further below.
az aks get-credentials -g secureshack2 -n aksblobpopen
```

```
# Install the open-source Azure Blob CSI driver.
curl -skSL https://raw.githubusercontent.com/kubernetes-sigs/blob-csi-driver/master/deploy/install-driver.sh | bash -s master blobfuse-proxy --

# Here is a sample output below.
Installing Azure Blob Storage CSI driver, version: master ...
serviceaccount/csi-blob-controller-sa created
clusterrole.rbac.authorization.k8s.io/blob-external-provisioner-role created
clusterrolebinding.rbac.authorization.k8s.io/blob-csi-provisioner-binding created
clusterrole.rbac.authorization.k8s.io/blob-external-resizer-role created
clusterrolebinding.rbac.authorization.k8s.io/blob-csi-resizer-role created
clusterrole.rbac.authorization.k8s.io/csi-blob-controller-secret-role created
clusterrolebinding.rbac.authorization.k8s.io/csi-blob-controller-secret-binding created
serviceaccount/csi-blob-node-sa configured
clusterrole.rbac.authorization.k8s.io/csi-blob-node-secret-role configured
clusterrolebinding.rbac.authorization.k8s.io/csi-blob-node-secret-binding configured
csidriver.storage.k8s.io/blob.csi.azure.com configured
deployment.apps/csi-blob-controller created
set enable-blobfuse-proxy as true ...
daemonset.apps/csi-blob-node configured
Azure Blob Storage CSI driver installed successfully.
```

```
# To retrieve related pods:
kubectl get po -n kube-system -owide | grep csi-blob

# Here is a sample output below. Each node has a csi-blob-node pod. There are also controller pods.
# csi-blob-controller-fdf6d487c-tcxd7   4/4     Running   0          7m8s   10.224.0.5    aks-nodepool1-37173752-vmss000002   <none>           <none>
# csi-blob-controller-fdf6d487c-wfn2n   4/4     Running   0          7m8s   10.224.0.6    aks-nodepool1-37173752-vmss000001   <none>           <none>
# csi-blob-node-gnqtd                   3/3     Running   0          7m8s   10.224.0.4    aks-nodepool1-37173752-vmss000000   <none>           <none>
# csi-blob-node-rnvpt                   3/3     Running   0          7m8s   10.224.0.6    aks-nodepool1-37173752-vmss000001   <none>           <none>
# csi-blob-node-t4nmf                   3/3     Running   0          7m8s   10.224.0.5    aks-nodepool1-37173752-vmss000002   <none>           <none>

# To retrieve the image, use the following command:
kubectl get po -n kube-system csi-blob-node-gnqtd -oyaml | grep image: | grep blob

# Here is a sample output below.
#    image: mcr.microsoft.com/k8s/csi/blob-csi:latest
```
