Run the following command to remove the driver as indicated in https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/docs/install-csi-driver-master.md#clean-up-blob-csi-driver.

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

# Run the below to confirm that there is no output.
kubectl get po -n kube-system -owide | grep csi-blob
```
