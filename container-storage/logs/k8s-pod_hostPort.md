> ## pod.hostPort

```
kubectl delete po nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80
      hostPort: 80
EOF
sleep 5
kubectl get po -w

k describe po nginx | head -n 20
Name:             nginx
Node:             aks-nodepool1-31079220-vmss000002/10.224.0.5
IP:               10.244.1.133
Containers:
  nginx:
    Host Port:      80/TCP
# aks-nodepool1-31079220-vmss000002 curl 10.224.0.5:80 -I # HTTP/1.1 200 OK
```

- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods/#my-pod-stays-pending: In most cases, hostPort is unnecessary, try using a Service object to expose your Pod. If you do require hostPort then you can only schedule as many Pods as there are nodes in your Kubernetes cluster.

```
kubectl delete deploy nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 5 # Ensure this is larger than the number of nodes
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        ports:
        - containerPort: 80
          hostPort: 80
EOF
sleep 5
kubectl get po -owide -w

kubectl describe po nginx-6fcd9974b6-62t5d
Status:           Pending
Events:
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  60s   default-scheduler  0/1 nodes are available: 1 node(s) didn't have free ports for the requested pod ports. preemption: 0/1 nodes are available: 1 No preemption victims found for incoming pod..
```
