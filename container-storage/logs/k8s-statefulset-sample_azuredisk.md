```
kubectl delete statefulset statefulset-azuredisk
cd /tmp
wget https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/deploy/example/statefulset.yaml
chmod +x statefulset.yaml
kubectl apply -f statefulset.yaml
sleep 1m
kubectl get statefulset statefulset-azuredisk
kubectl get po -l app=nginx
```

```
kubectl scale statefulset statefulset-azuredisk --replicas=2
```

- https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/master/deploy/example/statefulset.yaml
