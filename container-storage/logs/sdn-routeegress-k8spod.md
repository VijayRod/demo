## routeegress.k8spod.cni.kubenet

```
# Kubenet should SNAT to the node IP before leaving the node, unless there's a custom config under the IP masq agent (nonMasqueradeCIDRs).
# outbound curl request from a pod

kubectl delete po nginx
kubectl run nginx --image=nginx
sleep 10
kubectl get po # nginx
kubectl exec nginx -- curl -I google.com
kubectl exec nginx -- curl -Iv google.com # * Connected to google.com (142.250.74.174) port 80 (#0)

# NSG flow log: FlowDirection_s=O, FlowType_s=ExternalPublic, SrcIP_s=<Node IP> (not the pod IP)
```

- https://github.com/Azure/AKS/issues/2031: The existing behavior for AKS clusters using kubenet network plugin is to only SNAT/Masquerade pod traffic to the source Node IP when leaving the PodCIDR and cluster Subnet.
- https://blog.stevegriffith.nyc/posts/aks-networking-part1/: SNAT should ONLY happen for packets NOT destined for our cluster’s pod cidr
