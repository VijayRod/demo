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
  name: aspnetapp
spec:
  nodeSelector:
    "kubernetes.io/os": windows
  containers:
  - name: aspnetapp
    image: mcr.microsoft.com/dotnet/framework/samples:aspnetapp
    resources:
      requests:
        cpu: 100m
        memory: 2048M
      limits:
        cpu: 250m
        memory: 2048M
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
# kubectl exec -it aspnetapp -- powershell
mkdir c:\tmp; cd c:\tmp
Compress-Archive -LiteralPath C:\Windows\assembly -DestinationPath assembly.zip

# dir
    Directory: C:\tmp
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         8/8/2023   5:54 PM      421929668 assembly.zip

# Measure-Command { copy assembly.zip /mnt/azure }
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 3
Milliseconds      : 129
Ticks             : 31293647
TotalDays         : 3.62194988425926E-05
TotalHours        : 0.000869267972222222
TotalMinutes      : 0.0521560783333333
TotalSeconds      : 3.1293647
TotalMilliseconds : 3129.3647

# Measure-Command { copy /mnt/azure/assembly.zip assembly2.zip }
Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 2
Milliseconds      : 482
Ticks             : 24827441
TotalDays         : 2.87354641203704E-05
TotalHours        : 0.000689651138888889
TotalMinutes      : 0.0413790683333333
TotalSeconds      : 2.4827441
TotalMilliseconds : 2482.7441
```

```
# To cleanup
kubectl delete po aspnetapp
kubectl delete pvc my-azurefile
```
