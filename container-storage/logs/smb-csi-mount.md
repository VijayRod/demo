Here are the steps to create a StatefulSet in Linux using https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md. These steps should be followed after installing the SMB Server and the SMB driver as indicated [here](smb-csi-mount_initialize.md).

```
# To create a sample stateful set. This assumes the cluster credentials have been retrieved with 'az aks get-credentials'.
# https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/e2e_usage.md
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/deploy/example/statefulset.yaml
```

```
# To retrieve resources.
kubectl get pvc | grep statefulset-smb
kubectl get po | grep statefulset-smb

# Here is a sample output below. `pvc-networkdisk-smbshare` is the network disk in which the Samba server deployment was created with smb-server-networkdisk.yaml.
# NAME                                   STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
# persistent-storage-statefulset-smb-0   Bound    pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5   10Gi       RWO	 smb            7h13m
#
# NAME                          READY   STATUS    RESTARTS   AGE
# statefulset-smb-0             1/1     Running   0          6h56m
```

```
# To display the pod mount after container exec.
kubectl exec -it statefulset-smb-0 -- df -h | grep smb

# Here is a sample output below.
# Filesystem                                                                             Size  Used Avail Use% Mounted
# //smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5   98G   17M   98G   1% /mnt/smb
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
# To retrieve logs from the SMB driver pod, use the first command to find the name of the driver pod on the node in which the required pod is mounted.
k get po -n kube-system -owide -l app=csi-smb-node | grep vmss000001
kubectl logs -n kube-system csi-smb-node-4z5wd -c smb

# Here is a sample output below.
I0703 13:12:29.687937       1 utils.go:76] GRPC call: /csi.v1.Node/NodeStageVolume
I0703 13:12:29.687954       1 utils.go:77] GRPC request: {"secrets":"***stripped***","staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["dir_mode=0777","file_mode=0777","uid=1001","gid=1001","noperm","mfsymlinks","cache=strict","noserverino"]}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/pv/name":"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5","csi.storage.k8s.io/pvc/name":"persistent-storage-statefulset-smb-0","csi.storage.k8s.io/pvc/namespace":"default","source":"//smb-server.default.svc.cluster.local/share","storage.kubernetes.io/csiProvisionerIdentity":"1688389939368-3508-smb.csi.k8s.io","subdir":"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5"},"volume_id":"smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#"}
I0703 13:12:29.688146       1 nodeserver.go:206] NodeStageVolume: targetPath(/var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount) volumeID(smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#) context(map[csi.storage.k8s.io/pv/name:pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5 csi.storage.k8s.io/pvc/name:persistent-storage-statefulset-smb-0 csi.storage.k8s.io/pvc/namespace:default source://smb-server.default.svc.cluster.local/share storage.kubernetes.io/csiProvisionerIdentity:1688389939368-3508-smb.csi.k8s.io subdir:pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5]) mountflags([dir_mode=0777 file_mode=0777 uid=1001 gid=1001 noperm mfsymlinks cache=strict noserverino]) mountOptions([dir_mode=0777 file_mode=0777 uid=1001 gid=1001 noperm mfsymlinks cache=strict noserverino])
I0703 13:12:29.688476       1 mount_linux.go:245] Detected OS without systemd
I0703 13:12:29.688505       1 mount_linux.go:220] Mounting cmd (mount) with arguments (-t cifs -o dir_mode=0777,file_mode=0777,uid=1001,gid=1001,noperm,mfsymlinks,cache=strict,noserverino,<masked> //smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5 /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount)
I0703 13:12:29.723221       1 nodeserver.go:238] volume(smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#) mount "//smb-server.default.svc.cluster.local/share/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5" on "/var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount" succeeded
I0703 13:12:29.723251       1 utils.go:83] GRPC response: {}
I0703 13:12:29.728276       1 utils.go:76] GRPC call: /csi.v1.Node/NodePublishVolume
I0703 13:12:29.728293       1 utils.go:77] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount","target_path":"/var/lib/kubelet/pods/e5141c6c-79f7-49d6-a671-45e444efd434/volumes/kubernetes.io~csi/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5/mount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["dir_mode=0777","file_mode=0777","uid=1001","gid=1001","noperm","mfsymlinks","cache=strict","noserverino"]}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/ephemeral":"false","csi.storage.k8s.io/pod.name":"statefulset-smb-0","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"e5141c6c-79f7-49d6-a671-45e444efd434","csi.storage.k8s.io/pv/name":"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5","csi.storage.k8s.io/pvc/name":"persistent-storage-statefulset-smb-0","csi.storage.k8s.io/pvc/namespace":"default","csi.storage.k8s.io/serviceAccount.name":"default","source":"//smb-server.default.svc.cluster.local/share","storage.kubernetes.io/csiProvisionerIdentity":"1688389939368-3508-smb.csi.k8s.io","subdir":"pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5"},"volume_id":"smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#"}
I0703 13:12:29.729396       1 nodeserver.go:79] NodePublishVolume: mounting /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount at /var/lib/kubelet/pods/e5141c6c-79f7-49d6-a671-45e444efd434/volumes/kubernetes.io~csi/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5/mount with mountOptions: [bind] volumeID(smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#)
I0703 13:12:29.729420       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount /var/lib/kubelet/pods/e5141c6c-79f7-49d6-a671-45e444efd434/volumes/kubernetes.io~csi/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5/mount)
I0703 13:12:29.732110       1 mount_linux.go:220] Mounting cmd (mount) with arguments ( -o bind,remount /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount /var/lib/kubelet/pods/e5141c6c-79f7-49d6-a671-45e444efd434/volumes/kubernetes.io~csi/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5/mount)
I0703 13:12:29.735843       1 nodeserver.go:86] NodePublishVolume: mount /var/lib/kubelet/plugins/kubernetes.io/csi/smb.csi.k8s.io/695339b4138abd4a1bf042424cbeceace49396ffdb07171561e8c2ee4b40bb87/globalmount at /var/lib/kubelet/pods/e5141c6c-79f7-49d6-a671-45e444efd434/volumes/kubernetes.io~csi/pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5/mount volumeID(smb-server.default.svc.cluster.local/share#pvc-e2254491-c10b-4e3d-9271-416c2a43a9a5#) successfully
I0703 13:12:29.735868       1 utils.go:83] GRPC response: {}
```

```
# To cleanup.
kubectl delete statefulset statefulset-smb
```
