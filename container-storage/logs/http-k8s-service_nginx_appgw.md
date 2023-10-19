Network flow: Client -> Application Gateway (backend pool targets for each node IP, backend port = Kubernetes service node port) -> VM ScaleSet VM(s)

```
kubectl delete svc nginx
kubectl delete po nginx
kubectl run nginx --image=nginx
kubectl expose po nginx --port=80 --type=LoadBalancer
sleep 15
kubectl get po nginx
kubectl get svc nginx

# The application gateway can be in any resource group, must be in its own subnet within the same virtual network as the cluster. 
# Add the client range to the NSG (Network Security Group).
# The application gateway Backend health status is expected to be green/healthy (Note: It may take up to 15 minutes for a new or started application gateway).
of the app gateway.
curl -I $appgwFrontendIp 
HTTP/1.1 200 OK
```
