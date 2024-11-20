## pod.container.init

```
kubectl delete po myapp-pod
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app.kubernetes.io/name: MyApp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "echo starting init; sleep 30"]
EOF
kubectl get po -owide; kubectl logs myapp-pod -c init-myservice

NAME        READY   STATUS     RESTARTS   AGE   IP       NODE                                NOMINATED NODE   READINESS GATES
myapp-pod   0/1     Init:0/1   0          1s    <none>   aks-nodepool1-40899545-vmss000001   <none>           <none>
starting init

NAME        READY   STATUS     RESTARTS   AGE   IP           NODE                                NOMINATED NODE   READINESS GATES
myapp-pod   0/1     Init:0/1   0          4s    10.244.2.7   aks-nodepool1-40899545-vmss000001   <none>           <none>
starting init

NAME        READY   STATUS    RESTARTS   AGE   IP           NODE                                NOMINATED NODE   READINESS GATES
myapp-pod   1/1     Running   0          32s   10.244.2.7   aks-nodepool1-40899545-vmss000001   <none>           <none>
starting init
```

- https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-init-containers/
- https://kubernetes.io/docs/concepts/workloads/pods/init-containers/#differences-from-sidecar-containers
