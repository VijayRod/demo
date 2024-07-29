- A single outbound IP address

```
kubectl run nginx --image=nginx
sleep 10
kubectl exec -it nginx -- curl ifconfig.me # 74.241.163.46

publicIpResourceUri=$(az aks show -g $rg -n aks --query networkProfile.loadBalancerProfile.effectiveOutboundIPs[].id -otsv)
az network public-ip show --ids $publicIpResourceUri --query ipAddress -o tsv # 74.241.163.46
```

- Multiple outbound IP addresses

```
az aks update -g $rg -n aksdns --load-balancer-managed-outbound-ip-count 2
kubectl run nginx --image=nginx
kubectl run nginx2 --image=nginx
sleep 10
kubectl exec -it nginx -- curl ifconfig.me # 74.241.163.46
kubectl exec -it nginx2 -- curl ifconfig.me # 74.241.163.46 (Shows the same IP)
```

- https://learn.microsoft.com/en-us/azure/load-balancer/outbound-rules#scale
