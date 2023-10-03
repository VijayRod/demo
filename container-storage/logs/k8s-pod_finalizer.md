```
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  finalizers:
  - finalizer.extensions/v1beta1  
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
kubectl delete po nginx # hung
```

```
kubectl get po nginx -oyaml | grep deletion
metadata:
  deletionGracePeriodSeconds: 0
  deletionTimestamp: "2023-10-03T20:26:15Z"
  
kubectl patch po nginx -p '{"metadata":{"finalizers":null}}'
```

```
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
  finalizers:
  - finalizer.extensions/v1beta1  
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
EOF
kubectl delete deploy nginx
# kubectl get deploy nginx -oyaml | grep deletion
# kubectl patch deploy nginx -p '{"metadata":{"finalizers":null}}'

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  creationTimestamp: null
  name: nginx
  finalizers:
  - finalizer.extensions/v1beta1  
EOF
kubectl delete ns nginx
# kubectl get ns nginx -oyaml
# kubectl patch ns nginx -p '{"metadata":{"finalizers":null}}'
```
  
- https://kubernetes.io/blog/2021/05/14/using-finalizers-to-control-deletion/
- https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/
- https://kubernetes.io/docs/concepts/architecture/garbage-collection/
- https://book.kubebuilder.io/reference/using-finalizers.html
- https://kubebyexample.com/learning-paths/operator-framework/kubernetes-api-fundamentals/finalizers
