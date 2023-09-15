```
kubectl run --image=mcr.microsoft.com/windows/servercore:ltsc2022 servercore --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/os": "windows" } } } } }'

kubectl run --image=mcr.microsoft.com/dotnet/framework/samples:aspnetapp aspnetapp --overrides='{ "spec": { "template": { "spec": { "nodeSelector": { "kubernetes.io/os": "windows" } } } } }' --port 80
```

```
apiVersion: v1
kind: Pod
metadata:
  name: windowspod
spec:
   nodeSelector:
     "kubernetes.io/os": windows
  containers:
  - name: sample
    image: mcr.microsoft.com/dotnet/framework/samples:aspnetapp
    ports:
    - containerPort: 80
```
