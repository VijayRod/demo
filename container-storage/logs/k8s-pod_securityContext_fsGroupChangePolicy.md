```
TBD (pod in ContainerCreating during issue)

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

- https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#configure-volume-permission-and-ownership-change-policy-for-pods: For large volumes, checking and changing ownership and permissions can take a lot of time, slowing Pod startup.
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-disk-volume#error5: ApplyFSGroup failed for vol. To resolve this error, we recommend that you set fsGroupChangePolicy: "OnRootMismatch" in the securityContext of a Deployment, a StatefulSet or a pod.
- https://github.com/kubernetes-sigs/kubespray/issues/6619: Setting volume ownership for ... and fsGroup set. If the volume has a lot of files then setting volume ownership could be slow, see https://github.com/kubernetes/kubernetes/issues/69699 (Set pod.securityContext.fsGroupChangePolicy as "OnRootMismatch")
- https://kubernetes.io/blog/2020/12/14/kubernetes-release-1.20-fsgroupchangepolicy-fsgrouppolicy/
- https://kubernetes.io/blog/2022/12/23/kubernetes-12-06-fsgroup-on-mount/
- https://stackoverflow.com/questions/68079774/write-permissions-on-volume-mount-with-security-context-fsgroup-option
- https://stackoverflow.com/questions/69805813/fsgroup-vs-supplementalgroups
