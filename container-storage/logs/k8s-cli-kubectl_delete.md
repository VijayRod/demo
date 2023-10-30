```
kubectl delete pods --all # -A
```

```
kubectl create deploy nginx --image=nginx
sleep 10; kubectl get po | grep nginx
kubectl delete deploy nginx --cascade=foreground
```

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/#deleting-resources
