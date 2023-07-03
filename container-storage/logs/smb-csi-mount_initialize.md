Here are the steps to create a Samba server using https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md. If you encounter any issues, you can file them at https://github.com/kubernetes-csi/csi-driver-smb/issues. This setup is generally used with an on-prem SMB server. For troubleshooting, you can try manually mounting on the node to check for errors, following the steps provided in https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/csi-debug.md#troubleshooting-connection-failure-on-agent-node. Additionally, known issues can be found at https://github.com/kubernetes-csi/csi-driver-smb/blob/master/known-issues.md.

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

# To install the SMB driver pods.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/install-smb-csi-driver.md
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/install-driver.sh | bash -s master --

# To create the storage class for the smb.csi.k8s.io provisioner.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/storageclass-smb.yaml
```

```
# To retrieve resources.
kubectl get sc smb
kubectl get pvc | grep smbshare
kubectl get po | grep smb-server

# Here is a sample output below. `pvc-networkdisk-smbshare` is the network disk in which the Samba server deployment was created with smb-server-networkdisk.yaml.
# NAME   PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
# smb    smb.csi.k8s.io   Delete          Immediate           false                  6h56m
#
# NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# pvc-networkdisk-smbshare               Bound    pvc-506ec43d-ff96-4791-adc2-3a3de51c5070   100Gi      RWO	 default        6h56m
#
# NAME                          READY   STATUS    RESTARTS   AGE
# smb-server-5dd8f8fb58-q5fth   1/1     Running   0          6h56m
```

```
# To retrieve logs from the SMB server pod.
kubectl logs -l app=smb-server

# Here is a sample output below.
# Added user USERNAME.
# smbd version 4.12.2 started.
# Copyright Andrew Tridgell and the Samba Team 1992-2020
# daemon_ready: daemon 'smbd' finished starting up and ready to serve connections

# To display the smb-server pod(s).
kubectl get po -l app=smb-server

# Here is a sample output below.
# NAME                          READY   STATUS    RESTARTS   AGE
# smb-server-5dd8f8fb58-q5fth   1/1     Running   0          7h
```

```
# To display the SMB driver pods. The first pod has the label app=csi-smb-controller, and the remaining pods have the label app=csi-smb-node.
k get po -n kube-system | grep csi-smb

csi-smb-controller-57d6576c7b-qkgbt   3/3     Running   0          4h37m
csi-smb-node-4z5wd                    3/3     Running   0          4h37m
csi-smb-node-7b9tk                    3/3     Running   0          4h37m
csi-smb-node-wpk24                    3/3     Running   0          4h37m

# To display the SMB driver daemonsets.
kubectl get ds -n kube-system | grep csi-smb-node

# NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR              AGE     LABELS
# csi-smb-node                 3         3         3       3            3           kubernetes.io/os=linux     4h36m
# csi-smb-node-win             0         0         0       0            0           kubernetes.io/os=windows   4h36m
```

```
# To cleanup.
kubectl delete svc smb-server
kubectl delete deploy smb-server
kubectl delete pvc pvc-networkdisk-smbshare
kubectl delete sc smb
kubectl delete secret smbcreds
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/uninstall-driver.sh | bash -s --
```
