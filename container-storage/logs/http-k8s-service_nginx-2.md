Network flow: Client -> Application Gateway -> Load Balancer (Kubernetes service exposed port 8080) -> VM Scale Set (Scale Set public IP is the LB frontend IP)

```
kubectl delete svc nginx
kubectl delete po nginx
kubectl run nginx --image=nginx
kubectl expose po nginx --port=8080 --target-port=80 --type=LoadBalancer # Different exposed port 8080
sleep 15
kubectl get po nginx
kubectl get svc nginx
```

```
NAME    TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
nginx   LoadBalancer   10.0.84.215   4.225.3.146   8080:31740/TCP   16s

kubectl exec -it nginx -- bash
apt update && apt install telnet -y && telnet localhost 80 # target-port=80
# Escape character is '^]'.

curl -I $externalIp:8080
HTTP/1.1 200 OK

curl -I $appgwFrontendIp # Backend port is 8080, however the frontend IP configuration in the application gateway does not include a port
HTTP/1.1 200 OK
```
