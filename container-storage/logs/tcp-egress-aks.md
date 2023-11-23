```
kubectl delete po nginx
kubectl run nginx --image=nginx
sleep 5
kubectl exec -it nginx -- /bin/bash
root@nginx:/# curl -kvv google.com
# root@nginx:/# nslookup google.com

# Test curl operation from a node in each subnet rather than using test pods.
# If timeouts persist, create temporary Ubuntu VMs in each subnet. Perform curl test from new VMs to identify issues in Kubernetes/AKS setup (e.g., CNI, nodepool) or VNET configuration within subnets.
# root@aks-nodepool1-40004829-vmss000006:/# nslookup google.com
Server:         172.30.48.1
Address:        172.30.48.1#53
Non-authoritative answer:
Name:   google.com
Address: 142.250.200.78
Name:   google.com
Address: 2a00:1450:4003:80d::200e
root@aks-nodepool1-40004829-vmss000006:/# curl -kvv google.com
```

- https://learn.microsoft.com/en-us/azure/aks/outbound-rules-control-egress
