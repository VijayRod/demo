> ## k8s.pod.securityContext

- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

```
kubectl delete po --all
kubectl apply -f -<<EOF
apiVersion: v1
kind: Pod
metadata:
  name: netshoot
spec:
  containers:
  - name: netshoot
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    args: ["-c", "sleep 60000;"]
    securityContext:
      capabilities:
        add: ["NET_ADMIN", "SYS_TIME"]
EOF
kubectl get po -w

# the securityContext is not visible in kubectl describe output
k get po -oyaml
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  spec:
    containers:
    - args:
      - -c
      - sleep 60000;
      name: netshoot
      securityContext:
        capabilities:
          add:
          - NET_ADMIN
          - SYS_TIME
```

- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container


> ## k8s.pod.securityContext.fsGroup
```
# mount.timeout.fsGroup

# Random mount failure likely because its taking too long to set the volume ownership
# We observe that fsGroup in the pod securityContext is indeed being set. This can cause the blob CSI driver to take a long time to set the volume ownership, which involves changing the permissions on every file. The duration depends on the number of blobs in the storage account and may have led to the first aborted operation with a context deadline exceeded. How many blobs are in the storage account blob container?
# Can the customer try removing fsGroup and using fsGroupChangePolicy instead to see if the issue persists? Maybe the customer could try this in a test environment first.

# logs
# Could you please share the csi-blob-node pod logs, particularly the blob containers, from when this issue occurred?
# Could the customer please reproduce the issue without mitigating (without restarting the csi-blob-node pod) and send the full (csi-blob-node) pod logs from pod creation until 10 minutes after the first failed NodeStageVolume? Additionally, could the customer provide the pod definition to check if they are specifying an fsGroup in the securityContext of the pod?

2025-01-05 05:22 I0106 05:22    6576 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
2025-01-05 05:22 E0206 05:22    6525 utils.go:109] GRPC error: rpc error: code = Aborted desc = An operation with the given Volume ID MC_rg_aks_swedencentral#faf7a164ba5d246afaf9fa6#pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb already exists
2025-01-05 05:22 I0106 05:22    6525 utils.go:105] GRPC request: {"staging_target_path":"/var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/11111/globalmount","volume_capability":{"AccessType":{"Mount":{"mount_flags":["nconnect=4"],"volume_mount_group":"0"}},"access_mode":{"mode":5}},"volume_context":{"containerName":"storagecontainer","protocol":"nfs","resourceGroup":"mc_rg_aks_swedencentral","server":"faf7a164ba5d246afaf9fa6.privatelink.blob.core.windows.net","storageAccount":"faf7a164ba5d246afaf9fa6"},"volume_id":"MC_rg_aks_swedencentral#faf7a164ba5d246afaf9fa6#pvc-2945a875-04b7-472c-9d1b-2997b2e8ebbb"}
2025-01-05 05:22 I0106 05:22    6525 utils.go:104] GRPC call: /csi.v1.Node/NodeStageVolume
2025-01-05 05:22 W0106 05:22    6231 volume_linux.go:49] Setting volume ownership for /var/lib/kubelet/plugins/kubernetes.io/csi/blob.csi.azure.com/11111/globalmount and fsGroup set. If the volume has a lot of files then setting volume ownership could be slow, see https://github.com/kubernetes/kubernetes/issues/69699

/var/log/syslog
kubelet[1111]: W0215 .. 1111 volume_linux.go:49] Setting volume ownership for /var/lib/kubelet/pods/redactp-1111-1111-1111-111111111111/volumes/kubernetes.io~csi/pvc-redact2-1111-1111-1111-111111111111/mount and fsGroup set. If the volume has a lot of files then setting volume ownership could be slow, see https://github.com/kubernetes/kubernetes/issues/69699

# test
# tbd ~11k blobs in the file share
```

- https://github.com/kubernetes-sigs/kubespray/issues/6619: Setting volume ownership for ... and fsGroup set. If the volume has a lot of files then setting volume ownership could be slow, see https://github.com/kubernetes/kubernetes/issues/69699 (Set pod.securityContext.fsGroupChangePolicy as "OnRootMismatch")
- https://github.com/kubernetes/kubernetes/blob/master/pkg/volume/volume_linux.go: SetVolumeOwnership. klog.Warningf("Setting volume ownership for %s and fsGroup set. If the volume has a lot of files then setting volume ownership could be slow, see https://github.com/kubernetes/kubernetes/issues/69699", dir)
- https://github.com/kubernetes/kubernetes/issues/67014#issuecomment-413546283: fsGroup option. Today, I just removed and started pod again, it started in 1 minutes. I guess on each disk attach, its trying to change group id of all files which is in disk and this causing to time out error.
- https://github.com/kubernetes/kubernetes/issues/67014#issuecomment-589915496: chown slowness. pod run as root. set supplementalGroup to match the gid of the volume (safer since not run as root)
- https://github.com/kubernetes/kubernetes/issues/69699: fsgroup setting is recursively set on every mount. This can make mount very slow if the volume has many files
- https://kubernetes.io/blog/2020/12/14/kubernetes-release-1.20-fsgroupchangepolicy-fsgrouppolicy/
- https://kubernetes.io/blog/2022/12/23/kubernetes-12-06-fsgroup-on-mount/
- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods: For large volumes, checking and changing ownership and permissions can take a lot of time, slowing Pod startup.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-disk-volume#error5: ApplyFSGroup failed for vol. To resolve this error, we recommend that you set fsGroupChangePolicy: "OnRootMismatch" in the securityContext of a Deployment, a StatefulSet or a pod.
- https://stackoverflow.com/questions/68079774/write-permissions-on-volume-mount-with-security-context-fsgroup-option
- https://stackoverflow.com/questions/69805813/fsgroup-vs-supplementalgroups

```
TBD (pod in ContainerCreating during issue)
# mount.timeout.fsGroup.sample

rg=rg
storage="storage$RANDOM"
share=aksshare
az group create -n $rg -l $loc
az aks create -g $rg -n aks -s $vmsize -c 1
az aks get-credentials -g $rg -n aks --overwrite-existing

noderg=$(az aks show --resource-group $rg --name aks --query nodeResourceGroup -o tsv)
az storage account create -g $noderg -n $storage --sku Premium_LRS --kind FileStorage --enable-large-file-share --output none
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $noderg -n $storage -o tsv)
key=$(az storage account keys list -g $noderg --account-name $storage --query "[0].value" -o tsv)
echo Storage account key: $key
az storage share create -n $share --connection-string $AZURE_STORAGE_CONNECTION_STRING

kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=$storage --from-literal=azurestorageaccountkey=$key

mkdir /tmp/filesforupload
for i in {1..500}; do touch /tmp/filesforupload/file$i; done
ls /tmp/filesforupload/ | wc -l

TBD (Upload in portal) azcopy cp "https://$storage.blob.core.windows.net/$share$SAS_TOKEN" "/tmp/${SRC_FILE}"

kubectl delete po mypod
kubectl delete pvc azurefile
kubectl delete pv azurefile
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: file.csi.azure.com
  name: azurefile
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: azurefile-premium
  csi:
    driver: file.csi.azure.com
    readOnly: false
    volumeHandle: id123456  # make sure this volumeid is unique for every identical share in the cluster
    volumeAttributes:
      resourceGroup: $noderg  # optional, only set this when storage account is not in the same resource group as node
      shareName: $share
      # fsGroupChangePolicy: None # Alternate mitigation. It would involve recreating the Persistent Volume (PV)
    nodeStageSecretRef:
      name: azure-secret
      namespace: default
  mountOptions:
    - dir_mode=0777
    - file_mode=0777
    - uid=0
    - gid=0
    - mfsymlinks
    - cache=strict
    - nosharesock
    - nobrl
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: azurefile-premium
  volumeName: azurefile
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  securityContext:
    fsGroup: 10003 # Alternate solution to the issue is by removing the fsgroup configuration and then running the chown command in an initContainer
    # fsGroupChangePolicy: OnRootMismatch # The primary mitigation is to add this setting
  containers:
  - image: mcr.microsoft.com/oss/nginx/nginx:1.15.5-alpine
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
    persistentVolumeClaim:
      claimName: azurefile
EOF
sleep 10
kubectl get po,pv,pvc
kubectl exec -it mypod -- ls -l /mnt/azure | wc -l # 501
kubectl logs -n kube-system -l app=csi-azurefile-node -c azurefile | tail
```

> ## k8s.pod.securityContext.runAsUser(uid)


- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/failure-setting-azure-disk-mount-options-uid-gid
