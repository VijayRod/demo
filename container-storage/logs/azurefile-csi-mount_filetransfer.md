```
# Create the resources.
cat << EOF | kubectl create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-azurefile
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-premium
  resources:
    requests:
      storage: 100Gi
---
kind: Pod
apiVersion: v1
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: nginx
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 250m
        memory: 256Mi
    volumeMounts:
    - mountPath: "/mnt/azure"
      name: volume
  volumes:
  - name: volume
    persistentVolumeClaim:
      claimName: my-azurefile
EOF
```

```
kubectl exec -it mypod -- bash

# time dd if=/dev/zero of=/tmp/gentoo_root.img bs=4k iflag=fullblock,count_bytes count=200M
real    0m0.010s
user    0m0.002s
sys     0m0.000s

# time cp /tmp/gentoo_root.img /mnt/azure/
real    0m2.138s
user    0m0.000s
sys     0m0.316s

# time cp /mnt/azure/gentoo_root.img /tmp/gentoo_root2.img
real    0m2.903s
user    0m0.000s
sys     0m0.335s
```
