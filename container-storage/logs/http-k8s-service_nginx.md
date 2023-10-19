Network flow: Client -> Application Gateway -> Load Balancer (Kubernetes service exposed port 80) -> VM Scale Set (Scale Set public IP is the LB frontend IP)

```
kubectl delete svc nginx
kubectl delete po nginx
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80 --type=LoadBalancer
sleep 15
kubectl get po nginx
kubectl get svc nginx # The command displays the EXTERNAL-IP, which is the same as one of the Frontend IPs of the Kubernetes LoadBalancer (LB)
```

```
NAME    TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
nginx   LoadBalancer   10.0.194.202   20.240.36.24   80:30696/TCP   64m

kubectl exec -it nginx -- bash
apt update && apt install telnet -y && telnet localhost 80
# Escape character is '^]'.

# Adding the client range to the NSG (Network Security Group) is not necessary because the Load Balancer (LB) frontend IP is created as a public IP resource
curl -I $externalIp
HTTP/1.1 200 OK

# The application gateway can be in any resource group, must be in its own subnet within the same virtual network as the cluster. 
# Add the client range to the NSG (Network Security Group).
# The application gateway Backend pool has target IP address $kubernetesLoadBalancerFrontendIp (same as the $externalIp), uses Backend settings with (http) protocol and port = svc.Port (80) of the nginx service, and the Backend health status is expected to be green/healthy (Note: It may take up to 15 minutes for a new or started application gateway).
of the app gateway.
curl -I $appgwFrontendIp 
HTTP/1.1 200 OK
```
