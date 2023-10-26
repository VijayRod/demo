```
kubectl create deploy nginx --image=nginx
kubectl rollout restart deploy nginx # ds, statefulset
kubectl rollout restart deploy -l app=nginx
kubectl rollout status deploy -l app=nginx # deployment "nginx" successfully rolled out

kubectl rollout restart deploy -n kube-system ama-metrics
```

- https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/: Performing a Rolling Update
