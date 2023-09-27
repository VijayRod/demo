```
kubectl run --image=nginx nginx --port=80
kubectl expose po nginx --type=LoadBalancer ##--name=public-svc
```

```
kubectl create deploy nginx --image=nginx --port=80 --replicas=2
kubectl scale deploy nginx --replicas=3
kubectl expose deploy nginx --type=LoadBalancer
```
