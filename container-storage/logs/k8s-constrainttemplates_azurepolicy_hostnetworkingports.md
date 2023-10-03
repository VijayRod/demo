```
# hostnetworkingports (82985f06-dc18-4a48-bc1c-b9f4f0098cfe)
kubectl delete po nginx nginx2
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
---
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx2
  name: nginx2
spec:
  containers:
  - image: nginx
    name: nginx2
    ports:
    - containerPort: 80
      hostPort: 80
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  hostNetwork: true
EOF
kubectl get po -w

date; az policy state trigger-scan -g $rg
kubectl get k8sazurev3hostnetworkingports
kubectl describe k8sazurev3hostnetworkingports
```
