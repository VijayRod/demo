```
TBD (volume node affinity conflict)

az aks nodepool add -g $rg --cluster-name aks -n npzone1 --zone 1 -s $vmsize

noderg=$(az aks show -g $rg -n aks --query nodeResourceGroup -o tsv)

diskUri=$(az disk create -g $noderg -n myAKSDisk --size-gb 20 --query id --output tsv)

kubectl delete po mypod
kubectl delete pvc pvc-azuredisk
kubectl delete pv pv-azuredisk
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    pv.kubernetes.io/provisioned-by: disk.csi.azure.com
  name: pv-azuredisk
  labels:
    topology.kubernetes.io/zone: swedencentral-2
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: managed-csi
  csi:
    driver: disk.csi.azure.com
    readOnly: false
    volumeHandle: $diskUri # unique value
    volumeAttributes:
      fsType: ext4
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azuredisk
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  volumeName: pv-azuredisk
  storageClassName: managed-csi
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  nodeSelector:
    kubernetes.io/os: linux
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
      - name: azure
        mountPath: /mnt/azure
  volumes:
    - name: azure
      persistentVolumeClaim:
        claimName: pvc-azuredisk
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
            - swedencentral-1
EOF
sleep 30
kubectl describe po mypod
kubectl get po,pv,pvc

  Warning  FailedScheduling  39s   default-scheduler  0/4 nodes are available: 1 node(s) didn't match Pod's node affinity/selector, 3 node(s) had no available volume zone. preemption: 0/4 nodes are available: 4 Preemption is not helpful for scheduling..
```

- https://learn.microsoft.com/en-us/azure/aks/availability-zones#azure-disk-availability-zone-support: Volumes that use Azure managed LRS disks aren't zone-redundant resources, attaching across zones and aren't supported. You need to co-locate volumes in the same zone...
- https://stackoverflow.com/questions/51946393/kubernetes-pod-warning-1-nodes-had-volume-node-affinity-conflict
