## inline

This uses steps in 
https://learn.microsoft.com/en-us/azure/aks/azure-csi-files-storage-provision#mount-file-share-as-an-inline-volume to use the Azure File CSI driver to mount an inline Azure File share as a volume in a pod. Inline volumes follow the lifecyle of the pod as indicated in https://kubernetes.io/blog/2022/08/29/csi-inline-volumes-ga/.

```
# Replace the below with appropriate values.
rgname=
storageAccountName="mystorageacct$RANDOM"
shareName=aksshare
```

```
# Create a storage account.
az storage account create -g $rgname -n $storageAccountName --kind FileStorage --sku Premium_LRS --enable-large-file-share --output none

# Retrieve the storage account key.
key=$(az storage account keys list -g $rgname -n $storageAccountName --query [0].value -o tsv)

# Create a file share.
az storage share-rm create -g $rgname --storage-account $storageAccountName -n $shareName --quota 1024 --enabled-protocols SMB --output none
```

```
# Create the Kubernetes secret to store the Azure storage account credentials. This assumes az aks get-credentials has already been run to retrieve access credentials.
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storageAccountName --from-literal=azurestorageaccountkey=$key

# Create the resources.
cat << EOF | kubectl create -f - 
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - image: nginx
    name: mypod
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
  - name: azure
    csi:
      driver: file.csi.azure.com
      readOnly: false
      volumeAttributes:
        secretName: azure-secret  # required
        shareName: $shareName  # required
        mountOptions: "dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock"  # optional
EOF
```

```
# Display the resource. Since this is an inline volume, there won't be a Persistent Volume (PV) associated with it.
kubectl get po,pv

# Here is a sample output below.
# NAME                                                        READY   STATUS      RESTARTS   AGE
# pod/mypod                                                   1/1     Running     0          33s

# Retrieve the node name.
kubectl get po -owide

# Here is a sample output below.
# NAME                                                    READY   STATUS      RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
# mypod                                                   1/1     Running     0          7m53s   10.244.0.13   aks-nodepool1-51397738-vmss000004   <none>           <none>
```

```
# Describe includes the below output. There is no persistent volume claim in this output.
kubectl describe po mypod

# Here is a sample output below.
Containers:
  mypod:
    Mounts:
      /mnt/azure from azure (rw)
Volumes:
  azure:
    Type:              CSI (a Container Storage Interface (CSI) volume source)
    Driver:            file.csi.azure.com
    FSType:
    ReadOnly:          false
    VolumeAttributes:      mountOptions=dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock
                           secretName=azure-secret
                           shareName=aksshare
```

```
# To view the node syslog for the volume.
cat /var/log/syslog

# Here is a sample output below.
Jun 29 20:24:15 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 20:24:15.663214    1620 reconciler.go:357] "operationExecutor.VerifyControllerAttachedVolume started for volume \"azure\" (UniqueName: \"kubernetes.io/csi/1eed8fa0-86c4-4129-91de-bba88aee99ad-azure\") pod \"mypod\" (UID: \"1eed8fa0-86c4-4129-91de-bba88aee99ad\") " pod="default/mypod"
Jun 29 20:24:15 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 20:24:15.763910    1620 reconciler.go:269] "operationExecutor.MountVolume started for volume \"azure\" (UniqueName: \"kubernetes.io/csi/1eed8fa0-86c4-4129-91de-bba88aee99ad-azure\") pod \"mypod\" (UID: \"1eed8fa0-86c4-4129-91de-bba88aee99ad\") " pod="default/mypod"
Jun 29 20:24:15 aks-nodepool1-51397738-vmss000004 kernel: [38768.348501] CIFS: Attempting to mount \\mystorageacct19813.file.core.windows.net\aksshare
Jun 29 20:24:15 aks-nodepool1-51397738-vmss000004 kubelet[1620]: I0629 20:24:15.911954    1620 operation_generator.go:730] "MountVolume.SetUp succeeded for volume \"azure\" (UniqueName: \"kubernetes.io/csi/1eed8fa0-86c4-4129-91de-bba88aee99ad-azure\") pod \"mypod\" (UID: \"1eed8fa0-86c4-4129-91de-bba88aee99ad\") " pod="default/mypod"

# Mount output from the node for this volume.
root@aks-nodepool1-51397738-vmss000003:/# mount | grep mystorageacct

# Here is a sample output below.
//mystorageacct19813.file.core.windows.net/aksshare on /var/lib/kubelet/pods/1eed8fa0-86c4-4129-91de-bba88aee99ad/volumes/kubernetes.io~csi/azure/mount type cifs (rw,relatime,vers=3.1.1,cache=strict,username=mystorageacct19813,uid=0,noforceuid,gid=0,noforcegid,addr=20.60.79.8,file_mode=0777,dir_mode=0777,soft,persistenthandles,nounix,serverino,mapposix,mfsymlinks,rsize=1048576,wsize=1048576,bsize=1048576,echo_interval=60,actimeo=30,closetimeo=1)
```

```
# To display information about the csi-azurefile located in the node where the pod is scheduled.
kubectl get po -n kube-system -owide | grep csi-azurefile | grep vmss000004

# Here is a sample output below.
# csi-azurefile-node-h72r5              3/3     Running   0          10h     10.224.0.4   aks-nodepool1-51397738-vmss000004   <none>           <none>

# To retrieve CSI driver logs.
kubectl logs -n kube-system csi-azurefile-node-h72r5 -c azurefile

# Here is a sample output below.
I0629 20:24:15.766892       1 utils.go:76] GRPC call: /csi.v1.Node/NodePublishVolume
I0629 20:24:15.766906       1 utils.go:77] GRPC request: {"target_path":"/var/lib/kubelet/pods/1eed8fa0-86c4-4129-91de-bba88aee99ad/volumes/kubernetes.io~csi/azure/mount","volume_capability":{"AccessType":{"Mount":{}},"access_mode":{"mode":7}},"volume_context":{"csi.storage.k8s.io/ephemeral":"true","csi.storage.k8s.io/pod.name":"mypod","csi.storage.k8s.io/pod.namespace":"default","csi.storage.k8s.io/pod.uid":"1eed8fa0-86c4-4129-91de-bba88aee99ad","csi.storage.k8s.io/serviceAccount.name":"default","mountOptions":"dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock","secretName":"azure-secret","shareName":"aksshare"},"volume_id":"csi-3155cf52338ce63517fbaa609c86a7dc31d2cd0c97a784ef38a219719fd046e3"}
I0629 20:24:15.767003       1 nodeserver.go:68] NodePublishVolume: ephemeral volume(csi-3155cf52338ce63517fbaa609c86a7dc31d2cd0c97a784ef38a219719fd046e3) mount on /var/lib/kubelet/pods/1eed8fa0-86c4-4129-91de-bba88aee99ad/volumes/kubernetes.io~csi/azure/mount, VolumeContext: map[csi.storage.k8s.io/ephemeral:true csi.storage.k8s.io/pod.name:mypod csi.storage.k8s.io/pod.namespace:default csi.storage.k8s.io/pod.uid:1eed8fa0-86c4-4129-91de-bba88aee99ad csi.storage.k8s.io/serviceAccount.name:default getaccountkeyfromsecret:true mountOptions:dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock secretName:azure-secret secretnamespace:default shareName:aksshare storageaccount:]
W0629 20:24:15.767026       1 azurefile.go:601] parsing volumeID(csi-3155cf52338ce63517fbaa609c86a7dc31d2cd0c97a784ef38a219719fd046e3) return with error: error parsing volume id: "csi-3155cf52338ce63517fbaa609c86a7dc31d2cd0c97a784ef38a219719fd046e3", should at least contain two #
I0629 20:24:15.841976       1 nodeserver.go:302] cifsMountPath(/var/lib/kubelet/pods/1eed8fa0-86c4-4129-91de-bba88aee99ad/volumes/kubernetes.io~csi/azure/mount) fstype() volumeID(csi-3155cf52338ce63517fbaa609c86a7dc31d2cd0c97a784ef38a219719fd046e3) context(map[csi.storage.k8s.io/ephemeral:true csi.storage.k8s.io/pod.name:mypod csi.storage.k8s.io/pod.namespace:default csi.storage.k8s.io/pod.uid:1eed8fa0-86c4-4129-91de-bba88aee99ad csi.storage.k8s.io/serviceAccount.name:default getaccountkeyfromsecret:true mountOptions:dir_mode=0777,file_mode=0777,cache=strict,actimeo=30,nosharesock secretName:azure-secret secretnamespace:default shareName:aksshare storageaccount:]) mountflags([]) mountOptions([actimeo=30 cache=strict dir_mode=0777 file_mode=0777 nosharesock mfsymlinks]) volumeMountGroup()
I0629 20:24:15.911674       1 nodeserver.go:332] volume(csi-3155cf52338ce63517fbaa609c86a7dc31d2cd0c97a784ef38a219719fd046e3) mount //mystorageacct19813.file.core.windows.net/aksshare on /var/lib/kubelet/pods/1eed8fa0-86c4-4129-91de-bba88aee99ad/volumes/kubernetes.io~csi/azure/mount succeeded
I0629 20:24:15.911698       1 utils.go:83] GRPC response: {}
```

```
# Cleanup.
kubectl delete pod/mypod
kubectl delete secret azure-secret
az storage account delete -g $rgname -n $storageAccountName -y
```

## inline.(blob.csi).pod

- https://github.com/kubernetes-sigs/blob-csi-driver/blob/master/deploy/example/nginx-blobfuse-inline-volume.yaml
