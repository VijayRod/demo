```
kubectl label namespace default istio.io/rev=asm-1-17
kubectl run nginx --image=nginx
sleep 40
kubectl get po nginx
NAME    READY   STATUS    RESTARTS   AGE
nginx   2/2     Running   0          73s

kubectl describe po nginx
Containers:
  istio-proxy:
    Container ID:  containerd://1f7ffaa6684ec815bad3c81b01786c52bbeb90376e194fe8bf80729f449b055b
    Image:         mcr.microsoft.com/oss/istio/proxyv2:1.17.5-distroless
```
    
- https://learn.microsoft.com/en-us/azure/aks/istio-deploy-addon#enable-sidecar-injection
