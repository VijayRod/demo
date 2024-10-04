## k8s-pod.nodeSelector

```
kubectl delete po nginx
kubectl run nginx --image=nginx --overrides='{"spec": { "nodeSelector": {"kubernetes.io/os": "linux"}}}' # Forbidden to update this field for an existing pod

kubectl delete po nginx
kubectl run nginx --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-38494683-vmss000000"}}}' # --dry-run client -oyaml
kubectl expose po nginx

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
  - args:
    - client
    image: nginx
    name: nginx
    ports:
    - containerPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  nodeSelector:
    kubernetes.io/hostname: aks-nodepool1-38494683-vmss000000
EOF
kubectl get po -w

kubectl delete deploy nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
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
      nodeSelector:
        kubernetes.azure.com/agentpool: nodepool5
EOF
k get deploy -w
```

- https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
