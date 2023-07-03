Here are steps to create a Samba server with a StatefulSet in Linux using https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md. You can file any issues at https://github.com/kubernetes-csi/csi-driver-smb/issues. This setup is generally used with an on-prem SMB server. For troubleshooting, you can try manually mounting on the node to check for errors using the steps provided in https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/csi-debug.md#troubleshooting-connection-failure-on-agent-node.

```
# Replace the below with appropriate values.
rgname=
clustername=akssamba
```

```
# Create the cluster and retrieve the credentials.
az aks create -g $rgname -n $clustername
az aks get-credentials -g $rgname -n $clustername --overwrite-existing

# Create the secret with the smb-server resources. 
# https://github.com/kubernetes-csi/csi-driver-smb/tree/master/deploy/example/smb-provisioner
kubectl create secret generic smbcreds --from-literal username=USERNAME --from-literal password="PASSWORD"
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/smb-provisioner/smb-server-networkdisk.yaml

# Install the SMB driver pods.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/docs/install-smb-csi-driver.md
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/install-driver.sh | bash -s master --

# Create the storage class for the smb.csi.k8s.io provisioner, and a sample stateful set.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/storageclass-smb.yaml
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/statefulset.yaml
```

```
# Retrieve resources.
kubectl get sc smb
kubectl get pvc | grep smb
kubectl get po | grep smb

# Here is a sample output below. `pvc-networkdisk-smbshare` is the network disk in which the Samba server deployment was created with smb-server-networkdisk.yaml.
# NAME   PROVISIONER      RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
# smb    smb.csi.k8s.io   Delete          Immediate           false                  6h56m
#
# NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistent-storage-statefulset-smb-0   Bound    pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5   10Gi       RWO	 smb            7h13m
# pvc-networkdisk-smbshare               Bound    pvc-506ec43d-ff96-4791-adc2-3a3de51c5070   100Gi      RWO	 default        6h56m
#
# NAME                          READY   STATUS    RESTARTS   AGE
# smb-server-5dd8f8fb58-q5fth   1/1     Running   0          6h56m
# statefulset-smb-0             1/1     Running   0          6h56m
```

```
# Execute into the container.
kubectl exec -it statefulset-smb-0 -- df -h | grep smb

# Here is a sample output below.
# Filesystem                                                                             Size  Used Avail Use% Mounted
# //smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5   98G   17M   98G   1% /mnt/smb
```

```
# Retrieve logs from the SMB server pod.
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
# To view the syslog of the node hosting the pod. Run the second command during node SSH.
kubectl get po -owide | grep statefulset-smb
cat /var/log/syslog

# Here is a sample output below.
# Jul  3 13:12:29 aks-nodepool1-84224479-vmss000001 kubelet[1611]: I0703 13:12:29.579134    1611 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5\" (UniqueName: \"kubernetes.io/csi/smb.csi.k8s.io^smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#\") pod \"statefulset-smb-0\" (UID: \"e5141c6c-79f7-49d6-a671-45e444efd434\") " pod="default/statefulset-smb-0"
# Jul  3 13:12:29 aks-nodepool1-84224479-vmss000001 kubelet[1611]: I0703 13:12:29.679877    1611 reconciler.go:269] "operationExecutor.MountVolume started for volume \"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5\" (UniqueName: \"kubernetes.io/csi/smb.csi.k8s.io^smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#\") pod \"statefulset-smb-0\" (UID: \"e5141c6c-79f7-49d6-a671-45e444efd434\") " pod="default/statefulset-smb-0"
# Jul  3 13:12:29 aks-nodepool1-84224479-vmss000001 kubelet[1611]: I0703 13:12:29.723647    1611 operation_generator.go:658] "MountVolume.MountDevice succeeded for volume \"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5\" (UniqueName: \"kubernetes.io/csi/smb.csi.k8s.io^smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#\") pod \"statefulset-smb-0\" (UID: \"e5141c6c-79f7-49d6-a671-45e444efd434\") device mount path \"/var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount\"" pod="default/statefulset-smb-0"
# Jul  3 13:12:29 aks-nodepool1-84224479-vmss000001 kernel: [11520.062521] CIFS: Attempting to mount \\smb-server.default.svc.cluster.local\share
# Jul  3 13:12:29 aks-nodepool1-84224479-vmss000001 kubelet[1611]: I0703 13:12:29.736179    1611 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5\" (UniqueName: \"kubernetes.io/csi/smb.csi.k8s.io^smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#\") pod \"statefulset-smb-0\" (UID: \"e5141c6c-79f7-49d6-a671-45e444efd434\") " pod="default/statefulset-smb-0"
```

```
# To display the node mount. Run the second command during node SSH.
kubectl get po -o wide -n kube-system | grep csi-smb-node
sudo mount | grep cifs

# Here is a sample output below.
# //smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5 on /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=USERNAME,uid=1001,noforceuid,gid=1001,noforcegid,addr=10.0.194.14,file_mode=0777,dir_mode=0777,soft,nounix,mapposix,mfsymlinks,noperm,rsize=4194304,wsize=4194304,bsize=1048576,echo_interval=60,actimeo=1,closetimeo=1)
# //smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5 on /var/lib/kubelet/pods/e5141c6c-79f7-49d6-a671-45e444efd434/volumes/kubernetes.io~csi/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=USERNAME,uid=1001,noforceuid,gid=1001,noforcegid,addr=10.0.194.14,file_mode=0777,dir_mode=0777,soft,nounix,mapposix,mfsymlinks,noperm,rsize=4194304,wsize=4194304,bsize=1048576,echo_interval=60,actimeo=1,closetimeo=1)
```

```
# Cleanup.
kubectl delete statefulset statefulset-smb
kubectl delete svc smb-server
kubectl delete deploy smb-server
kubectl delete pvc pvc-networkdisk-smbshare
kubectl delete sc smb
kubectl delete secret smbcreds
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/uninstall-driver.sh | bash -s --
```
