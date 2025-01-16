## smb.cifs

```
TBD
az aks nodepool add -g $rg --cluster-name aks -n npuser --mode=user -c 1 -s $vmsize
kubectl get no -l kubernetes.azure.com/mode=user,kubernetes.io/os=windows
kubectl apply -f https://raw.githubusercontent.com/ksubmsft/daemonset-repro/main/cifs-debug.ds.yaml
kubectl get po name=cifs-credits-diag
kubectl logs -l name=cifs-credits-diag
```

- TBD https://github.com/ksubmsft/daemonset-repro/blob/main/cifs-debug.ds.yaml: "/tmp/$(hostname)_*.tgz"

## smb.cifs.app.k8s.csi

- https://learn.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-linux?tabs=Ubuntu%2Csmb311: sudo apt install cifs-utils

## smb.cifs.error-waiting_for_provisioner_smb.csi.k8s.io

The "waiting for a volume to be created, either by external provisioner 'smb.csi.k8s.io'" message with PVC in a pending state may be due to no running SMB driver pods. To resolve this issue, you should install the SMB driver pods.

```
# Replace the below with appropriate values.
rgname=
clustername=akssamba
```

```
# To create the cluster and retrieve the credentials.
az aks create -g $rgname -n $clustername
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

# To create the secret with the smb-server resources. 
# https://github.com/kubernetes-csi/csi-driver-smb/tree/master/deploy/example/smb-provisioner
kubectl create secret generic smbcreds --from-literal username=USERNAME --from-literal password="PASSWORD"
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/smb-provisioner/smb-server-networkdisk.yaml

# To create the storage class for the smb.csi.k8s.io provisioner.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/storageclass-smb.yaml

# To create a sample stateful set. This assumes the cluster credentials have been retrieved with 'az aks get-credentials'.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/statefulset.yaml
```

```
# To retrieve the pvc. This is in the pending state.
kubectl get pvc | grep statefulset-smb

# Here is a sample output below.
# NAME                                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistent-storage-statefulset-smb-0   Pending	  smb

# To describe the pvc.
kubectl describe pvc persistent-storage-statefulset-smb-0

# Here is a sample output below.
# Events:
#   Type    Reason                Age                            From                         Message
#   ----    ------                ----                           ----                         -------
#   Normal  ExternalProvisioning  <invalid> (x6 over <invalid>)  persistentvolume-controller  waiting for a volume to be created, either by external provisioner "smb.csi.k8s.io" or manually created by system administrator
```

```
# To get the CSI driver daemon set.  
kubectl get ds -n kube-system csi-smb-node

# Here is a sample output below.
# Error from server (NotFound): daemonsets.apps "csi-smb-node" not found
```

Now install the driver pods to resolve.

```
# To install the SMB driver pods.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/install-smb-csi-driver.md
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/install-driver.sh | bash -s master --

# To get the CSI driver daemon set.  
kubectl get ds -n kube-system | grep csi-smb

# Here is a sample output below.
# csi-smb-node                 3         3         3       3            3           kubernetes.io/os=linux     4m
# csi-smb-node-win             0         0         0       0            0           kubernetes.io/os=windows   3m59s

# # To retrieve the pvc. This is in the bound state.
kubectl get pvc | grep statefulset-smb

# Here is a sample output below.
# NAME                                   STATUS    VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistent-storage-statefulset-smb-0   Bound    pvc-8c451dbb-9e8c-4df3-8f54-c54ab14ea620   10Gi       RWO	 smb            4m9s
```
