```
cat << EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ultra-disk-sc
provisioner: disk.csi.azure.com # replace with "kubernetes.io/azure-disk" if aks version is less than 1.21
volumeBindingMode: WaitForFirstConsumer # optional, but recommended if you want to wait until the pod that will use this disk is created 
parameters:
  skuname: UltraSSD_LRS
  kind: managed
  cachingMode: None
  diskIopsReadWrite: "2000"  # minimum value: 2 IOPS/GiB 
  diskMbpsReadWrite: "320"   # minimum value: 0.032/GiB
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-ultradisk
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: ultra-disk-sc
  resources:
    requests:
      storage: 1000Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: nginx-ultra
spec:
  containers:
  - name: nginx-ultra
    image: nginx
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: ultra-disk
EOF
sleep 30
kubectl get po,pv,pvc
```

```
kubectl delete po nginx-ultra
kubectl delete pvc pvc-ultradisk
kubectl delete sc ultra-disk-sc
```

- https://learn.microsoft.com/en-us/azure/aks/use-ultra-disks
- https://learn.microsoft.com/en-us/troubleshoot/azure/azure-kubernetes/fail-to-mount-azure-disk-volume#error4: StorageAccountType UltraSSD_LRS can be used only when additionalCapabilities.ultraSSDEnabled is set
