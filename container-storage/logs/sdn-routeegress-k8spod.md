## routeegress.k8spod

```
curl -Iv google.com # * Connected to google.com (142.250.200.14) port 80. HTTP/1.1 301 Moved Permanently

# kubectl run nginx --image=nginx; kubectl exec -it nginx -- curl -Iv google.com
kubectl delete po nginx
kubectl run nginx --image=nginx
sleep 10
kubectl get po # nginx
# kubectl exec nginx -- curl -I google.com
kubectl exec nginx -- curl -Iv google.com # * Connected to google.com (142.250.74.174) port 80 (#0)

## update node names (first two lines target the same node, the third targets a different one)
kubectl run nginx0 --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-10049467-vmss000000"}}}'
kubectl run nginx02 --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-10049467-vmss000000"}}}'
kubectl run nginx1 --image=nginx --port=80 --overrides='{"spec": { "nodeSelector": {"kubernetes.io/hostname": "aks-nodepool1-10049467-vmss000001"}}}'
sleep 10
kubectl get po -owide
## curl to another pod on the same node and to another pod on a different node. Replace the IPs below
kubectl exec nginx0 -- curl -I 10.244.0.71
kubectl exec nginx0 -- curl -I 10.244.1.233
```

## routeegress.k8spod.cni.kubenet

```
# outbound curl request from a pod - Kubenet should SNAT to the node IP before leaving the node, unless there's a custom config under the IP masq agent (nonMasqueradeCIDRs).
# NSG flow log: FlowDirection_s=O, FlowType_s=ExternalPublic, SrcIP_s=<Node IP> (not the pod IP)
```

- https://github.com/Azure/AKS/issues/2031: The existing behavior for AKS clusters using kubenet network plugin is to only SNAT/Masquerade pod traffic to the source Node IP when leaving the PodCIDR and cluster Subnet.
- https://blog.stevegriffith.nyc/posts/aks-networking-part1/: SNAT should ONLY happen for packets NOT destined for our cluster’s pod cidr
