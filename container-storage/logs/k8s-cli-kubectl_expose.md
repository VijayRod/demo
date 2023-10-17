```
kubectl run --image=nginx nginx --port=80
kubectl expose po nginx --type=LoadBalancer ##--name=public-svc
# kubectl expose po nginx --port=80 # curl ip
# kubectl expose po nginx --port=8080 --target-port=80 # curl ip:8080
```

```
kubectl create deploy nginx --image=nginx --port=80 --replicas=2
kubectl scale deploy nginx --replicas=3
kubectl expose deploy nginx --type=LoadBalancer
```
