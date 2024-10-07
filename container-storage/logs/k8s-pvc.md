## k8s-pvc

```
kubectl api-resources | grep pv
NAME                                SHORTNAMES          APIVERSION                             NAMESPACED   KIND
persistentvolumeclaims              pvc                 v1                                     true         PersistentVolumeClaim
persistentvolumes                   pv                  v1                                     false        PersistentVolume
```

## k8s-pvc.scale

```
# create 300 pvcs using a custom storage class
rm /tmp/pods.yaml
cat <<EOF >> /tmp/pods.yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: test-azurefile-csi
mountOptions:
- mfsymlinks
- actimeo=30
parameters:
  skuName: Standard_LRS
  useDataPlaneAPI: "true"
provisioner: file.csi.azure.com
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
--- # This is necessary as it precedes the next pod definition in the file
EOF
for i in $(seq -f "%03g" 1 300)
do
  cat <<EOF >> /tmp/pods.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-azurefile-$i
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: test-azurefile-csi
---
EOF
done
cat /tmp/pods.yaml

echo Before starting the creation process...
date
kubectl create -f /tmp/pods.yaml
echo After the creation process is complete...
date
kubectl get pv -w
kubectl get pvc --sort-by=.metadata.creationTimestamp -A |grep -i azurefile|grep -i Pending|head -n5
kubectl get pv | grep Bound | wc -l

cat /tmp/pods.yaml
kubectl delete -f /tmp/pods.yaml
kubectl delete po --all
kubectl delete pvc --all
```

## k8s-pvc.status.bound aka binding

```
storageclass.volumeBindingMode
```
