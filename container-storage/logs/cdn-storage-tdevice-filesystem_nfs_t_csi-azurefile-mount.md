```
kubectl delete po fiopod
kubectl delete pvc pvc-azurefile-nfs
kubectl delete sc azurefile-csi-nfs

# To create the resources
cat << EOF | kubectl create -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi-nfs
provisioner: file.csi.azure.com
allowVolumeExpansion: true
parameters:
  protocol: nfs
mountOptions:
  - nconnect=4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-nfs
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: azurefile-csi-nfs
  resources:
    requests:
      storage: 250Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: fiopod
spec:
  volumes:
    - name: azuredisk
      persistentVolumeClaim:
        claimName: pvc-azurefile-nfs
  containers:
    - name: fio
      image: nixery.dev/shell/fio
      args:
        - sleep
        - "1000000"
      volumeMounts:
        - mountPath: "/volume"
          name: azuredisk
EOF
kubectl get po,pv,pvc,sc
```

```
kubectl get pv | grep nfs
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM         STORAGECLASS              REASON   AGE
pvc-917a5c08-ad17-49ca-b10f-829e6238081e   250Gi      RWO            Delete           Bound    default/pvc-azurefile-nfs     azurefile-csi-nfs  13m

kubectl describe pv pvc-917a5c08-ad17-49ca-b10f-829e6238081e | grep VolumeH
    VolumeHandle:      mc_rgblob_aksblob_centralus#fa59c59b1608c402e85685a#pvcn-917a5c08-ad17-49ca-b10f-829e6238081e###default

nslookup fa59c59b1608c402e85685a.file.core.windows.net
fa59c59b1608c402e85685a.file.core.windows.net   canonical name = file.dsm07prdstf50a.store.core.windows.net.
Name:   file.dsm07prdstf50a.store.core.windows.net
Address: 20.60.241.redacted
```

```
Name:            pvc-b3d4915e-7595-4f25-8e5b-a49bfd593bd3
Labels:          <none>
Annotations:     pv.kubernetes.io/provisioned-by: file.csi.azure.com
                 volume.kubernetes.io/provisioner-deletion-secret-name:
                 volume.kubernetes.io/provisioner-deletion-secret-namespace:
Finalizers:      [external-provisioner.volume.kubernetes.io/finalizer kubernetes.io/pv-protection]
StorageClass:    azurefile-csi-nfs
Status:          Bound
Claim:           default/pvc-azurefile-nfs
Reclaim Policy:  Delete
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        250Gi
Node Affinity:   <none>
Message:
Source:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            file.csi.azure.com
    FSType:
    VolumeHandle:      MC_rgml_aks_eastus2#f80aaf03132434a4e85a359#pvcn-b3d4915e-7595-4f25-8e5b-a49bfd593bd3###default
    ReadOnly:          false
    VolumeAttributes:      csi.storage.k8s.io/pv/name=pvc-b3d4915e-7595-4f25-8e5b-a49bfd593bd3
                           csi.storage.k8s.io/pvc/name=pvc-azurefile-nfs
                           csi.storage.k8s.io/pvc/namespace=default
                           protocol=nfs
                           secretnamespace=default
                           storage.kubernetes.io/csiProvisionerIdentity=1741601941848-2567-file.csi.azure.com
Events:                <none>

# temporarily enable firewall access from all networks
token="replace"
az storage share list --account-name f80aaf03132434a4e85a359 --sas-token $token
[
  {
    "name": "pvcn-b3d4915e-7595-4f25-8e5b-a49bfd593bd3",
    "protocols": [
      "NFS"
    ],
    
root@aks-nodepool1-98803342-vmss000000:/# nslookup f80aaf03132434a4e85a359.file.core.windows.net
Server:         168.63.129.16
Address:        168.63.129.16#53
Non-authoritative answer:
f80aaf03132434a4e85a359.file.core.windows.net   canonical name = file.lvl05prdstf01a.store.core.windows.net.
Name:   file.lvl05prdstf01a.store.core.windows.net
Address: 57.150.152.165

root@aks-nodepool1-98803342-vmss000000:/# ping 57.150.152.165
PING 57.150.152.165 (57.150.152.165) 56(84) bytes of data.
^C
--- 57.150.152.165 ping statistics ---
10 packets transmitted, 0 received, 100% packet loss, time 9205ms
```

```
kubectl delete po fiopod
kubectl delete pvc pvc-azurefile-nfs
kubectl delete sc azurefile-csi-nfs
```

- https://learn.microsoft.com/en-us/azure/aks/azure-files-csi#nfs-file-shares
- https://learn.microsoft.com/en-us/azure/aks/concepts-storage#azure-files
- https://cloud-provider-azure.sigs.k8s.io/faq/known-issues/azurefile/
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/files-troubleshoot
