```
# create
kubectl create deploy nginx --image=nginx

# run
kubectl run nginx --image=nginx
kubectl run busybox --image=busybox --command -- sh -c 'sleep 1d' # sleep 1d or sleep 100000 or sleep infinity

# yaml
kubectl create deploy nginx --image=nginx -oyaml --dry-run=client
kubectl run nginx --image=nginx -oyaml --dry-run=client
```

- https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#create
