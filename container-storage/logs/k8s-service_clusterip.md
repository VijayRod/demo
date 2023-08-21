```
kubectl run nginx --image=nginx
kubectl expose po nginx --port=8080
```

```
root@aks-nodepool1-51397738-vmss00000Z:/# curl 10.0.182.254 | grep DOC
<!DOCTYPE html>
```

```
# To cleanup
kubectl delete svc nginx
kubectl delete po nginx
```
