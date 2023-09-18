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
  dnsPolicy: ClusterFirst
  restartPolicy: Always
EOF
sleep 20
kubectl get po
```

https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
