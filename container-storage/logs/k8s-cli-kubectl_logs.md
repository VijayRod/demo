## k8s-cli-kubectl.logs

```
kubectl run nginx --image=nginx

# kubectl logs nginx | tail
2023/08/14 19:37:07 [notice] 1#1: start worker process 29
2023/08/14 19:37:07 [notice] 1#1: start worker process 30

kubectl logs nginx --tail=10 # Show the last 10 lines of logs
kubectl logs nginx --timestamps=true
kubectl logs nginx --since=1h # 30s 10m
kubectl logs nginx --previous # Show previous container logs if the pod still exists
kubectl logs nginx -c nginx
kubectl logs nginx -f # follow/stream
kubectl attach nginx
```

```
# root@aks-nodepool1-51397738-vmss00000Z:/# cat /var/log/syslog
Aug 14 19:37:08 aks-nodepool1-51397738-vmss00000Z kubelet[1734]: I0814 19:37:08.209275    1734 logs.go:323] "Finished parsing log file" path="/var/log/pods/default_nginx_96d459e4-c1a6-4412-b38d-dbf299dafd19/nginx/0.log"

# root@aks-nodepool1-51397738-vmss00000Z:/# ls /var/log/pods/default_nginx_96d459e4-c1a6-4412-b38d-dbf299dafd19
nginx

# root@aks-nodepool1-51397738-vmss00000Z:/# cat /var/log/pods/default_nginx_96d459e4-c1a6-4412-b38d-dbf299dafd19/nginx/0.log | tail
2023-08-14T19:37:07.077871413Z stderr F 2023/08/14 19:37:07 [notice] 1#1: start worker process 29
2023-08-14T19:37:07.078055513Z stderr F 2023/08/14 19:37:07 [notice] 1#1: start worker process 30

# root@aks-nodepool1-51397738-vmss00000Z:/# cat /var/log/containers/nginx_default_nginx-578f72d0d40c1758c61041acae108c22d210cbd1c6ea879be27b101870921454.log | tail
2023-08-14T19:37:07.077871413Z stderr F 2023/08/14 19:37:07 [notice] 1#1: start worker process 29
2023-08-14T19:37:07.078055513Z stderr F 2023/08/14 19:37:07 [notice] 1#1: start worker process 30
```

```
# root@aks-nodepool1-51397738-vmss00000Z:~# crictl ps | grep nginx
CONTAINER           IMAGE               CREATED             STATE               NAME                    ATTEMPT             POD ID              POD
578f72d0d40c1       89da1fb6dcb96       48 minutes ago      Running             nginx                   0        a70c7e3fcbe13       nginx

# root@aks-nodepool1-51397738-vmss00000Z:~# crictl logs 578f72d0d40c1 | tail
2023/08/14 19:37:07 [notice] 1#1: start worker process 29
2023/08/14 19:37:07 [notice] 1#1: start worker process 30

# root@aks-nodepool1-51397738-vmss00000Z:~# crictl inspect 578f72d0d40c1 | grep logPath
    "logPath": "/var/log/pods/default_nginx_96d459e4-c1a6-4412-b38d-dbf299dafd19/nginx/0.log",
```

- https://kubernetes.io/docs/concepts/cluster-administration/logging/
- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs
- https://github.com/kubernetes/kubernetes/blob/master/staging/src/k8s.io/kubectl/pkg/cmd/logs/logs.go
- https://stackoverflow.com/questions/47915287/where-are-kubernetes-pods-logfiles
- https://kubernetes.io/docs/reference/kubectl/cheatsheet/#interacting-with-running-pods: kubectl logs

## k8s-cli-kubectl.logs.error exec /docker-entrypoint.sh: exec format error

```
Pod status: CrashLoopBackOff
kubectl logs: exec /docker-entrypoint.sh: exec format error
```

- https://www.reddit.com/r/docker/comments/1bq7fhs/getting_exec_dockerentrypointsh_exec_format_error/: That's the error you get when running the wrong architecture executable for the CPU.
- https://stackoverflow.com/questions/73320833/docker-image-running-successfully-in-my-local-but-not-in-kuberneters-cluster: inspect your_image and it will show on which Architecture it will work
