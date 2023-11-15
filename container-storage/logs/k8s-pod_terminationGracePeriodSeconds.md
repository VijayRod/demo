```
kubectl delete po nginx
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  terminationGracePeriodSeconds: 86400 # 24h. 
EOF
sleep 10
kubectl get po nginx

kubectl get po -oyaml
apiVersion: v1
items:
- apiVersion: v1
  spec:
    terminationGracePeriodSeconds: 86400
```    

```    
kubectl delete deploy nginx
cat << EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx
  name: nginx
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
      terminationGracePeriodSeconds: 86400 # 24h. 
EOF
sleep 10
kubectl get deploy nginx
```
    
- https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination
- https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#hook-handler-execution
- https://kubernetes.io/docs/tutorials/services/pods-and-endpoint-termination-flow/#example-flow-with-endpoint-termination
