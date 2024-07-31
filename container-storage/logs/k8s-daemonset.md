```
kubectl create deploy nginx --image=nginx --dry-run=client -oyaml # Then manually edit the output to change the kind to DaemonSet

kubectl delete ds nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: nginx
  name: nginx
spec:
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
EOF
sleep 10
kubectl get po -owide | grep nginx

kubectl expose ds nginx
error: cannot expose a DaemonSet.apps

```

- https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
- https://spot.io/resources/kubernetes-autoscaling/kubernetes-daemonset-a-practical-guide/
