```
kubectl run nginx --image=nginx
kubectl debug -it nginx --image=busybox:1.28 --target=nginx # https://kubernetes.io/docs/tasks/debug/debug-application/debug-running-pod/#ephemeral-container-example
```
