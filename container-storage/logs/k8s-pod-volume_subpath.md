- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/could-not-change-permissions-azure-files
- https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath

```
# subpath

kubectl delete po subpath-emptydir-demo
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: subpath-emptydir-demo
spec:
  containers:
  - name: app
    image: busybox
    command: [ "sleep", "3600" ]
    volumeMounts:
    - name: workdir
      mountPath: /mnt/data
      subPath: logs
  volumes:
  - name: workdir
    emptyDir: {}
  restartPolicy: Never
EOF
kubectl get po -owide -w

k describe po | grep subPath # no rows found
k get po -oyaml | grep subPath # subPath: logs
```

```
# subpath.value.limit

# scenario: a 400-character subpath value leads to a pod creation error
# mitigate: shorten volume names or subPaths. Consider flattening the directory structure or using fewer nested subPaths
# mitigate: force a node restart as a temporary workaround If pods are stuck in the deleting state, restarting the node can forcibly detach a file share volume (not required for emptyDir volume)
# rca: The path includes: The base path (/run/...), Pod UID, Volume plugin name, Volume name (which may include secrets, share names, etc.). If any of these components are long — especially the volume name or subPath — the total path can easily exceed PATH_MAX (see below for this value).

# subpath value with n characters
# subpath=$(head /dev/urandom | tr -dc a-z0-9 | head -c 5000); echo "length: ${#subpath}" # the output length may be much less than 5000 depending on the system locale
subpath=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 300); echo "length: ${#subpath}" # 300-character subpath value
      subPath: "$subpath"
      
subpath-emptydir-demo    0/1     CreateContainerConfigError   0          2s

k describe po subpath-emptydir-demo
Status:           Pending
Containers:
  app:
    State:          Waiting
      Reason:       CreateContainerConfigError
    Ready:          False
    Mounts:
      /mnt/data from workdir (rw,path="subPath-value-redacted")
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-wkn2n (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       False
  ContainersReady             False
  PodScheduled                True
Volumes:
  workdir:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:
    SizeLimit:  <unset>
  Normal   Pulled     23s                kubelet            Successfully pulled image "busybox" in 813ms (813ms including waiting). Image size: 2156518 bytes.
  Normal   Pulling    10s (x3 over 25s)  kubelet            Pulling image "busybox"
  Warning  Failed     9s (x3 over 25s)   kubelet            Error: failed to prepare subPath for volumeMount "workdir" of container "app"

# subPath-value-redacted = $subpath
# similar logs in kubelet default logs and with --v=12
root@aks-nodepool1-10466718-vmss000006:/# cat /var/log/syslog | tail
Jun 16 20:29:48 aks-nodepool1-10466718-vmss000006 kubelet[3724]: E0616 20:29:48.166754    3724 kubelet_pods.go:322] "Could not determine if subPath exists, will not attempt to change its permissions" path="/var/lib/kubelet/pods/889326fa-da21-41e9-acc9-7596a3b64ff8/volumes/kubernetes.io~empty-dir/workdir/subPath-value-redacted"
Jun 16 20:29:48 aks-nodepool1-10466718-vmss000006 kubelet[3724]: E0616 20:29:48.166827    3724 kubelet_pods.go:349] "Failed to prepare subPath for volumeMount of the container" err="error resolving symlinks in \"/var/lib/kubelet/pods/889326fa-da21-41e9-acc9-7596a3b64ff8/volumes/kubernetes.io~empty-dir/workdir/subPath-value-redacted\": lstat /var/lib/kubelet/pods/889326fa-da21-41e9-acc9-7596a3b64ff8/volumes/kubernetes.io~empty-dir/workdir/subPath-value-redacted: file name too long" containerName="app" volumeMountName="workdir"
Jun 16 20:29:48 aks-nodepool1-10466718-vmss000006 kubelet[3724]: E0616 20:29:48.166913    3724 kuberuntime_manager.go:1274] "Unhandled Error" err="container &Container{Name:app,Image:busybox,Command:[sleep 3600],Args:[],WorkingDir:,Ports:[]ContainerPort{},Env:[]EnvVar{EnvVar{redacted,},Resources:ResourceRequirements{Limits:ResourceList{},Requests:ResourceList{},Claims:[]ResourceClaim{},},VolumeMounts:[]VolumeMount{VolumeMount{Name:workdir,ReadOnly:false,MountPath:/mnt/data,SubPath:subPath-value-redacted,MountPropagation:nil,SubPathExpr:,RecursiveReadOnly:nil,},VolumeMount{Name:kube-api-access-wkn2n,ReadOnly:true,MountPath:/var/run/secrets/kubernetes.io/serviceaccount,SubPath:,MountPropagation:nil,SubPathExpr:,RecursiveReadOnly:nil,},},LivenessProbe:nil,ReadinessProbe:nil,Lifecycle:nil,TerminationMessagePath:/dev/termination-log,ImagePullPolicy:Always,SecurityContext:nil,Stdin:false,StdinOnce:false,TTY:false,EnvFrom:[]EnvFromSource{},TerminationMessagePolicy:File,VolumeDevices:[]VolumeDevice{},StartupProbe:nil,ResizePolicy:[]ContainerResizePolicy{},RestartPolicy:nil,} start failed in pod subpath-emptydir-demo_default(889326fa-da21-41e9-acc9-7596a3b64ff8): CreateContainerConfigError: failed to prepare subPath for volumeMount \"workdir\" of container \"app\"" logger="UnhandledError"
Jun 16 20:29:48 aks-nodepool1-10466718-vmss000006 kubelet[3724]: E0616 20:29:48.168077    3724 pod_workers.go:1301] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"app\" with CreateContainerConfigError: \"failed to prepare subPath for volumeMount \\\"workdir\\\" of container \\\"app\\\"\"" pod="default/subpath-emptydir-demo" podUID="889326fa-da21-41e9-acc9-7596a3b64ff8"

echo ${#subpath} # length of the variable $subpath

aks-nodepool1-10466718-vmss000006:/# getconf PATH_MAX / # 4096 # if the subpath variable length is significantly lesser than this value, the error is likely not due to the PATH_MAX value in Ubuntu
```

```
# subpath.azurefile

storageAccountName="mystorageacct$RANDOM"; echo $storageAccountName
shareName=aksshare; echo $shareName
noderg=$(az aks show --resource-group $rg --name aks --query nodeResourceGroup -o tsv); echo $noderg
az storage account create -g $noderg -n $storageAccountName --sku Premium_LRS --kind FileStorage --enable-large-file-share --output none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $noderg -n $storageAccountName -o tsv); echo $AZURE_STORAGE_CONNECTION_STRING
STORAGE_KEY=$(az storage account keys list -g $noderg --account-name $storageAccountName --query "[0].value" -o tsv)
echo Storage account key: $STORAGE_KEY
az storage share create -n $shareName --connection-string $AZURE_STORAGE_CONNECTION_STRING

kubectl delete secret azure-secret
kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storageAccountName --from-literal=azurestorageaccountkey=$STORAGE_KEY

kubectl delete po azurefile-subpath-demo
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: azurefile-subpath-demo
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    volumeMounts:
    - name: azurefile-vol
      mountPath: /mnt/azure
      subPath: logs
  volumes:
  - name: azurefile-vol
    csi:
      driver: file.csi.azure.com
      readOnly: false
      volumeAttributes:
        secretName: azure-secret
        shareName: "$shareName"
        storageAccount: "$storageAccountName"
        mountOptions: "dir_mode=0777,file_mode=0777,cache=strict"
  restartPolicy: Never
EOF
kubectl get po -owide -w

k logs -n kube-system csi-azurefile-node-xczcp -c azurefile | grep logs # no rows found for the subPath name
```
